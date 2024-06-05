# ABP Import Code Changes (UPRN1A)

There will be times when you'll need to import the ABP CSV data into the database:

- When setting up the system for the first time
- When an ABP change-only update becomes available
- When the code that imports the ABP data into the database changes

## Initial Setup and Change-Only Updates
- Initial Setup: Instructions for importing ABP data for the first time are found in the UPRN ABP Processing documentation (Initial Database Update).

- Change-Only Updates: Instructions for automatically processing change-only updates are found in the UPRN ABP Processing documentation, using the scheduler software (POURC).

## Code Changes and Full Import

When the code that imports the ABP data into the MUMPS database changes, a FULL import is necessary. After this, all change-only updates must be processed in the correct order to ensure the database is current.

Routine for Import: The routine that imports the ABP data into the database is UPRN1A.

Routine for Full Import and Updates: The routine that performs a FULL import and then processes all change-only updates is ABPFULL.

## Scheduler Stub

- Stub for Scheduler: GB^ABPFULL

- Stub Parameters:

zip: Specifies the 7z file containing the ABP files used for the initial setup.

folder: The directory where ABPFULL will perform its unzipping.

Example:

- do STT^ABPFULL("/tmp/", "/opt/all/6471504/pawk.7z")

In this example, the software will unzip the files one at a time from /opt/all/6471504/pawk.7z to /tmp/.

## Full Import Process

STT^ABPFULL performs the following steps:

1.  Retrieves Counties.txt, Residential_codes.txt, and Saints.txt from the ASSIGN GitHub repository (saves to /tmp/).

2.  Checks the contents of the zip to ensure all necessary files are included.

3.  Automatically restores the latest UPRN* routines from the ASSIGN repository.

4.  Drops/kills the main UPRN globals.

5.  Unzips ID32_Class_Records.csv.

6.  Imports ID32_Class_Records.csv into the database by calling IMPCLASS^UPRN1A.

7.  Deletes ID32_Class_Records.csv to free up disk space.

8.  Unzips ID15_StreetDesc_Records.csv.

9.  Imports ID15_StreetDesc_Records.csv into the database by calling IMPSTR^UPRN1A.

10. Deletes ID15_StreetDesc_Records.csv.

11. Unzips ID21_BLPU_Records.csv, calls IMPBLP^UPRN1A, deletes.

12. Unzips ID28_DPA_Records.csv, calls IMPDPA^UPRN1A, deletes.

13. Unzips ID24_LPI_Records.csv, calls IMPLPI^UPRN1A, deletes.

14. Kills ^DSYSTEM("COU"), which keeps a record of all previously processed change-only updates.

15. Sets ^DSYSTEM("COU", 6471504) to avoid processing the folder containing the full files.

16. Calls PROCESS^ABPAPI2 to process the change-only updates.

17. Calls AREAS^UPRN1A to drop and refresh ^UPRN("AREAS") from ^UPRNX("X").

18. Calls SETSWAPS^UPRNU to set up lookup global nodes used by the algorithm to find a UPRN.
