#!/bin/bash

output_file="$1"
shift
field_ids=("$@")

# Print header to the output file if it doesn't exist
if [ ! -f "$output_file" ]; then
    echo "filepath,param,eid,field_id,ins" > "$output_file"
    echo "creating $output_file"
fi

for field_id in "${field_ids[@]}"; do
    echo "extracting metadata for ${field_id}"
    
    # Capture the first line of output with timeout for reading
    first_line=$( dx find data --property field_id="$field_id" 2>/dev/null | head -n 1)

    if [[ "$first_line" == *"Bulk"* ]]; then
     # 'Bulk' found in the filepath, process this field_id
     dx find data --property field_id="$field_id" 2>/dev/null | awk -F'/' '
     { # Find the index of "/Bulk/"
       start_index = index($0, "/Bulk/")
       # Find the index of ".zip"
       end_index = index($0, ".zip") + 4
       # Extract filepath starting from "/Bulk/" up to ".zip"
       filepath = substr($0, start_index, end_index - start_index)
       split($6, a, "_")
       param = $4
       eid = a[1]
       field_id = a[2]
       ins = a[3]
       print filepath "," param "," eid "," field_id "," ins
     }
     ' >> "$output_file"
    else
        # 'Bulk' not found in the filepath
        echo "Field ID $field_id is not a bulk field."
    fi
done
exit 0
