#!/usr/bin/env python3
"""
Netflix Data Pipeline - Load to PostgreSQL
Purpose: Simple lang - load yung cleaned CSV from PySpark tapos save to database
Author: Kristhia
"""

import pandas as pd
from sqlalchemy import create_engine

print("="*70)
print("🎬 NETFLIX DATA PIPELINE - LOADING TO DATABASE")
print("="*70)
print()

# ============================================
# STEP 1: Load Cleaned Data from PySpark
# ============================================
print("📥 Loading cleaned Netflix data...")
df = pd.read_csv(
    "data/cleaned/netflix_cleaned_final.csv",
    encoding='utf-8',           # Para ma-handle yung special characters
    on_bad_lines='skip',        # Skip lang if may problematic rows
    engine='python'             # Use Python engine for better handling
)

print(f"✅ Loaded {len(df):,} rows")
print()

# ============================================
# STEP 2: Connect to PostgreSQL Database
# ============================================
print("🗄️ Connecting to PostgreSQL...")

# Connection details (from docker-compose.yml)
# IMPORTANT: Use 'postgres-lab' as host kasi we're INSIDE the Docker network
# Port 5432 (internal), not 5433 (external)
connection_string = "postgresql://airflow:airflow@postgres-lab:5432/airflow"
engine = create_engine(connection_string)

print("✅ Connected!")
print()

# ============================================
# STEP 3: Save to Database Table
# ============================================
print("📤 Saving to database table: netflix_cleaned...")

# to_sql() - super convenient method to save DataFrame to database
df.to_sql(
    'netflix_cleaned',          # Table name
    engine,                     # Database connection
    if_exists='replace',        # Replace table if it exists
    index=False,                # Don't save DataFrame index as column
    method='multi',             # Insert multiple rows at once (faster)
    chunksize=1000             # Insert 1000 rows at a time
)

print(f"✅ Saved {len(df):,} rows to database")
print()

# ============================================
# STEP 4: Verify Data in Database
# ============================================
print("🔍 Verifying...")

# Quick query to check if data was saved properly
check = pd.read_sql("SELECT COUNT(*) as total FROM netflix_cleaned", engine)
print(f"✅ Database has {check['total'][0]:,} rows")
print()

print("="*70)
print("🎉 COMPLETE! Ready for SQL analysis!")
print("="*70)
