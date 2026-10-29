# Data

This folder contains the synthetic datasets used in the **ELISA Analytics & Decision-Support Workflow** portfolio project.

## Source Data

The source folder contains five datasets representing the starting laboratory data:

-**Run_Metadata.csv** — Run, plate, operator, instrument, reagent lot and experimental-condition metadata.

-**Plate_Controls.csv**— Blank, negative, low-positive and positive control measurements.

-**Calibrators.csv** — Calibration standards and replicate OD450 measurements.

-**Sample_Wells.csv** — Specimen-level replicate OD450 measurements and plate/well information.

-**Specimen_Master.csv** — Specimen and associated collection metadata.

## Processed Data

'Final_Specimen_Metadata.csv' is the integrated analysis-ready dataset produced by connecting specimen, assay, QC and run metadata through the SQL analytical workflow.

It is subsequently used for exploratory/statistical analysis and Power BI reporting.

## Data Note

All data in this repository are **synthetic and created for portfolio demonstration purposes**. They do not contain patient, clinical, proprietary or confidential laboratory information.