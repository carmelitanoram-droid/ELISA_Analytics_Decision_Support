USE ELISA_analytics;
GO

/* ============================================================================
   01 — DATA INTEGRITY & TRACEABILITY
   Purpose:
   Confirm that the five source datasets can be connected reliably before
   assay QC or specimen-level interpretation.

   Expected result for the portfolio dataset:
   The exception queries below return no records.
============================================================================ */


/* 1. Duplicate sample wells: PlateID + Well should be unique */
SELECT
    PlateID,
    Well,
    COUNT(*) AS Record_Count
FROM dbo.Sample_wells
GROUP BY PlateID, Well
HAVING COUNT(*) > 1;


/* 2. Sample wells referencing an unknown specimen */
SELECT DISTINCT
    sw.SpecimenID
FROM dbo.Sample_wells AS sw
LEFT JOIN dbo.Specimen_master AS sm
    ON sw.SpecimenID = sm.SpecimenID
WHERE sm.SpecimenID IS NULL;


/* 3. Sample wells referencing an unknown run */
SELECT DISTINCT
    sw.RunID
FROM dbo.Sample_wells AS sw
LEFT JOIN dbo.Run_metadata AS rm
    ON sw.RunID = rm.RunID
WHERE rm.RunID IS NULL;


/* 4. Specimens without exactly two replicate wells */
SELECT
    PlateID,
    SpecimenID,
    COUNT(*) AS Replicate_Count
FROM dbo.Sample_wells
GROUP BY PlateID, SpecimenID
HAVING COUNT(*) <> 2;


/* 5. Plate-to-run consistency:
      each PlateID represented in sample wells should map to one RunID */
SELECT
    PlateID,
    COUNT(DISTINCT RunID) AS Run_Count
FROM dbo.Sample_wells
GROUP BY PlateID
HAVING COUNT(DISTINCT RunID) <> 1;


/* 6. Missing critical run metadata */
SELECT
    RunID,
    PlateID,
    OperatorID,
    InstrumentID,
    ReagentKitLot,
    AmbientTemp_C,
    IncubationTime_min,
    WashCycles
FROM dbo.Run_metadata
WHERE
       PlateID IS NULL
    OR OperatorID IS NULL
    OR InstrumentID IS NULL
    OR ReagentKitLot IS NULL
    OR AmbientTemp_C IS NULL
    OR IncubationTime_min IS NULL
    OR WashCycles IS NULL;


/* Additional referential-integrity checks for controls and calibrators */
SELECT DISTINCT pc.RunID
FROM dbo.Plate_controls AS pc
LEFT JOIN dbo.Run_metadata AS rm
    ON pc.RunID = rm.RunID
WHERE rm.RunID IS NULL;

SELECT DISTINCT c.RunID
FROM dbo.Calibrators AS c
LEFT JOIN dbo.Run_metadata AS rm
    ON c.RunID = rm.RunID
WHERE rm.RunID IS NULL;


/* Review source-table structure */
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN
(
    'Calibrators',
    'Plate_controls',
    'Run_metadata',
    'Sample_wells',
    'Specimen_master'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;


/* ---------------------------------------------------------------------------
   Optional schema enforcement used during project setup.
   Run once on a database where these constraints do not already exist.
--------------------------------------------------------------------------- */
/*
ALTER TABLE dbo.Specimen_master
ADD CONSTRAINT PK_Specimen_Master
PRIMARY KEY (SpecimenID);

ALTER TABLE dbo.Run_metadata
ADD CONSTRAINT PK_Run_metadata
PRIMARY KEY (RunID);

ALTER TABLE dbo.Sample_wells
ADD CONSTRAINT PK_Sample_wells
PRIMARY KEY (PlateID, Well);

ALTER TABLE dbo.Sample_wells
ADD CONSTRAINT FK_SampleWells_SpecimenMaster
FOREIGN KEY (SpecimenID)
REFERENCES dbo.Specimen_master (SpecimenID);

ALTER TABLE dbo.Sample_wells
ADD CONSTRAINT FK_SampleWells_RunMeta
FOREIGN KEY (RunID)
REFERENCES dbo.Run_metadata (RunID);

ALTER TABLE dbo.Plate_controls
ADD CONSTRAINT PK_Plate_controls
PRIMARY KEY (PlateID, Well);

ALTER TABLE dbo.Plate_controls
ADD CONSTRAINT FK_PlateControls_RunMeta
FOREIGN KEY (RunID)
REFERENCES dbo.Run_metadata (RunID);

ALTER TABLE dbo.Calibrators
ADD CONSTRAINT PK_Calibrators
PRIMARY KEY (PlateID, Well);

ALTER TABLE dbo.Calibrators
ADD CONSTRAINT FK_Calibrators_RunMeta
FOREIGN KEY (RunID)
REFERENCES dbo.Run_metadata (RunID);
*/
