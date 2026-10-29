USE ELISA_analytics;
GO

/* ============================================================================
   02 — PLATE QC
   Purpose:
   Evaluate plate controls and calibrators, then consolidate them into a
   single plate-level validity decision.

   Project-specific acceptance criteria:
   Controls
   - Blank: mean OD <= 0.10; duplicate difference <= 0.05; n = 2
   - Negative: mean OD <= 0.15; duplicate difference <= 0.05; n = 2
   - Low positive: mean OD 0.30–0.80; CV <= 15%; n = 2
   - Positive: mean OD 1.20–2.50; CV <= 15%; n = 2

   Calibrators
   - CAL-0 mean OD <= 0.10
   - CAL-1 to CAL-6 CV <= 10%
   - Mean OD increases monotonically with concentration

   Plate validity
   - PASS only when both control QC and calibrator QC pass.
============================================================================ */

DROP TABLE IF EXISTS dbo.Allcontrols_QC;
GO

WITH ControlQC AS
(
    SELECT
        PlateID,
        ControlType,
        ROUND(AVG(OD450), 2) AS Mean_OD450,
        ROUND(STDEV(OD450), 2) AS SD_OD450,
        ROUND(
            (STDEV(OD450) / NULLIF(AVG(OD450), 0)) * 100,
            2
        ) AS CV_PERCENT,
        ROUND(MAX(OD450) - MIN(OD450), 2) AS Duplicate_Difference,
        COUNT(OD450) AS Replicate_Count,

        CASE
            WHEN ControlType = 'Blank'
                 AND AVG(OD450) <= 0.10
                 AND MAX(OD450) - MIN(OD450) <= 0.05
                 AND COUNT(OD450) = 2
            THEN 'PASS'

            WHEN ControlType = 'NegativeControl'
                 AND AVG(OD450) <= 0.15
                 AND MAX(OD450) - MIN(OD450) <= 0.05
                 AND COUNT(OD450) = 2
            THEN 'PASS'

            WHEN ControlType = 'LowPositiveControl'
                 AND AVG(OD450) BETWEEN 0.30 AND 0.80
                 AND (STDEV(OD450) / NULLIF(AVG(OD450), 0)) * 100 <= 15
                 AND COUNT(OD450) = 2
            THEN 'PASS'

            WHEN ControlType = 'PositiveControl'
                 AND AVG(OD450) BETWEEN 1.20 AND 2.50
                 AND (STDEV(OD450) / NULLIF(AVG(OD450), 0)) * 100 <= 15
                 AND COUNT(OD450) = 2
            THEN 'PASS'

            ELSE 'FAIL'
        END AS Plate_Control_QC

    FROM dbo.Plate_controls
    GROUP BY PlateID, ControlType
),

ControlPlateResult AS
(
    SELECT
        PlateID,
        SUM(CASE WHEN Plate_Control_QC = 'FAIL' THEN 1 ELSE 0 END)
            AS Control_Fails,
        CASE
            WHEN SUM(CASE WHEN Plate_Control_QC = 'FAIL' THEN 1 ELSE 0 END) > 0
            THEN 'FAIL'
            ELSE 'PASS'
        END AS Control_Plate_Status
    FROM ControlQC
    GROUP BY PlateID
),

CalibratorQC AS
(
    SELECT
        PlateID,
        CalibratorLevel,
        Concentration_U_mL,
        AVG(OD450) AS Mean_OD450,
        (STDEV(OD450) / NULLIF(AVG(OD450), 0)) * 100 AS CV_PERCENT,
        LAG(AVG(OD450)) OVER
        (
            PARTITION BY PlateID
            ORDER BY Concentration_U_mL
        ) AS Previous_Mean_OD
    FROM dbo.Calibrators
    GROUP BY PlateID, CalibratorLevel, Concentration_U_mL
),

CalibratorResult AS
(
    SELECT
        PlateID,
        CalibratorLevel,
        Concentration_U_mL,
        Mean_OD450,
        CV_PERCENT,
        Previous_Mean_OD,

        CASE
            WHEN CalibratorLevel = 'CAL-0'
                 AND Mean_OD450 <= 0.10
            THEN 'PASS'

            WHEN CalibratorLevel <> 'CAL-0'
                 AND CV_PERCENT <= 10
                 AND Mean_OD450 > Previous_Mean_OD
            THEN 'PASS'

            ELSE 'FAIL'
        END AS Calibrator_QC
    FROM CalibratorQC
),

CalibratorPlateResult AS
(
    SELECT
        PlateID,
        SUM(CASE WHEN Calibrator_QC = 'FAIL' THEN 1 ELSE 0 END)
            AS Calibrator_Fails,
        CASE
            WHEN SUM(CASE WHEN Calibrator_QC = 'FAIL' THEN 1 ELSE 0 END) > 0
            THEN 'FAIL'
            ELSE 'PASS'
        END AS Calibrator_Plate_Status
    FROM CalibratorResult
    GROUP BY PlateID
)

SELECT
    c.PlateID,
    c.Control_Plate_Status,
    k.Calibrator_Plate_Status,
    CASE
        WHEN c.Control_Plate_Status = 'PASS'
         AND k.Calibrator_Plate_Status = 'PASS'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Plate_QC_Status
INTO dbo.Allcontrols_QC
FROM ControlPlateResult AS c
LEFT JOIN CalibratorPlateResult AS k
    ON c.PlateID = k.PlateID;
GO


/* Final plate-level QC result */
SELECT
    PlateID,
    Control_Plate_Status,
    Calibrator_Plate_Status,
    Plate_QC_Status
FROM dbo.Allcontrols_QC
ORDER BY PlateID;
