#!/bin/bash

# Check if the file_paths.txt argument is provided and exists
if [[ -z "$1" || ! -f "$1" ]]; then
  echo "Error: imaging.csv is not provided."
  return 1
fi

# Get the project ID
local PR
PR=$(dx env | grep project- | cut -f 2)

# Check if the project ID was successfully retrieved
if [[ -z "$PR" ]]; then
  echo "Error: Could not retrieve project ID."
  return 1
fi

# Construct and execute the dx download commands for each line in the file_paths.txt
local file_paths_file=$1
while IFS= read -r file_path; do
  local command="dx download --lightweight ${PR}:\"${file_path}\""
  eval "$command"
done < "$file_paths_file"