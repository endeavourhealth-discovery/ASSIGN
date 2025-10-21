---
title: api calls
---



> python functions wrapping address-to-uprn matching api calls



# functions

::: {#cell-4 .cell 0='h' 1='i' 2='d' 3='e'}
``` {.python .cell-code}
import logging
import http.client as http_client
```
:::


::: {#cell-5 .cell 0='h' 1='i' 2='d' 3='e'}
``` {.python .cell-code}
def _logger(level: int = 0):
    """connection logging

    Args:
        level (int, optional): [description]. Defaults to 0.

    Returns:
        Logger: details of logging
    """

    # SET THIS TO 1 IF TROUBLESHOOTING
    http_client.HTTPConnection.debuglevel = level
    # You must initialize logging, otherwise you'll not see debug output.
    logging.basicConfig()
    # set to logging.DEBUG for details
    logging.getLogger().setLevel(logging.ERROR)
    requests_log = logging.getLogger("requests.packages.urllib3")
    # set to logging.DEBUG for details
    requests_log.setLevel(logging.ERROR)
    requests_log.propagate = True
    return requests_log
```
:::


::: {#cell-6 .cell 0='e' 1='x' 2='p' 3='o' 4='r' 5='t'}
``` {.python .cell-code}
def _secrets() -> tuple:
    """set/get environment variables from a local source outside version control

    Returns:
        str, str, str: tuple
    """
    import os
    from dotenv import load_dotenv

    # take environment variables from .env.
    load_dotenv("../.env")
    ASSIGN_ENDPOINT = os.getenv("ASSIGN_ENDPOINT")
    ASSIGN_USER = os.getenv("ASSIGN_USER")
    ASSIGN_PASS = os.getenv("ASSIGN_PASS")
    return ASSIGN_ENDPOINT, ASSIGN_USER, ASSIGN_PASS

```
:::


::: {#cell-7 .cell 0='e' 1='x' 2='p' 3='o' 4='r' 5='t'}
``` {.python .cell-code}
import requests

def address_search(
    address: str # An address on a single line, each element separated with a comma
    ) -> str: # json representation of the matching AddressBase Premium record
    """
    Search for a UPRN by address

    Example:

        > response = address_search('10 Downing St,Westminster,London,SW1A2AA')
        > response.json()
        {'Address_format': 'good',
         'Postcode_quality': 'good',
         'Matched': True,
         'BestMatch': {'UPRN': '100023336956',
         'Qualifier': 'Property',
         'LogicalStatus': '1',
         'Classification': 'RD04',
         'ClassTerm': 'Terraced',
         'Algorithm': '10-match1',
         'ABPAddress': {'Number': '10',
         'Street': 'Downing Street',
         'Town': 'City Of Westminster',
         'Postcode': 'SW1A 2AA'},
         'Match_pattern': {'Postcode': 'equivalent',
         'Street': 'equivalent',
         'Number': 'equivalent',
         'Building': 'equivalent',
         'Flat': 'equivalent'}}}
    """

    # GET AUTHENTICATION DETAIL FROM .ENV
    ASSIGN_ENDPOINT, ASSIGN_USER, ASSIGN_PASS = _secrets()

    response = requests.get(
        f"{ASSIGN_ENDPOINT}/getinfo?adrec={address}", auth=(ASSIGN_USER, ASSIGN_PASS)
    )
    return response
```
:::


::: {#cell-8 .cell 0='e' 1='x' 2='p' 3='o' 4='r' 5='t'}
``` {.python .cell-code}
import requests
import os

def upload(
    infilepath: str, # filepath containing multiple addresses to upload
    debugLevel: int = 0 # optional, used during development
) -> requests.models.Response: # API response confirming whether upload OK
    """
    Upload text file of TSV address records to the ASSIGN API, OR upload an encrypted salt
    
    For address uploads, format is two columns: id and address, e.g.:
    1	10 Downing St,Westminster,London,SW1A2AA
    1	11 Downing St,Westminster,London,SW1A2AA

    Example:

        > infilepath='../data/external/test-addresses.txt'
        > upload(infilepath=infilepath).json()
        {'upload': {'status': 'OK'}}

        OR FOR SALT

        > infilepath='../data/external/test.EncryptedSalt'
        > upload(infilepath=infilepath).json()
        {"upload": { "status": "SALTOK"}}

    """

    # useful for debugging http activity
    if debugLevel == 1:
        _logger()

    # GET AUTHENTICATION DETAIL FROM .ENV
    ASSIGN_ENDPOINT, ASSIGN_USER, ASSIGN_PASS = _secrets()

    # HTTP POST request
    url = f"{ASSIGN_ENDPOINT}/fileupload2"

    files = {
        "file": (os.path.basename(infilepath), open(infilepath, "rb"), "text/plain")
    }
    response = requests.post(url, files=files, auth=(ASSIGN_USER, ASSIGN_PASS))

    return response
```
:::


::: {#cell-9 .cell 0='e' 1='x' 2='p' 3='o' 4='r' 5='t'}
``` {.python .cell-code}
import requests
import os

def download(
    infilepath: str, # filename of the previously uploaded file
    outfilepath: str = '../data/processed/assign-uprn.tsv', # filepath to store the response in
) -> requests.models.Response: # API response containing content to output to TSV file
    """
    Download TSV data matching previously upload txt file of TSV addresses
    
    Example:
    
        > infilepath = '../data/external/test-addresses.txt'
        > download(infilepath=infilepath).status_code
        200

    """

    # GET AUTHENTICATION DETAIL FROM .ENV
    ASSIGN_ENDPOINT, ASSIGN_USER, ASSIGN_PASS = _secrets()

    # HTTP GET request
    url = f"{ASSIGN_ENDPOINT}/download3"

    # TRIM PATH TO FILENAME ONLY (FOR IDENTIFICATION BY ASSIGN)
    params = {
        "filename": os.path.basename(infilepath),
    }

    response = requests.get(
        url, params=params, auth=(f"{ASSIGN_USER}", f"{ASSIGN_PASS}")
    )

    with open(outfilepath, "wb") as f:
        f.write(response.content)
        print(f"written to {outfilepath}")

    return response
```
:::


::: {#cell-10 .cell 0='h' 1='i' 2='d' 3='e'}
``` {.python .cell-code}
import nbdev

nbdev.nbdev_export()
```
:::


