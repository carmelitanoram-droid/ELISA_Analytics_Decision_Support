# ELISA Analytics & Decision-Support Workflow

**Scientific Analytics | SQL | Python | Power BI | Business Analysis**

A portfolio project demonstrating how multi-plate ELISA data can be transformed into a traceable analytical workflow for assay assessment, investigation of performance factors, statistical evaluation, and scientific decision support.

The project combines **scientific domain knowledge with SQL, Python, statistics and Power BI**, while separating predefined assay/QC requirements from analyst-derived observations.

---

## Project at a Glance

**8 ELISA runs/plates | 192 specimen test events | SQL data integration & QC | 4PL modelling | Statistical investigation | Power BI**

### Analytical workflow

**Connect data & metadata → Establish assay validity → Assess specimen results → Investigate performance factors → Evaluate statistical evidence → Support decisions**

---

## Dashboard Preview

![ELISA Analytics & Decision-Support Dashboard](images/elisa_dashboard.png)

The Power BI dashboard provides an interactive view of specimen outcomes, plate validity and potential performance factors such as receipt delay, reagent lot, operator, instrument, matrix and collection site.

The dashboard serves as the **monitoring and communication layer**; QC logic, data integration and statistical evaluation are performed upstream using SQL and Python.

**Power BI file:** [`powerbi/ELISA_Analytics_Dashboard.pbix`](powerbi/ELISA_Analytics_Dashboard.pbix)

---

## Why This Project?

ELISA experiments can generate results across multiple plates, specimens, calibrators, controls, operators, instruments and reagent lots. Reliable interpretation therefore requires more than calculating individual assay metrics.

This project addresses four practical needs:

- maintaining traceability between assay results and experimental metadata;
- establishing assay/plate validity before interpreting specimen results;
- distinguishing descriptive performance signals from statistically supported evidence;
- presenting complex laboratory data in an intuitive format for scientific and operational review.

The dataset is synthetic and represents a **research-use analytical scenario rather than a clinical diagnostic validation study**.

---

## Solution Workflow

### 1. Connect — Data Traceability

Five source datasets were integrated:

- run metadata;
- plate controls;
- calibrators;
- specimen wells;
- specimen metadata.

SQL integrity checks verify key relationships and preserve traceability from specimen result to plate, run and experimental metadata.

### 2. Validate — Assay and Specimen Assessment

Predefined project QC rules were applied to:

- blanks and plate controls;
- calibrator replicate precision and monotonicity;
- specimen replicate CV;
- overall plate validity.

A critical decision rule was implemented:

> **Plate validity overrides specimen-level precision.**

A specimen cannot be considered analytically acceptable when the plate itself fails predefined validity requirements.

### 3. Analyse — Performance Factors

For QC-valid plates, specimen outcomes were investigated against factors including:

- specimen matrix;
- collection site;
- receipt delay;
- reference status;
- reagent kit lot;
- operator;
- instrument;
- incubation time.

This identified descriptive patterns requiring further evaluation rather than automatically treating them as root causes.

### 4. Test Evidence — Python & Statistics

Python was used for:

- 4-parameter logistic (4PL) calibration-curve fitting;
- R² and RMSE assessment;
- Mann–Whitney U tests;
- Kruskal–Wallis testing;
- chi-square tests;
- Fisher's exact test;
- exploratory plate-position analysis.

Statistical testing was used to distinguish **signals worth monitoring from evidence strong enough to support an association**.

### 5. Support Decisions — Power BI

The final analysis-ready dataset was used to build an interactive dashboard for:

- specimen QC monitoring;
- plate-status review;
- performance-factor exploration;
- filtering by relevant experimental metadata;
- rapid identification of specimens requiring review or investigation.

---

## Key Findings

- **2 of 8 plates failed** predefined plate-level QC requirements.
- Plate-level failure was propagated to affected specimen results rather than allowing apparently precise specimen replicates to override invalid plate status.
- Among **144 specimens from valid plates**, 126 (87.5%) passed, 7 (4.9%) required review and 11 (7.6%) failed specimen replicate QC.
- 4PL calibration models showed strong curve fit across all eight plates, with **R² > 0.9993** and RMSE approximately **0.004–0.021**.
- Descriptive differences were observed across factors such as receipt delay, reagent lot, site and operator.
- Statistical testing did **not provide sufficient evidence for strong associations** for the selected factors in this small synthetic dataset.
- Exploratory plate-position analysis was performed, but the experimental layout was not designed as a formal edge-effect study; therefore no edge-effect conclusion was made.

The overall analytical lesson is that **descriptive differences should trigger investigation, not automatically become causal conclusions**.

---

## Tools and Their Role

| Tool | Role in the Workflow |
|---|---|
| **SQL / SSMS** | Data integrity checks, joins, QC rules, plate validity, specimen status and analysis-ready dataset |
| **Python / pandas** | Data manipulation and exploratory analysis |
| **SciPy** | 4PL curve fitting and statistical hypothesis testing |
| **Matplotlib** | Calibration and plate-position exploration |
| **Power BI** | Interactive monitoring and communication of analytical results |
| **Business Analysis** | Requirements interpretation, traceability, decision rules and translation of scientific findings into stakeholder-relevant information |

---

## What This Project Demonstrates

**Scientific analytics:** translating ELISA experimental design and assay requirements into an analytical workflow.

**Data analytics:** integrating multiple datasets, applying rule-based logic, modelling calibration curves and statistically evaluating performance factors.

**Business analysis:** converting scientific requirements into traceable data rules and separating predefined requirements from analyst-derived findings.

**Product thinking:** organizing the workflow around user decisions — what is valid, what requires review, what warrants investigation and what information needs to be visible for monitoring.

---

## Repository Structure

```text
elisa-analytics-decision-support/
│
├── README.md
│
├── data/
│   ├── source/
│   │   ├── Run_Metadata.csv
│   │   ├── Plate_Controls.csv
│   │   ├── Calibrators.csv
│   │   ├── Sample_Wells.csv
│   │   └── Specimen_Master.csv
│   ├── processed/
│   │   └── Final_Specimen_Metadata.csv
│   └── README.md
│
├── sql/
│   ├── 01_data_integrity_traceability.sql
│   ├── 02_plate_qc.sql
│   ├── 03_specimen_qc.sql
│   ├── 04_final_analytical_dataset.sql
│   └── 05_performance_factor_analysis.sql
│
├── python/
│   └── ELISA_Statistical_Analysis.ipynb
│
├── powerbi/
│   └── ELISA_Analytics_Dashboard.pbix
│
├── images/
│   └── elisa_dashboard.png
│
└── report/
    └── ELISA_Analytics_Decision_Support_Report.pdf
```

---

## Explore the Project

For a quick review:

1. **Start with the dashboard** above to understand the final decision-support output.
2. Review [`sql/`](sql/) to see data traceability, QC logic and analytical dataset construction.
3. Open [`python/ELISA_Statistical_Analysis.ipynb`](python/ELISA_Statistical_Analysis.ipynb) for 4PL modelling and statistical evidence assessment.
4. Read the [`report/ELISA_Analytics_Decision_Support_Report.pdf`](report/ELISA_Analytics_Decision_Support_Report.pdf) for the complete case study and scientific/business reasoning.

---

## Scope and Limitations

This project uses a **synthetic RUO-style dataset** created for portfolio demonstration.

The analysis is intended to demonstrate analytical workflow design and decision support rather than assay validation or clinical diagnostic performance. The limited number of runs and intentionally structured dataset also restrict statistical power and causal inference.

Observed differences are therefore treated as **investigation signals requiring confirmation in larger study cohorts or repeated sampling**.

---

## Detailed Case Study

For ELISA background, project requirements, analytical methodology, interpretation and future improvements, see:

**[ELISA Analytics & Decision-Support Report](report/ELISA_Analytics_Decision_Support_Report.pdf)**

---

## Repository Purpose

This portfolio project demonstrates the transition from **laboratory-generated data to structured scientific evidence and decision support** by combining wet-lab domain expertise with data analytics, statistical reasoning and business-analysis principles.
