---
title: api calls tests
---



> check the api calls are working as expected


::: {#cell-2 .cell 0='h' 1='i' 2='d' 3='e'}
``` {.python .cell-code}
from assign_uprn.api_calls import address_search, upload, download
```
:::


::: {#cell-3 .cell 0='h' 1='i' 2='d' 3='e'}
``` {.python .cell-code}
%load_ext autoreload
%autoreload 2
```
:::


## test single address check

::: {#cell-5 .cell}
``` {.python .cell-code}
comparable = {'Address_format': 'good',
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

response = address_search(address="10 Downing St,Westminster,London,SW1A2AA")
assert response.json() == comparable
```
:::


## test upload an encrypted salt

::: {#cell-7 .cell}
``` {.python .cell-code}
comparable = {"upload": { "status": "SALTOK"}}

assert upload(infilepath="../data/external/test.EncryptedSalt").json() == comparable
```
:::


## test upload a multiple address check file

::: {#cell-9 .cell}
``` {.python .cell-code}
comparable = {'upload': {'status': 'OK'}}

assert upload(infilepath="../data/external/test-addresses.txt").json() == comparable
```

::: {.cell-output .cell-output-display}
```
requests.models.Response
```
:::
:::


## download a multiple address match file

::: {#cell-11 .cell}
``` {.python .cell-code}
import time
# GIVE TIME FOR THE UPLOAD TO BE PROCESSED DURING TESTS
time.sleep(10)

infilepath = '../data/external/test-addresses.txt'
outfilepath = '../data/processed/assign-uprn.tsv'
assert download(infilepath=infilepath, outfilepath=outfilepath).status_code == 200
```

::: {.cell-output .cell-output-stdout}
```
written to ../data/processed/assign-uprn.tsv
```
:::
:::


