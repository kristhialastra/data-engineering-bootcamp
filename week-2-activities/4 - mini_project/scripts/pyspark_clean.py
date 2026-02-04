#!/usr/bin/env python3
"""
PySpark Cleaning Job for Netflix Data
Purpose: Clean raw CSV, handle missing values, extract features
Author: Kristhia - Netflix Content Team
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, when, trim, to_date, try_to_date, year, month,
    split, size, lower
)

# ============================================
# STEP 1: Initialize Spark Session
# ============================================
print("🔥 Initializing Spark...")

spark = SparkSession.builder \
    .appName("Netflix Data Cleaning") \
    .master("local[*]") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")  # Para di masyadong madaming logs
print("✅ Spark session created successfully!\n")

# ============================================
# STEP 2: Load Raw Data
# ============================================
print("📥 Loading raw Netflix data...")

# Load yung CSV na ni-copy ko kanina
df_raw = spark.read.csv(
    "/app/data/raw/netflix_raw.csv",
    header=True,           # First row is column names
    inferSchema=True,      # Auto-detect data types
    multiline=True,        # IMPORTANT: Handles fields na may line breaks (lowercase 'l'!)
    escape='"'             # Handles escaped quotes sa data
)

print(f"✅ Loaded {df_raw.count()} rows with {len(df_raw.columns)} columns\n")
print("📊 Original Schema:")
df_raw.printSchema()

# ============================================
# STEP 3: Data Cleaning - Handle Missing Values
# ============================================
print("\n🧹 Starting data cleaning...")

# Fill missing values with "Unknown" para may placeholder
# Trim din para walang extra spaces
df_cleaned = df_raw \
    .withColumn("director", 
                when(col("director").isNull(), "Unknown")
                .otherwise(trim(col("director")))) \
    .withColumn("cast",
                when(col("cast").isNull(), "Unknown")
                .otherwise(trim(col("cast")))) \
    .withColumn("country",
                when(col("country").isNull(), "Unknown")
                .otherwise(trim(col("country"))))

# Drop rows na walang date_added or rating kasi kailangan ko sila sa analysis
df_cleaned = df_cleaned.filter(
    col("date_added").isNotNull() & 
    col("rating").isNotNull()
)

# Trim lahat ng text columns para consistent
df_cleaned = df_cleaned \
    .withColumn("title", trim(col("title"))) \
    .withColumn("type", trim(col("type"))) \
    .withColumn("description", trim(col("description")))

print(f"✅ After cleaning: {df_cleaned.count()} rows remain\n")

# ============================================
# STEP 4: Add Calculated Columns
# ============================================
print("⚙️ Adding calculated columns...")

# Convert date_added to proper date format
# Use try_to_date para di mag-crash if may invalid dates (like "Shakira Barrera" lol)
df_transformed = df_cleaned.withColumn(
    "date_added_clean",
    try_to_date(trim(col("date_added")), "MMMM d, yyyy")  # Format: "January 1, 2020"
)

# Extract year and month from the date para madaling i-analyze later
df_transformed = df_transformed \
    .withColumn("year_added", year(col("date_added_clean"))) \
    .withColumn("month_added", month(col("date_added_clean")))

# Count how many genres (split by comma)
# Example: "Comedies, Dramas, International" = 3 genres
df_transformed = df_transformed.withColumn(
    "genre_count",
    size(split(col("listed_in"), ","))
)

# Count cast size (how many actors)
# If "Unknown", set to 0. Otherwise, count commas + 1
df_transformed = df_transformed.withColumn(
    "cast_size",
    when(col("cast") == "Unknown", 0)
    .otherwise(size(split(col("cast"), ",")) + 1)
)

# Standardize type column to uppercase for consistency
df_transformed = df_transformed.withColumn(
    "type",
    when(lower(col("type")) == "movie", "MOVIE")
    .when(lower(col("type")) == "tv show", "TV SHOW")
    .otherwise(col("type"))
)

print("✅ Transformations complete!\n")

# ============================================
# STEP 5: Preview the Results
# ============================================
print("👀 Sample of cleaned data:")
df_transformed.select(
    "title", "type", "country", "year_added",
    "month_added", "genre_count", "cast_size"
).show(10, truncate=False)

# ============================================
# STEP 6: Save Cleaned Data
# ============================================
print("\n💾 Saving cleaned data...")

output_path = "/app/data/cleaned/netflix_cleaned.csv"

# Coalesce(1) para single file lang ang output, hindi multiple part files
df_transformed.coalesce(1).write.mode("overwrite").csv(
    output_path,
    header=True
)

print(f"✅ Cleaned data saved to {output_path}\n")

# ============================================
# STEP 7: Summary Statistics
# ============================================
print("📈 Data Quality Report:")
print(f"   Total rows processed: {df_transformed.count()}")
print(f"   Rows dropped due to missing data: {df_raw.count() - df_transformed.count()}")
print(f"\n   Breakdown by Type:")

df_transformed.groupBy("type").count().show()

print("\n🎉 PySpark job completed successfully!")

spark.stop()
