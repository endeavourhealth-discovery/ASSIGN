---
title: assign-uprn
---



> python wrapper for ASSIGN API calls 


## About

docs
: [https://joeldn.srht.site/assign-uprn](https://joeldn.srht.site/assign-uprn)

code
: [https://git.sr.ht/~joeldn/assign-uprn](https://git.sr.ht/~joeldn/assign-uprn)

license
: [AGPLV3](https://git.sr.ht/~joeldn/assign-uprn/tree/main/item/LICENSE)

## Usage

### Installation

Install from [pypi](https://pypi.org/project/assign-uprn/)


```sh
$ pip install assign_uprn
```

### Background

#### Address-to-UPRN matching algorithm


> In partnership with researchers at Queen Mary University of London’s Clinical Effectiveness Group, Endeavour Health has developed an address-matching algorithm to link patient health records to geospatial information. Linking people to places can help researchers understand how health is impacted by social and environmental factors, like the characteristics of a household, green space or air pollution. But patient addresses are entered into GP records as free text so the same address can be written in different ways, making data linkage very difficult.

> The algorithm, known as ASSIGN (**A**ddre**SS** Match**I**n**G** to Unique Property Reference **N**umbers), allocates a Unique Property Reference Number (UPRN) to patient records 

> Every property in the UK already has a UPRN. They are allocated by local authorities and made nationally available by Ordnance Survey. A UPRN gives every address a standardised format, enabling pseudonymised linkage to other sources of data.

> ASSIGN compares addresses in freetext form with the Ordnance Survey's "Address Base Premium" UPRN database, one element at a time, and decides whether there is a match. The algorithm mirrors human pattern recognition, so it allows for certain character swaps, spelling mistakes and abbreviations. After rigorous testing and adjustments, ASSIGN correctly matches 98.6% of patient addresses at 38,000 records per minute. It also includes patients’ past addresses, making it possible to study addresses across the life span. 

> The address matching algorithms use a human mediated best fit method to match a candidate address to one address from the set of all available 'standard' addresses.

> The algorithms use human semantic pattern recognition, applying rankings of matching judgements following rules that manipulate the text, supported by a few machine based algorithms such as the Levenshtein distance algorithm.

> The rankings, which can be considered as a set of numbers, `1-n`, could be described as a plausibility measure, as opposed to a probability measure or deterministic measure.

[docs](https://wiki.endeavourhealth.org/index.php?title=ASSIGN-_UPRN_address_match_application) | 
[code](https://github.com/endeavourhealth-discovery/ASSIGN)

#### UPRN de-identification

ASSIGN can also de-identify UPRNs into Residential Anonymised Linkage Fields (RALFs). These are locations that are pseudo-anonymised by encrypting them using a salt, which has itself been encrypted by a research governance function and the openpseudobymiser website: 

> [https://www.openpseudonymiser.org](https://www.openpseudonymiser.org)

Different datasets with UPRNs, such as council records and health records, can be de-identified using the same salt, and then linked anonymously for research purposes by anonymising the home UPRN of the person into a RALF. 

::: {.callout-note collapse="true" title="A note on re-identification"}

It's worth noting that whilst de-identified data protects information about individuals, it can potentially be re-identified by association with other datasets, as explained in the following excerpt from Cory Doctorow's blog: 

> [https://pluralistic.net/2024/03/08/the-fire-of-orodruin/](https://pluralistic.net/2024/03/08/the-fire-of-orodruin/)

> &hellip;it is surprisingly easy to "re-identify" individuals in anonymous data-sets. To take an obvious example: we know which two dates former PM Tony Blair was given a specific treatment for a cardiac emergency, because this happened while he was in office. We also know Blair's date of birth. Check any trove of NHS data that records a person who matches those three facts and you've found Tony Blair – and all the private data contained alongside those public facts is now in the public domain, forever.

> Not everyone has Tony Blair's reidentification hooks, but everyone has data in some kind of database, and those databases are continually being breached, leaked or intentionally released. A breach from a taxi service like Addison-Lee or Uber, or from Transport for London, will reveal the journeys that immediately preceded each prescription at each clinic or hospital in an "anonymous" NHS dataset, which can then be cross-referenced to databases of home addresses and workplaces. In an eyeblink, millions of Britons' records of receiving treatment for STIs or cancer can be connected with named individuals – again, forever.

Using de-identified UPRNs in datasets does not completely eliminate the risk of person-level records being re-identified. For this reason, an alternative research data management practice is now being using by organisations such as OpenSAFELY: 

> [https://www.opensafely.org](https://www.opensafely.org)

OpenSAFELY retains identifiable records in a secure location whilst researchers prepare their analysis code on synthetic data, including the ability to produce disclosure controlled outputs. Researchers submit their code to OpenSAFELY, which runs it against real data, and the disclosure controls are checked by moderators prior to release back the researhers. This way, row-level information about individuals is protected against identification.

:::

## Dependencies

### API Access

### License to use AddressBase Premium 

AddressBase Premium usage is typically used by public service providers under the terms of the Public Services Geospatial Mapping Agreement (PSGA). You can check whether you are licensed to use this data with the following lookup:

> [https://www.ordnancesurvey.co.uk/customers/public-sector/psga-member-finder](https://www.ordnancesurvey.co.uk/customers/public-sector/psga-member-finder)

### API access and authentication

Endeavour health manage access, and provide the API endpoints, usernames, and passwords that support API usage:

> [https://endeavourhealth.org](https://endeavourhealth.org)

### Python packages used by this module

the following packages dependencies need to be available in the python environment used by this package

```py
# pip install requests, used to interact with the API
import requests
```

```py
# pip install python-dotenv, note that other dot env packages exist
from dotenv import load_dotenv
```

#### Working with python-dotenv

Create a `.env` file in the project root containing the following variables used by the package: 

```sh
ASSIGN_ENDPOINT=endpoint
ASSIGN_USER=username
ASSIGN_PASS=password
```

`.env` is explicitly excluded from version control by `.gitignore` which keeps your authentication credentials separate from the codebase.

The contents of `.env` will contain authentication credentials provided by endeavour health with the contents resembling the following structure:

### De-identification salt

To obtain RALFs, your research governance function can support you to obtain a salt they have previously encrypted with the openpseudonymiser website using a salt phrase created for the research project being conducted:

> [https://www.openpseudonymiser.org](https://www.openpseudonymiser.org)

The salt is encrypted using a private key known only to The University of Nottingham (the maintainers of openpseudonymiser).

## Using the API

### Single address check

A single address can be sent for matching within a single HTTP request. A search for `10+Downing+St,Westminster,London,SW1A2AA` would receive the following response:

```json
{
   "Address_format":"good",
   "Postcode_quality":"good",
   "Matched":true,
   "BestMatch":{
      "UPRN":"100023336956",
      "Qualifier":"Property",
      "LogicalStatus":"1",
      "Classification":"RD04",
      "ClassTerm":"Terraced",
      "Algorithm":"10-match1",
      "ABPAddress":{
         "Number":"10",
         "Street":"Downing Street",
         "Town":"City Of Westminster",
         "Postcode":"SW1A 2AA"
      },
      "Match_pattern":{
         "Postcode":"equivalent",
         "Street":"equivalent",
         "Number":"equivalent",
         "Building":"equivalent",
         "Flat":"equivalent"
      }
   }
}
```

### Uploading an encrypted salt


If you wish to de-identify the UPRNS, please ask your data governance function to provide you with a `.EncryptedSalt` file from the openpseudonymiser website. You can then use the provided `upload` function to send this to the API.

From then on, addresses batch uploaded with the `upload` function will not only be UPRN matched, but a RALF will be provided too (see the `Example download file content` in this document).

### Multiple address checking

Multiple addresses can be uploaded within a text file which is processed immediately after the file has been uploaded, and downloaded shortly afterwards.

### Upload

The maximum number of address candidates that you can upload in a single file is `100,000`.

The address file to be uploaded must: 

* have a .txt extension
* include no headers
* contain two columns separated by a single tab character 
  * The first line must not contain any header information
  * The first column is a unique numeric row id
  * The second column is the address (with commas between each address line)

#### Example upload file content:

```tsv
1⭾10 Downing St,Westminster,London,SW1A2AA
3⭾Bridge Street,London,SW1A 2LW
4⭾221b Baker St,Marylebone,London,NW1 6XE
5⭾3 Abbey Rd,St John's Wood,London,NW8 9AY
```

### Download

Uploads are processed straightaway and can be downloaded by referencing the name of the upload file in the API call. The download includes data from AddressBase Premium (plus a RALF if you've previously uploaded a `.EncryptedSalt` file): 

#### Example download file content:

<div id="example-download-file-content" style="overflow-x: scroll">
| id | uprn | address_fmt | algorithm | classification | match_building | match_flat | match_number | match_postcode | match_street | abp_number | abp_postcode | abp_street | abp_town | qualifier | adr_candiddate | abp_building | latitude | longitude | point | x | y | ralf | classification_term | abp_flat | logical_status |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 100023336956 |  | 10-match1 | RD04 | equivalent | equivalent | equivalent | equivalent | equivalent | 10 | SW1A 2AA | Downing Street | City Of Westminster | Property | 10 Downing St,Westminster,London,SW1A2AA |  | 51.5035410 | -.1276700 | 51.5035410 | 530047.00 | 179951.00 | C30921C8404087803C3687301351FF41CCB4A5E8F3691070723293C8BD654CBB | Terraced |  | 1 |
| 2 | 200002501505 |  | 550-match5a | PP | candidate field dropped | equivalent | equivalent | equivalent | equivalent |  | SW1A 2LW | Bridge Street | City Of Westminster | Property | Bridge Street,London,SW1A 2LW | Portcullis House | 51.5013476 | -.1243451 | 51.5013476 | 530284.00 | 179713.00 | 4D19E2EB66A2C12BD56B93D96CFBBE5B74525AEFC4C68329BE87B55C43EA4C36 | Property Shell |  | 1 |
| 3 | 100023071949 |  | 3200-match61A170 | CR08 | moved from Number  | equivalent | moved to Building  | equivalent | equivalent |  | NW1 6XE | Baker Street | London | Property | 221b Baker St,Marylebone,London,NW1 6XE | 221B | 51.5237510 | -.1585550 | 51.5237510 | 527847.00 | 182144.00 | 7727B90C7C3A744AF6FD8D5A4FEB6767B1EACBBC721B85EED6AE86EDD2B0BA9C | Shop / Showroom |  | 1 |
| 4 | 100023122909 |  | 40-match1 | CR08 | moved from Street  | moved from Number  | moved from Flat  | equivalent | moved from Building  | 3 | NW8 9AY | Abbey Road | City Of Westminster | Property | 3 Abbey Rd,St Johns Wood,London,NW8 9AY |  | 51.5321562 | -.1779541 | 51.5321562 | 526478.00 | 183045.00 | 6E479D3F8DA8A548C631622EA8640E1CE9030289C5ED4458B91A4F6C4F92C799 | Shop / Showroom |  | 1 |
</div>


## Developer Guide

This project uses `nbdev` which uses notebooks to create the package the module, tests, documentation (using quarto), and makes git versioning cleaner by removing notebook metadata prior to commits:

> [https://nbdev.fast.ai/](https://nbdev.fast.ai/)

### Working on the assign-uprn module

```sh
# install assign_uprn package as a developer
$ pip install -e '[.dev]'

# make changes to notebooks in the nbs/ directory
# ...

# clean the notebook metadata to make git history cleaner
$ nbdev_clean

# compile to have changes apply to assign_uprn module, and run tests
$ nbdev_prepare

# build the static website with quarto (https://quarto.org/)
$ nbdev_docs

# local preview of the website with quarto
$ nbdev_preview

```

