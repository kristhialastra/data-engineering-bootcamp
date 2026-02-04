#!/bin/bash
# Netflix Raw Data Ingestion Script
# Purpose: Copy yung raw CSV from project files to my working directory

echo "🚀 Starting to copy Netflix data..."

SOURCE_FILE="/mnt/project/netflix.csv"  # Dito naka-store yung original file
DESTINATION_DIR="data/raw"              # Dito ko siya ililipat

# Gawa muna ng folder kung wala pa
mkdir -p "$DESTINATION_DIR"

# Copy the file
cp "$SOURCE_FILE" "$DESTINATION_DIR/netflix_raw.csv"

# Check kung successful yung copy
if [ $? -eq 0 ]; then
    echo "✅ Success! File copied to $DESTINATION_DIR/netflix_raw.csv"
    echo "📊 File size: $(du -h "$DESTINATION_DIR/netflix_raw.csv" | cut -f1)"
else
    echo "❌ Error! File copy failed"
    exit 1  # Exit with error code para alam ko may problem
fi

echo "🎉 Raw data ingestion complete!"
