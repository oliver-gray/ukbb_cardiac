#!/bin/bash

# Function: extract_eids
# Description:
# On the RAP imaging data can be found within the bulk folder within a dispensed project. 
# Each image type/sequence per paricipant is in a zip file  with naming convention *{eid}_{field_id}_{instance_0}.zip*. 
# This function checks the field id is a bulk imaging field and if it is searches and gathers all file paths for a specified field id and extracts specific parameters. 
# The results are written to an output file in csv format.
#
# Parameters:
#   $1 - output_file: The file where the results will be saved.
#   $@ - field_ids: An array of field IDs to search and process. These field_ids should be bulk imaging fields.
#
# Usage:
#   extract_eids "output.csv" 20204 20254

extract_eids(){
 local output_file="$1"
 shift
 local field_ids=("$@")

 # Print header to the output file if it doesn't exist
 if [ ! -f "$output_file" ]; then
   echo "filepath,param,eid,field_id,ins" > "$output_file"
 fi

 for field_id in "${field_ids[@]}"; do
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
}

export -f extract_eids