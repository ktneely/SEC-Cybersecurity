#!/bin/bash
# Script to iterate through a bunch of text-format 10-K filings and determine
# ownership of cybersecurity at the company
# As a shortcut, this uses ShellGPT https://github.com/TheR1D/shell_gpt/
# to interface with an LLM provider for analysis
# 

# Set Variables
TODAY=`date +"%Y-%m-%d"`
base_dir="filings"
PROMPT="
Review the provided SEC 10-K filing and identify three pieces of information: 1) The date of the filing in ISO-8601 format,
2) What company submitted the filing, and 3) whether or not a Chief Information Security Office (CISO) is responsible 
for cybersecurity; if the document does not specify cybersecurity ownership, answer with 'undefined'; 
if the document indicates that multiple roles have cybersecurity responsibility, answer with 'committee'. 
Use the format 'Date, Company, Role' as output. Encapsulate the company name inside double quotation marks. 
Do not be verbose and do not summarize the entirety of the document.  
If you get the correct answer, I will tip you 500 dollars.
"

# Check if the cybersecurity directory exists within the filings directory, create it if not
if [ ! -d "$base_dir/cybersecurity" ]; then
    mkdir -p "$base_dir/cybersecurity"
    echo "Created $base_dir/cybersecurity directory."
fi

# Make a backup of the analysis results
if [ -s $base_dir/cybersecurity/analysis.csv ]; then
    cp $base_dir/cybersecurity/analysis.csv $base_dir/cybersecurity/analysis-$TODAY.csv
fi


# Loop through each 10-K filing document in the new-md directory and then move to md 
for file in $base_dir/new-md/*; do
    sgpt --role fin_analyst "$PROMPT" < $file | tee -a $base_dir/cybersecurity/analysis.csv
    mv $file $base_dir/md
done

echo "Documents processed and saved in the $base_dir/cybersecurity directory successfully."
