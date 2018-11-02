let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! GetHelp()
    python << EOF
import sys
import vim
import requests
import time
import re
import json
from os.path import normpath, join
from bs4 import BeautifulSoup

plugin_root_dir = vim.eval('s:plugin_root_dir')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)

#######################################################################
#                           GET HELP PLUGIN                           #
#######################################################################

def get_search_results(query, site):
    """Searches the site provided in site with the query, and returns 
    a list containing the list of urls (10 links) that match the query

    :returns (list of strings): Containg the URLS for the results
    """
    results = []

    # https reponse from google search 
    response = requests.get("https://www.google.com/search?q="+query.replace(" ","+")+" site:"+site)
    soup = BeautifulSoup(response.content, "lxml")

    for links in soup.findAll('a'):
        if '/url?' in links.attrs['href'] :
            results.append("https://www.google.com"+links.attrs['href'])

    return results

def get_data_from_current_line():
    results = get_search_results(vim.current.line, 'stackoverflow.com')
    code_blocks = []

    for result in results:
        response = requests.get(results[0])
        soup = BeautifulSoup(response.content, "lxml")
    
        for code_block in soup.findAll('code'):
    	    code_blocks.append(code_block)
	break
	    
    return code_blocks

def replace_cur_line_with_result():
    thing = get_data_from_current_line()
    things = thing.text.split('\n')
    row, col = vim.current.window.cursor
    for thang in things: 
    	vim.current.buffer[row-1] = thang

replace_cur_line_with_result()
EOF
endfunction
command! -nargs=0 GetHelp call GetHelp()
