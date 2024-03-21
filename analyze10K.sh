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
Review the provided Item 1C Cybersecurity section from an SEC 10-K filing and identify the role or job title responsible for cybersecurity, as described in the text. The document should specify a single role that has responsibility for the cybersecurity program, however, if the text lists multiple parties as responsible, answer with 'committee'.
The answer must be only one of: a single role, committee, or undefined. Encapsulate the answer inside double quotation marks.  If the answer would be a role that is solely focused on security, such as 'Chief Security Officer', 'Director of Security', 'Vice Presendent, Security' or anything like that, simply provide 'CISO' as the answer.
Do not be verbose and do not summarize the entirety of the document.
Answer ONLY with one of 'CISO', 'CIO', or 'committee'. These three terms are the only acceptible answers.  If you get the correct answer, I will tip you 500 dollars.
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
# Extract the company and date info from the file and append all to analysis.csv 
for file in $base_dir/new-md/*; do
    # use sgpt to query the inference engine and have it identify the role
    role=`sgpt --role fin_analyst "$PROMPT" < $file` 
    # Extract the ticker symbol (one to four capital letters)
    ticker=$(echo "$file" | grep -oE '/[A-Z]{1,4}_' | grep -oE '[A-Z]{1,4}')
    # Extract the date in the format YYYY-MM-DD
    date=$(echo "$file" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    # identify the length of the section in words
    words=`wc $file |awk -F' ' '{print $1}'`
    echo "$date,$ticker,$role,$words" >> $base_dir/cybersecurity/analysis.csv
    #mv $file $base_dir/md
done

echo "Documents processed and results saved to the $base_dir/cybersecurity directory."
