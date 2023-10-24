
from lxml import etree
from zipfile import ZipFile
import os
import requests
from argparse import ArgumentParser

def analysis_entry():
    parser = ArgumentParser(description="Process a collection or individual zip file")

    parser.add_argument('path')
    parser.add_argument('target_word')
    parser.add_argument('--parallel', action='store_true')

    arguments = parser.parse_args()

    # if the path is to a folder, then extract the names of the zip files in it, analyse each, and combine the results
    if os.path.isdir(arguments.path):
        results = analyse_collection(arguments.path, arguments.target_word, arguments.parallel)
    else: 
        results = analyse_file(arguments.target_word, arguments.path)

    print(results)

def analyse_file(target_word, source):
    try:
        with ZipFile(source) as zip:
            index_file = [name for name in zip.namelist() if "metadata" in name][0]
            with zip.open(index_file) as metadata:
                tree=etree.parse(metadata)
                date = tree.find('//{http://www.loc.gov/mods/v3}dateIssued').text
            # for each other file in the ALTO xml
            other_files = [name for name in zip.namelist() if "metadata" not in name and name != "ALTO/"]
            count = 0
            for filename in other_files:
                with zip.open(filename) as file:
                    tree=etree.parse(file)
                    text = tree.findall(f"//String[@CONTENT='{target_word}']")
                    count += len(text)
        return {date: count}
    except AttributeError:
        return {"": 0}

def combine(dict1, dict2):

    for key in dict2:
        if key in dict1:
            dict1[key]+=dict2[key]
        else:
            dict1[key] = dict2[key]

    return dict1

def analyse_collection(source, target_word, parallel=False):

    from functools import reduce, partial
    targets = list(map(partial(os.path.join, source),os.listdir(source)))
    mapper = partial(analyse_file, target_word)
    
    if parallel:
        import mr4mp
        pool = mr4mp.pool(2*os.cpu_count())
        result = pool.mapreduce(mapper, combine, targets)
    else:

        result = reduce(combine,map(mapper, targets),{})
    return result