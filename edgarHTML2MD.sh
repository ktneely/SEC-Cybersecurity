#!/bin/bash

# simply converts all html files in the filings/html directory
# to simplified Markdown files in the filings/md directory
# Works on the massively over-formatted EDGAR docs from the SEC
# but should work on other HTML files, as well


base_dir="filings"

# Function to truncate a 10-K filings after the last occurrence of the Item 2: Properties section
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



## Check for and create the necessary directories
 Check if the new-md directory exists within the filings directory, create it if not
if [ ! -d "$base_dir/new-md" ]; then
    mkdir -p "$base_dir/new-md"
    echo "Created $base_dir/new-md directory."
fi


## TODO::  place the conversions in a directory called something like "New Filings"
##         instead of the generic directory so we can process only new information
# This converts the HTML to Markdown and drops the first 4 lines
for file in filings/html/*
do
    #    filename=`echo "${file% .*}"`
    filename=$(basename "$file" .html)
    if [ ! -s $base_dir/new-md/$filename.md ]; then
        echo "Now converting $filename ..."
	pandoc -f html -t markdown_github-raw_html $file |tail -n +4 > $base_dir/new-md/$filename.md
    fi
done



# Remove everything from Item 2 onwards from the 10-K filing
# This will reduce the token usage against the LLM
for file in $base_dir/new-md/*
do
    if [ -f "$file" ]; then
        truncate_file "$file"
    fi
done

echo "Processing complete."
