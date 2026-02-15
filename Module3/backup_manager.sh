#!/bin/bash

# ==============================
# Backup Manager Script
# ==============================

# 1. Check if exactly 3 arguments are passed
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"<source_directory>\" \"<backup_directory>\" \"<file_extension>\""
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

# 2. Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# 3. If backup directory does not exist, create it
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || {
        echo "Error: Failed to create backup directory."
        exit 1
    }
fi

# 4. Globbing to collect matching files
FILES=("$SOURCE_DIR"/*"$EXTENSION")

# Check if no files match
if [ ! -e "${FILES[0]}" ]; then
    echo "No files with extension $EXTENSION found in $SOURCE_DIR."
    exit 0
fi

# Initialize counters
TOTAL_SIZE=0
export BACKUP_COUNT=0

echo "Files to be backed up:"
echo "------------------------"

# 5. Loop through files
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        FILE_NAME=$(basename "$FILE")
        FILE_SIZE=$(stat -c%s "$FILE")

        echo "File: $FILE_NAME | Size: $FILE_SIZE bytes"

        DEST_FILE="$BACKUP_DIR/$FILE_NAME"

        # If file exists in backup directory
        if [ -f "$DEST_FILE" ]; then
            # Overwrite only if source is newer
            if [ "$FILE" -nt "$DEST_FILE" ]; then
                cp "$FILE" "$BACKUP_DIR"
                ((BACKUP_COUNT++))
                ((TOTAL_SIZE+=FILE_SIZE))
            fi
        else
            cp "$FILE" "$BACKUP_DIR"
            ((BACKUP_COUNT++))
            ((TOTAL_SIZE+=FILE_SIZE))
        fi
    fi
done

# 6. Generate Report
REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
echo "========== Backup Summary =========="
echo "Total files processed: $BACKUP_COUNT"
echo "Total size backed up: $TOTAL_SIZE bytes"
echo "Backup directory: $BACKUP_DIR"
echo "===================================="
} > "$REPORT_FILE"

echo "Backup completed."
echo "Report saved at: $REPORT_FILE"

