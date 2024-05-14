# Importing the ABP data into Mumps using the osdatahub API

## BACKGROUND

The Address Base Premium files, allow the UPRN algorithm to find UPRN data from an address candidate  
A candidate address is an address string:  
Flippers, 5-9 High St, Skegness, PE25 3NY
The last piece must be a post code

The ABP files are downloaded using an API  
A routine called ABPAPI can be used to download the files:  
https://api.os.uk/downloads/v1/dataPackages

Data packages are created using the OS datahub:  
https://osdatahub.os.uk/

## DOWNLOADING THE ADDRESS BASE PREMIUM FILES

A routine called ABPAPI2.m has been written to download an OS package and apply the ABP files to the database
Before running ABPAPI2 you'll need to update a global called ^ICONFIG with some credentials, that allows ABPAPI2 to download the files from the OS web site

Access your yottadb system:

su fred
cd /home/fred/
/usr/local/lib/yottadb/latest/ydb

set ^ICONFIG("COU-NAME")="Blah" (the name of the os data package that you want to download)
set ^ICONFIG("HUB","KEY")="Blah" (the API key from the os datahub site)
set ^ICONFIG("HUB","SECRET")="Blah" (the secret from the os datahub site)

D ALL^ABPAPI2

ALL^ABPAPI2 downloads the zip files, unzips, then converts the raw csv files, that were previously unzipped, into a version that can be imported into the mumps database:  

ID32_Class_Records.csv  
ID28_DPA_Records.csv  
ID24_LPI_Records.csv  
ID21_BLPU_Records.csv,  
ID15_StreetDesc_Records.csv

If everythiong goes to plan, you should be able to find the csv files in /opt/all/

## IMPORTING THE ADDRESS BASE PREMIUM FILES INTO MUMPS

Download Residential_codes.txt, Counties.txt, Saints.txt from the ASSIGN repository:  
https://github.com/endeavourhealth-discovery/ASSIGN/tree/master/UPRN/codelists  
Copy Residential_codes.txt, Counties.txt, Saints.txt to /tmp/
Move the downloaded csv's to /tmp/ 

su fred
cd /home/fred/
/usr/local/lib/yottadb/latest/ydb

Then, run this command to import the csv files into the mumps database:
D IMPORT^UPRN1A("/tmp/")