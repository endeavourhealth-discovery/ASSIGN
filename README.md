# ASSIGN
This project contains the source code for the ASSIGN UPRN application
## Architecture and technologies
The software consists of 7 main architectural components

1. An Angular web application for users who wish to use ASSIGN as a human user
2. REST APIs for systems seeking to match addresses using an API
3. A command line utility for file based matching.
4. A hierarchical mumps database holding data derived from the Address Based Premium distribution files
5. Yotta Mumps business logic code (Mumps considers database access and business logic as a single tier)
6. SQL reference database reflecting the ABP distribution file formats which are relational in nature.
7. Install Scripts






