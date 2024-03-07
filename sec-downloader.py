#!/usr/bin/env python3

# REQUIREMENTS
# sec-downloader  (will also pull in sec-edgar-downloader)
#
# Saves trhe downloaded HTML forms to a './filings' directory, relative to execution

# from sec_edgar_downloader import Downloader # original
from sec_downloader import Downloader  
from sec_downloader.types import RequestedFilings
import sys
import os

if len(sys.argv) != 2:
    raise ValueError("Specify the ticker list on the command line. Example: sec-downloader.py tickers.txt")
data_file = sys.argv[1]

# Initialize a downloader instance. Download filings to the current
# working directory. Must declare company name and email address
# to form a user-agent string that complies with the SEC Edgar's
# programmatic downloading fair access policy.
# More info: https://www.sec.gov/os/webmaster-faq#code-support
# Company name and email are used to form a user-agent of the form:
# User-Agent: <Company Name> <Email Address>
dl = Downloader("Independent Researcher", "id@email.address")


# Download two most recent filings from a given stock ticker symbol
#dl.get("10-K", "F", limit=2)

# Collect the meta data from multiple ticker symbols
# tickers = ["MSFT", "UBER"]

# Variables for data to retrieve from Edgar
form = "10-K"
doc_count = 1
tickers = []
base_dir = 'filings'

# Create the 'tickers' list from the file specified on the command line
try:
    # Open the file in read mode
    with open(data_file, 'r') as file:
        # Read each line from the file and append it to the list
        for line in file:
            tickers.append(line.strip())  # Strip any whitespace characters like newline '\n'
except FileNotFoundError:
    print(f"The file {file} was not found.")
except IOError as e:
    print(f"An error occurred while reading the file: {e}")

file.close

# Create the filings directory if it does not yet exist
# note: this directory is in the .gitignore
if not os.path.exists(base_dir):
    # Create the directory
    os.makedirs(base_dir)
    print(f"Directory '{base_dir}' was created.")
else:
    print(f"Directory '{base_dir}' exists.  Lets go get some SEC filings!")

# Retrieve the data for the specified ticker symbols
for ticker in tickers:
    try:
        metadatas = dl.get_filing_metadatas(
            RequestedFilings(ticker_or_cik=ticker, form_type=form, limit=doc_count)
        )
    except ValueError as ve:
        print(f"No CIK could be mapped to ticker symbol {ticker}")
    for metadata in metadatas:
        html = dl.download_filing(url=metadata.primary_doc_url).decode()
        date = metadata.filing_date
        form = metadata.form_type
    file_path = r"filings/html/" + ticker + "_" + date + "_" + form + ".html"
    file_test = os.path.isfile(file_path)   # test to see if the file already exists
    if file_test:
        print(f"The requested form for {ticker} has already been downloaded")
    else:
        os.path.isfile("filings/html/" + ticker + "_" + date + "_" + form + ".html") == False
        print("retrieving edgar data for " + ticker)
        file = open("filings/html/" + ticker + "_" + date + "_" + form + ".html", "w")
        file.write(html)
        file.close
    
