# About this Repository

This repository provides background information on the technologies utilized by the ASSIGN software.

The technical information in this documentation refers to installing ASSIGN on the Ubuntu operating system.

Mumps, as a programming language, has been implemented by number of different vendors.

YottaDB is an open source implemention of Mumps which ASSIGN uses to run the algorithm.

The most recent YottaDB installation script is compatible with Ubuntu 22.04 LTS.

The provided instructions include installing the YottaDB Python plug-in and showcasing examples of its usage.

This potentially enables someone to rewrite the Mumps code in Python, while leveraging the existing Mumps global structures to locate a UPRN.

Note: Familiarity with Globals is essential for utilizing the Python plug-in.

For further details on global variables, refer to the following link: 

https://github.com/robtweed/global_storage/blob/master/README.md


Please note that the Mumps ASSIGN source code is undergoing continuous changes, due to the inclusion of additional addresses from various source systems and locations during training.

# Articles in this Repository

- [YottaDB Ubuntu pre-requisites](./Pre_Requisites.md)
- [Installing YottaDB](./YottaDB_Install.md)
- [Installing ASSIGN and the mumps web server](./ASSIGN_Install.md)
- [Importing the Address Base Premium data into the mumps database](./ABP_Import.md)
- [Installing and using Python with YottaDB](./Python.md)
- [Automated ABP processing](./ABP_Auto.md)
- [Using VS Code to run and debug your Mumps and Python code](./VSCode.md)
- [Using the ASSIGN API](./ASSIGN_Api.md)