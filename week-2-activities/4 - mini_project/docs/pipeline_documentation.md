# Netflix Data Pipeline Documentation

## Overview
This document provides complete step-by-step instructions for running the Netflix data pipeline, from raw data ingestion through SQL analysis.

---

## 🚀 PART 1: Daily Startup Routine

Every time I restart my laptop, I do these steps:

### Step 1.1: Start Docker Desktop
1. Open Docker Desktop from Windows Start menu
2. Wait until it says "Docker Desktop is running"
3. Check system tray - whale icon should be still (not animated)

### Step 1.2: Open Ubuntu Terminal
1. Press Windows key
2. Type "Ubuntu" 
3. Click the Ubuntu app

### Step 1.3: Navigate to Project Directory
```bash
cd /mnt/c/Users/i_kristhiacayle.last/Documents/data-engineering-bootcamp
```

### Step 1.4: Start All Containers
```bash
docker compose up -d
```
*Wait 30-60 seconds for containers to start*

### Step 1.5: Verify Containers are Running
```bash
docker ps
```
*I should see 4 containers: postgres-lab, airflow-webserver-lab, airflow-scheduler-lab, python-lab*

---

## 📂 PART 2: Project Structure

### Directory Structure:
```
.
├── data/
│   ├── raw/              # Original Netflix CSV
│   ├── cleaned/          # PySpark cleaned output
│   └── processed/        # (Future use)
├── scripts/
│   ├── copy_raw_data.sh
│   ├── pyspark_clean.py
│   └── pandas_analysis.py
```

---

## 📜 PART 3: Pipeline Execution

### Step 3.1: Run Data Ingestion
```bash
chmod +x scripts/copy_raw_data.sh
./scripts/copy_raw_data.sh
```

**Expected Output:**
```
🚀 Starting to copy Netflix data...
✅ Success! File copied to data/raw/netflix_raw.csv
📊 File size: 1.2M
🎉 Raw data ingestion complete!
```

### Step 3.2: Run PySpark Cleaning
```bash
docker exec -it python-lab python3 /app/scripts/pyspark_clean.py
```

**Expected Output:**
```
🔥 Initializing Spark...
✅ Spark session created successfully!
📥 Loading raw Netflix data...
✅ Loaded 5837 rows with 12 columns
🧹 Starting data cleaning...
✅ After cleaning: 5186 rows remain
⚙️ Adding calculated columns...
✅ Transformations complete!
💾 Saving cleaned data...
✅ Cleaned data saved to /app/data/cleaned/netflix_cleaned.csv
🎉 PySpark job completed successfully!
```

### Step 3.3: Extract Cleaned CSV
```bash
cp data/cleaned/netflix_cleaned.csv/part-*.csv data/cleaned/netflix_cleaned_final.csv
```

### Step 3.4: Load to PostgreSQL
```bash
docker exec -it python-lab python3 /app/scripts/pandas_analysis.py
```

**Expected Output:**
```
======================================================================
🎬 NETFLIX DATA PIPELINE - LOADING TO DATABASE
======================================================================
📥 Loading cleaned Netflix data...
✅ Loaded 5,186 rows
🗄️ Connecting to PostgreSQL...
✅ Connected!
📤 Saving to database table: netflix_cleaned...
✅ Saved 5,186 rows to database
🔍 Verifying...
✅ Database has 5,186 rows
======================================================================
🎉 COMPLETE! Ready for SQL analysis!
======================================================================
```

---

## 📊 PART 4: SQL Analysis in DBeaver

After running the pipeline:
1. Open DBeaver
2. Navigate to: airflow connection → Databases → airflow → Schemas → public → Tables → netflix_cleaned
3. Create new SQL script
4. Run business queries

---

## 🔧 Troubleshooting

### Issue: Containers not starting
**Solution:** Restart Docker Desktop, wait 2 minutes, try `docker compose up -d` again

### Issue: Permission denied on shell script
**Solution:** Run `chmod +x scripts/copy_raw_data.sh`

### Issue: PySpark can't find file
**Solution:** Verify file exists with `ls data/raw/netflix_raw.csv`

### Issue: pandas can't connect to database
**Solution:** Check containers are running with `docker ps`
