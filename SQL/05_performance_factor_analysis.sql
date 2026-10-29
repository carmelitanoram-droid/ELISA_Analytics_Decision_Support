USE ELISA_analytics;
GO

/* ============================================================================
   05 — PERFORMANCE-FACTOR ANALYSIS
   Purpose:
   Explore specimen and run/process factors after plate validity has been
   established. These are descriptive investigation signals; statistical
   testing is performed separately in Python.

   Source:
   dbo.vw_Final_Specimen_Metadata created in 04_final_analytical_dataset.sql
============================================================================ */


/* Overall specimen outcome distribution on QC-valid plates */
SELECT
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percent_of_Valid_Plate_Specimens
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY Specimen_Status
ORDER BY Specimen_Count DESC;


/* Matrix */
SELECT
    Matrix,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY Matrix) AS Matrix_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Matrix)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Matrix
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY Matrix, Specimen_Status
ORDER BY Matrix, Percent_Within_Matrix DESC;


/* Collection site */
SELECT
    CollectionSite,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY CollectionSite) AS Site_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY CollectionSite)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Site
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY CollectionSite, Specimen_Status
ORDER BY CollectionSite, Percent_Within_Site DESC;


/* Reference status */
SELECT
    ReferenceStatus,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY ReferenceStatus) AS ReferenceStatus_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY ReferenceStatus)
        AS DECIMAL(5,2)
    ) AS Percent_Within_ReferenceStatus
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY ReferenceStatus, Specimen_Status
ORDER BY ReferenceStatus, Percent_Within_ReferenceStatus DESC;


/* Challenge specimen */
SELECT
    ChallengeSpecimen,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY ChallengeSpecimen) AS Challenge_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY ChallengeSpecimen)
        AS DECIMAL(5,2)
    ) AS Percent_Within_ChallengeGroup
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY ChallengeSpecimen, Specimen_Status
ORDER BY ChallengeSpecimen, Percent_Within_ChallengeGroup DESC;


/* Receipt delay */
SELECT
    Receipt_Delay,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY Receipt_Delay) AS ReceiptDelay_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Receipt_Delay)
        AS DECIMAL(5,2)
    ) AS Percent_Within_ReceiptDelay
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY Receipt_Delay, Specimen_Status
ORDER BY Receipt_Delay, Percent_Within_ReceiptDelay DESC;


/* Receipt delay by collection site — check possible confounding */
SELECT
    CollectionSite,
    Receipt_Delay,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY CollectionSite) AS Site_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY CollectionSite)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Site
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY CollectionSite, Receipt_Delay
ORDER BY CollectionSite, Receipt_Delay;


/* Matrix by collection site — check possible confounding */
SELECT
    CollectionSite,
    Matrix,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY CollectionSite) AS Site_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY CollectionSite)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Site
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY CollectionSite, Matrix
ORDER BY CollectionSite, Matrix;


/* Receipt delay by matrix — check possible confounding */
SELECT
    Matrix,
    Receipt_Delay,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY Matrix) AS Matrix_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Matrix)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Matrix
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY Matrix, Receipt_Delay
ORDER BY Matrix, Receipt_Delay;


/* Profile run/process factors */
SELECT
    COUNT(*) AS Number_of_Runs,
    COUNT(DISTINCT OperatorID) AS Number_of_Operators,
    COUNT(DISTINCT InstrumentID) AS Number_of_Instruments,
    COUNT(DISTINCT ReagentKitLot) AS Number_of_ReagentLots,
    MIN(AmbientTemp_C) AS Min_Temp,
    MAX(AmbientTemp_C) AS Max_Temp,
    MIN(IncubationTime_min) AS Min_Incubation,
    MAX(IncubationTime_min) AS Max_Incubation,
    MIN(WashCycles) AS Min_WashCycles,
    MAX(WashCycles) AS Max_WashCycles
FROM dbo.Run_metadata;


/* Operator */
SELECT
    OperatorID,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY OperatorID) AS Operator_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY OperatorID)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Operator
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY OperatorID, Specimen_Status
ORDER BY OperatorID, Percent_Within_Operator DESC;


/* Instrument */
SELECT
    InstrumentID,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY InstrumentID) AS Instrument_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY InstrumentID)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Instrument
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY InstrumentID, Specimen_Status
ORDER BY InstrumentID, Percent_Within_Instrument DESC;


/* Reagent kit lot */
SELECT
    ReagentKitLot,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY ReagentKitLot) AS Lot_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY ReagentKitLot)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Lot
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY ReagentKitLot, Specimen_Status
ORDER BY ReagentKitLot, Percent_Within_Lot DESC;


/* Ambient temperature */
SELECT
    Specimen_Status,
    ROUND(AVG(AmbientTemp_C), 2) AS Mean_Temp,
    ROUND(MIN(AmbientTemp_C), 2) AS Min_Temp,
    ROUND(MAX(AmbientTemp_C), 2) AS Max_Temp,
    COUNT(*) AS Specimen_Count
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY Specimen_Status;


/* Incubation time */
SELECT
    IncubationTime_min,
    Specimen_Status,
    COUNT(*) AS Specimen_Count,
    SUM(COUNT(*)) OVER (PARTITION BY IncubationTime_min) AS Incubation_Total,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY IncubationTime_min)
        AS DECIMAL(5,2)
    ) AS Percent_Within_Incubation
FROM dbo.vw_Final_Specimen_Metadata
WHERE Specimen_Status <> 'PLATE QC FAILED'
GROUP BY IncubationTime_min, Specimen_Status
ORDER BY IncubationTime_min, Percent_Within_Incubation DESC;


/* Run-level plate QC summary by operator, instrument and reagent lot */
WITH RunLevel AS
(
    SELECT DISTINCT
        RunID,
        PlateID,
        Plate_QC_Status,
        OperatorID,
        InstrumentID,
        ReagentKitLot
    FROM dbo.vw_Final_Specimen_Metadata
)

SELECT
    'Operator' AS Factor,
    OperatorID AS Factor_Level,
    COUNT(*) AS Total_Runs,
    SUM(CASE WHEN Plate_QC_Status = 'FAIL' THEN 1 ELSE 0 END) AS Failed_Runs
FROM RunLevel
GROUP BY OperatorID

UNION ALL

SELECT
    'Instrument',
    InstrumentID,
    COUNT(*),
    SUM(CASE WHEN Plate_QC_Status = 'FAIL' THEN 1 ELSE 0 END)
FROM RunLevel
GROUP BY InstrumentID

UNION ALL

SELECT
    'Reagent Lot',
    ReagentKitLot,
    COUNT(*),
    SUM(CASE WHEN Plate_QC_Status = 'FAIL' THEN 1 ELSE 0 END)
FROM RunLevel
GROUP BY ReagentKitLot;
