USE ELISA_analytics;
GO

/* ============================================================================
   03 — SPECIMEN QC
   Purpose:
   Aggregate duplicate specimen wells and classify replicate precision.

   Project-specific specimen replicate criteria:
   - PASS   : CV <= 10%
   - REVIEW : CV > 10% and <= 15%
   - FAIL   : CV > 15%
   - Expected replicate count = 2
============================================================================ */

DROP TABLE IF EXISTS dbo.Specimen_QC;
GO

WITH SampleQC AS
(
    SELECT
        SpecimenID,
        PlateID,
        COUNT(Replicate) AS Replicate_Count,
        ROUND(AVG(OD450), 2) AS Mean_OD450,
        ROUND(STDEV(OD450), 2) AS Std_Dev,
        ROUND(
            STDEV(OD450) / NULLIF(AVG(OD450), 0) * 100,
            2
        ) AS CV_PERCENT
    FROM dbo.Sample_wells
    GROUP BY SpecimenID, PlateID
)

SELECT
    SpecimenID,
    PlateID,
    Replicate_Count,
    Mean_OD450,
    Std_Dev,
    CV_PERCENT,

    CASE
        WHEN Replicate_Count = 2
             AND CV_PERCENT <= 10
        THEN 'PASS'

        WHEN Replicate_Count = 2
             AND CV_PERCENT > 10
             AND CV_PERCENT <= 15
        THEN 'REVIEW'

        WHEN Replicate_Count = 2
             AND CV_PERCENT > 15
        THEN 'FAIL'

        ELSE 'REVIEW'
    END AS Sample_QC_Result

INTO dbo.Specimen_QC
FROM SampleQC;
GO


SELECT
    SpecimenID,
    PlateID,
    Replicate_Count,
    Mean_OD450,
    Std_Dev,
    CV_PERCENT,
    Sample_QC_Result
FROM dbo.Specimen_QC
ORDER BY SpecimenID;
