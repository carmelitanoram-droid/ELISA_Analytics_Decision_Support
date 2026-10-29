USE ELISA_analytics;
GO

/* ============================================================================
   04 — FINAL ANALYTICAL DATASET
   Purpose:
   1. Propagate plate validity to specimen-level results.
   2. Connect specimen QC with specimen and run/process metadata.
   3. Produce the analysis-ready dataset used for downstream investigation
      and Power BI.

   Decision rule:
   Plate failure overrides specimen replicate QC.
============================================================================ */

DROP TABLE IF EXISTS dbo.Final_Specimen_QC;
GO

SELECT
    s.SpecimenID,
    s.PlateID,
    s.Mean_OD450,
    s.Std_Dev,
    s.CV_PERCENT,
    s.Sample_QC_Result,
    p.Plate_QC_Status,

    CASE
        WHEN p.Plate_QC_Status = 'FAIL'
        THEN 'PLATE QC FAILED'

        WHEN s.Sample_QC_Result = 'PASS'
         AND p.Plate_QC_Status = 'PASS'
        THEN 'PASS'

        WHEN s.Sample_QC_Result = 'REVIEW'
         AND p.Plate_QC_Status = 'PASS'
        THEN 'REVIEW SAMPLE QC'

        WHEN s.Sample_QC_Result = 'FAIL'
         AND p.Plate_QC_Status = 'PASS'
        THEN 'SAMPLE QC FAILED'

        ELSE 'FAIL'
    END AS Specimen_Status

INTO dbo.Final_Specimen_QC
FROM dbo.Specimen_QC AS s
LEFT JOIN dbo.Allcontrols_QC AS p
    ON s.PlateID = p.PlateID;
GO


/* Recreate the integrated analysis-ready view */
CREATE OR ALTER VIEW dbo.vw_Final_Specimen_Metadata
AS
SELECT
    f.SpecimenID,
    f.PlateID,
    f.Mean_OD450,
    f.Std_Dev,
    f.CV_PERCENT,
    f.Sample_QC_Result,
    f.Plate_QC_Status,
    f.Specimen_Status,

    sm.SubjectID,
    sm.CollectionSite,
    sm.Matrix,
    sm.CollectionDate,
    sm.ReceiptDate,
    sm.ReferenceStatus,
    sm.ChallengeSpecimen,

    rm.RunID,
    rm.RunDate,
    rm.OperatorID,
    rm.InstrumentID,
    rm.ReagentKitLot,
    rm.AmbientTemp_C,
    rm.IncubationTime_min,
    rm.WashCycles,

    DATEDIFF(DAY, sm.CollectionDate, sm.ReceiptDate) AS Receipt_Delay

FROM dbo.Final_Specimen_QC AS f
LEFT JOIN dbo.Specimen_master AS sm
    ON f.SpecimenID = sm.SpecimenID
LEFT JOIN dbo.Run_metadata AS rm
    ON f.PlateID = rm.PlateID;
GO


/* Validate row preservation */
SELECT COUNT(*) AS Final_Specimen_QC_Rows
FROM dbo.Final_Specimen_QC;

SELECT COUNT(*) AS Integrated_Metadata_Rows
FROM dbo.vw_Final_Specimen_Metadata;


/* Check for unmatched specimen or run metadata after integration */
SELECT
    SUM(CASE WHEN sm.SpecimenID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Specimen_Metadata,
    SUM(CASE WHEN rm.PlateID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Run_Metadata
FROM dbo.Final_Specimen_QC AS f
LEFT JOIN dbo.Specimen_master AS sm
    ON f.SpecimenID = sm.SpecimenID
LEFT JOIN dbo.Run_metadata AS rm
    ON f.PlateID = rm.PlateID;


/* Final integrated dataset */
SELECT *
FROM dbo.vw_Final_Specimen_Metadata
ORDER BY PlateID, SpecimenID;
