from bs4 import BeautifulSoup
from zipfile import ZipFile
import os
from argparse import ArgumentParser

def analysis_entry():
    parser = ArgumentParser(description="Process a collection or individual zip file")

    parser.add_argument('path')
    parser.add_argument('target_word')

    arguments = parser.parse_args()

    # if the path is to a folder, then extract the names of the zip files in it, analyse each, and combine the results
    if os.path.isdir(arguments.path):
        results = analyse_collection(arguments.path, arguments.target_word)
    else: 
    # if the path is to a zip file, assume it is a single book and analyse it, printing the results for that book
        results = analyse_file(arguments.path, arguments.target_word)

    print(results)

def analyse_file(source, target_word):
    with ZipFile(source) as zip:
        index_file = [name for name in zip.namelist() if "metadata" in name][0]
        with zip.open(index_file) as metadata:
            soup=BeautifulSoup(metadata, features='xml')
            date = int(soup.find('MODS:dateIssued').text)
        # for each other file in the ALTO xml
        other_files = [name for name in zip.namelist() if "metadata" not in name and name != "ALTO/"]
        count = 0
        for filename in other_files:
            with zip.open(filename) as file:
                soup=BeautifulSoup(file, features='xml')
                text = [string['CONTENT'] for string in soup.find_all("String")]
                selected_text = [result for result in text if result.lower().strip() == target_word.lower()]
                count += len(selected_text)
    return (date, count)

def analyse_collection(source, target_word):
    results = {}
    for file in os.listdir(source):
        year, count = analyse_file(
            os.path.join(source, file), 
            target_word)
        if year in results:
            results[year] += count
        else:
            results[year] = count
    return results