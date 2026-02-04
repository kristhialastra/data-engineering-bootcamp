# Netflix Data Pipeline Mini Project

## Overview
End-to-end data pipeline for Netflix content analysis using Docker, PySpark, pandas, and PostgreSQL.

## Pipeline Architecture
<img width="2604" height="863" alt="image" src="https://github.com/user-attachments/assets/9bd93ea5-6c2a-401a-91a7-daee98c526c1" />


## Pipeline Stages
1. **Ingest**: Copy raw CSV data (`copy_raw_data.sh`)
2. **Clean**: PySpark data transformation (`pyspark_clean.py`)
3. **Extract**: Manual CSV extraction from PySpark output folder
4. **Load**: Load cleaned data to PostgreSQL (`pandas_analysis.py`)
5. **Analyze**: SQL business queries in DBeaver

## Project Structure
```
4-mini-project/
├── scripts/
│   ├── copy_raw_data.sh      # Data ingestion script
│   ├── pyspark_clean.py       # PySpark cleaning job
│   └── pandas_analysis.py     # Load to PostgreSQL
├── queries/
│   └── netflix_titles_sql_queries.sql  # 30 business questions
├── docs/
│   └── pipeline_documentation.md       # Detailed instructions
├── My_First_Board__3_.jpg    # Pipeline diagram
└── README.md                  # This file
```

## How to Run
See `docs/pipeline_documentation.md` for complete step-by-step instructions.

## Data Flow
```
Raw CSV (5,837 rows)
  ↓
Shell Script (Ingest)
  ↓
data/raw/netflix_raw.csv
  ↓
PySpark (Clean & Transform)
  ↓
data/cleaned/netflix_cleaned.csv/ (folder with part files)
  ↓
Manual Extract (cp command)
  ↓
netflix_cleaned_final.csv (5,186 rows)
  ↓
pandas (Load)
  ↓
PostgreSQL Database (netflix_cleaned table)
  ↓
DBeaver (SQL Analysis - 30 business queries)
```
