#!/bin/bash

INPUT_FILE="input.txt"
OUTPUT_FILE="output.txt"

# Clear output file before writing
> "$OUTPUT_FILE"

# Variables to store values
frame_time=""
wlan_type=""
wlan_subtype=""

while IFS= read -r line
do
    # Extract frame.time
    if [[ "$line" == *"frame.time"* ]]; then
        frame_time=$(echo "$line" | awk -F': ' '{print $2}')
    fi

    # Extract wlan.fc.type
    if [[ "$line" == *"wlan.fc.type"* ]]; then
        wlan_type=$(echo "$line" | awk -F': ' '{print $2}')
    fi

    # Extract wlan.fc.subtype
    if [[ "$line" == *"wlan.fc.subtype"* ]]; then
        wlan_subtype=$(echo "$line" | awk -F': ' '{print $2}')

        # Once all three are captured, write to output
        {
            echo "\"frame.time\": \"$frame_time\","
            echo "\"wlan.fc.type\": \"$wlan_type\","
            echo "\"wlan.fc.subtype\": \"$wlan_subtype\""
        } >> "$OUTPUT_FILE"

        # Reset variables for next block
        frame_time=""
        wlan_type=""
        wlan_subtype=""
    fi

done < "$INPUT_FILE"

echo "Processing complete. Output saved in $OUTPUT_FILE"

