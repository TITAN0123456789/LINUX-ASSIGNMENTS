#!/bin/bash

# -----------------------------
# File Analyzer Script
# -----------------------------

ERROR_LOG="errors.log"

# Function to log errors
log_error() {
    echo "[$(date)] ERROR: $1" | tee -a "$ERROR_LOG"
}

# -----------------------------
# Help Menu (Here Document)
# -----------------------------
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search
  -f <file>        File to search directly
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}

# -----------------------------
# Recursive Function
# -----------------------------
search_recursive() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            search_recursive "$item" "$keyword"
        elif [ -f "$item" ]; then
            if grep -q "$keyword" "$item"; then
                echo "Keyword found in: $item"
            fi
        fi
    done
}

# -----------------------------
# Special Parameter Usage
# -----------------------------
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [ "$#" -eq 0 ]; then
    log_error "No arguments provided. Use --help for usage."
    exit 1
fi

# -----------------------------
# getopts Handling
# -----------------------------
while getopts ":d:k:f:" opt; do
    case $opt in
        d) DIRECTORY="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        \?) log_error "Invalid option: -$OPTARG"
            exit 1 ;;
    esac
done

# -----------------------------
# Regular Expression Validation
# -----------------------------

# Validate keyword (non-empty and alphanumeric)
if [[ -n "$KEYWORD" && ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
    log_error "Invalid keyword format."
    exit 1
fi

# Directory search
if [[ -n "$DIRECTORY" ]]; then
    if [[ ! -d "$DIRECTORY" ]]; then
        log_error "Directory does not exist: $DIRECTORY"
        exit 1
    fi

    if [[ -z "$KEYWORD" ]]; then
        log_error "Keyword cannot be empty."
        exit 1
    fi

    echo "Searching recursively in directory: $DIRECTORY"
    search_recursive "$DIRECTORY" "$KEYWORD"
    echo "Exit Status: $?"
fi

# File search using Here String
if [[ -n "$FILE" ]]; then
    if [[ ! -f "$FILE" ]]; then
        log_error "File does not exist: $FILE"
        exit 1
    fi

    if [[ -z "$KEYWORD" ]]; then
        log_error "Keyword cannot be empty."
        exit 1
    fi

    echo "Searching in file: $FILE"

    while read -r line; do
        if grep -q "$KEYWORD" <<< "$line"; then
            echo "Match found: $line"
        fi
    done < "$FILE"

    echo "Exit Status: $?"
fi

echo "Script Name: $0"
echo "Total Arguments: $#"
echo "All Arguments: $@"

