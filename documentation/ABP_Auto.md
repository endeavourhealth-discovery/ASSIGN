# UPRN ABP Processing

The routines responsible for maintaining the ABP globals' currency include:

- **POURC.m**
- **METRICS.m**
- **UPRN1B.m**
- **ABPAPI2.m**
- **ABPAPI.m**

POURC.m functions as a background process tasked with running schedules managed within a global reference named ^ZQZ.

Running POURC in the background is facilitated by utilizing the MUMPS job command:
```mumps
job SERVICE^POURC:(out="/dev/null")
```

The /dev/null parameter effectively suppresses any output from being written to disk.

SERVICE^POURC iterates in an infinite loop until it's time to execute MUMPS code. It services a MUMPS global known as ^ZQZ.

## API Integration

To ensure the MUMPS database remains current, ABP data is retrieved via an API developed by Ordnance Survey (https://www.ordnancesurvey.co.uk/).

Before utilizing the API, registration with osdatahub.os.uk is essential, along with the creation of a GB data package. Additionally, to employ the software for downloading ABP data, an API key must be generated through osdatahub. This key should then be configured within ^ICONFIG("HUB","KEY") and ^ICONFIG("HUB","SECRET") using the provided data from osdatahub. These details serve as part of the authentication process when calling the API.

Once a data package is created, it needs to be specified which package will be utilized to update the system. The names of the data packages must be configured within ^ICONFIG. For instance, if the package name is "GB WITH COU", the following MUMPS command should be executed:

set ^ICONFIG("COU-NAME")="GB WITH COU"

## Scheduling

The scheduling of API calls to download and process changes exclusively operates under schedule number 1. The setup for schedule 1 is executed by running the ZQZ1^POURC software.

Each schedule within the system consists of a run date, run time, and the MUMPS routine to execute. Currently, there are two schedules: one for downloading ABP data and another for importing change-only updates into the database.

The structure of the schedules is as follows:
```
^ZQZ(schedule_number)="schedule_name"
^ZQZ(schedule_number,run_date)="run_time" (run_date and run_time need to be in mumps $Horolog format)
^ZQZ(schedule_number,run_date,"RTN")="mumps_routine_to_execute"
```

For example:
```
^ZQZ(1)="ABP downloads"
^ZQZ(1,66956)=79500
^ZQZ(1,66956,"RTN")="ALL^ABPAPI2"
```
Each schedule is executed sequentially. If the currently running schedule takes an extended period or overlaps with another schedule, the subsequent schedule will commence once the running schedule concludes.

## Change-only Updates

The software "ALL^ABPAPI2" is responsible for downloading change-only data from the API, extracting it, and then converting the ABP data into a format compatible with the ASSIGN import software. This process occurs daily at 22:05.

The change-only updates are downloaded and processed within the "/opt/all" directory.

The second schedule is established by executing "ZQZ2^POURC". This schedule triggers the execution of "PROCESS^ABPAPI2".

## Importing Updates

"PROCESS^ABPAPI2" runs daily at 00:05 (five minutes past midnight). Its primary function is to import the change-only updates previously collected by "ALL^ABPAPI2". Upon execution, the first action performed by "PROCESS^ABPAPI2" is a directory listing of "/opt/all", where each subdirectory represents a change-only update ID. Any subdirectories that have been processed previously are ignored.

The software utilizes the ^DSYSTEM global to track whether a change-only update has been processed previously. Each entry in the ^DSYSTEM("COU") global corresponds to a change-only update, with the format "COU",ChangeUpdateID = Date,Time.

For example:
^DSYSTEM("COU",6471504)="66955,3004"

Indicates that change-only update 6471504 was imported into the system on April 25, 2024, at 00:50.

The software responsible for importing these updates is "STT^UPRN1B". After completing the import, "STT^UPRN1B" updates ^DSYSTEM("COU") to signify that the change-only update has been processed. If a change-only update is processed, a re-index of the system is necessary, accomplished by calling "^UPRNIND".

The duration of the last GB re-index was 4 hours and 13 minutes.

## Initial Database Update

For the initial ABP database update, a manual process is required due to the potentially large file sizes, particularly for importing data for Great Britain. A routine named "ABPAPI.m" facilitates this process by downloading the full update. To execute the code, use "STT^ABPAPI" and select the desired data package for download and conversion into a format compatible with ASSIGN.

The directory where the ABP files will be downloaded and processed is specified in ^ICONFIG("HUB","DIR"). This directory will also contain the final CSV output required for ASSIGN to import the data into the MUMPS database. After the process completes, ensure that "Counties.txt", "Residential_codes.txt", and "Saints.txt" are copied into the same folder as ^ICONFIG("HUB","DIR"). These text files can be sourced from the codelists folder in the ASSIGN GitHub repository.

## Importing CSV Data

To import the CSV data into the database, execute the following code:

```
Do IMPORT^UPRN1A(^ICONFIG("HUB","DIR"))
```

The files used by IMPORT^UPRN1A to update the MUMPS database include:

ID32_Class_Records.csv
ID28_DPA_Records.csv
ID24_LPI_Records.csv
ID21_BLPU_Records.csv
ID15_StreetDesc_Records.csv

## Metrics

To ascertain the availability of updates for download and the number of change-only updates imported into the system, utilize "STT^METRICS".
