#!/bin/bash

# simply converts all html files in the filings/html directory
# to simplified Markdown files in the filings/md directory
# Works on the massively over-formatted EDGAR docs from the SEC
# 
# Additionally, it removes all content 


base_dir="filings"

## Check if the new-md directory exists within the filings directory, create it if not
if [ ! -d "$base_dir/new-md" ]; then
    mkdir -p "$base_dir/new-md"
    echo "Created $base_dir/new-md directory."
fi


# Function to extract the Item 1C content from a file
extract_content() {
    local file_path="$1"
    local temp_file="${file_path}.tmp"

    # Use tac and awk to reverse process and capture the content between "Item 1C" and "Item 2"
    tac "$file_path" | awk 'BEGIN{IGNORECASE=1; print_section=0}
    /item.*2/ && print_section == 0 {print_section=1; next}
    /item.*1c/ && print_section == 1 {exit}
    {if(print_section) print}' | tac > "$temp_file"

    # Replace original file with the modified content
    mv "$temp_file" "$file_path"
    echo "Processed $file_path"
}

truncate_file() {
    local file_path="$1"
    # Use awk to find the last line matching the pattern and truncate the file after that line
    awk 'BEGIN{IGNORECASE=1} /item.*2.*properties/ {line=NR} END{if(line) print line}' "$file_path" | (
    while read -r line; do
        if [ -n "$line" ]; then
            # Truncate the file after the last matching line
            head -n "$line" "$file_path" > "${file_path}.tmp" && mv "${file_path}.tmp" "$file_path"
            echo "Truncated $file_path"
        fi
    done
    )
}


# This converts the HTML to Markdown and drops the first 4 lines
for file in filings/html/*2024*
do
    #    filename=`echo "${file% .*}"`
    filename=$(basename "$file" .html)
    if [ ! -s $base_dir/new-md/$filename.md ]; then
        echo "Now converting $filename ..."
	pandoc -f html -t markdown_github-raw_html $file |tail -n +4 > $base_dir/new-md/$filename.md
    fi
done


# Process the file reduction steps
for file in $base_dir/new-md/*
do
    if [ -f "$file" ]; then
        extract_content "$file"
        truncate_file "$file"
    fi
done

echo "Processing complete."
