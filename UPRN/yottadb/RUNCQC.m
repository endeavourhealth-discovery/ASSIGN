RUNCQC ; ; 2/4/21 11:23am
 ;
STRING(config) ;
 DO RUN1
 DO RUN2
 ; config, source_data, builder_file
 DO RUN3("internal_nel_gp_pid","/tmp/cqc_api-1a.csv","/tmp/cqc-builder.txt")
 ; config, serviceuuid, builder_file, systemuuid
 DO RUN4("internal_nel_gp_pid","3579048b-4cdb-4118-ab41-d85d275d6cb6","/tmp/cqc-builder.txt","93a50faa-f64d-4d0b-a6aa-4b2367b14fac")
 QUIT
 
 K ^TSTEP($J)
 
REFRESH ; 
 K ^TSTEP($J)
 D RUN1
 D RUN2
 QUIT
 
RUN1 ; CQCGETALLLOCATIONS (all locations in London)
 S ^TSTEP($J,1)="cd /home/ubuntu;sudo ./queueReader/YCQCGETALLLOCATIONS.sh /tmp/cqc-location-ids.csv"
 
 D RUN(1)
 
 QUIT
 
RUN2 ; CQCAPI
 S ^CQCAPI=$GET(^CQCAPI)+1
 S id=^CQCAPI
 S ^TSTEP($J,2)="cd /home/ubuntu;sudo ./queueReader/YCQCAPI.sh /tmp/cqc-location-ids.csv /tmp/cqc_api-"_id_".csv"
 
 D RUN(2)
 
 QUIT
 
 ; CQCCREATEBUILDER
RUN3(config,filename,builderfile) ;
 
 S ^TSTEP($J,3)="cd /home/ubuntu;sudo ./queueReader/YCQCCREATEBUILDER.sh "_config_" "_filename_" "_builderfile
 
 D RUN(3)
 
 QUIT
 
RUN4(config,serviceuuid,builderfile,systemid) 
 ; CQCTHREADED
 S ^TSTEP($J,4)="cd /home/ubuntu;sudo ./queueReader/YCQCTHREADED.sh "_config_" "_serviceuuid_" "_builderfile_" "_systemid
 
 D RUN(4)
 
 QUIT
 
CREATE ; queuereader directory
 S QDIR="/home/ubuntu/queueReader/"
 D SH("BASH1",QDIR_"YCQCGETALLLOCATIONS.sh")
 zsystem "chmod +x "_QDIR_"YCQCGETALLLOCATIONS.sh"
 D SH("BASH2",QDIR_"YCQCAPI.sh")
 zsystem "chmod +x "_QDIR_"YCQCAPI.sh"
 D SH("BASH3",QDIR_"YCQCCREATEBUILDER.sh")
 zsystem "chmod +x "_QDIR_"YCQCCREATEBUILDER.sh"
 D SH("BASH4",QDIR_"YCQCTHREADED.sh")
 zsystem "chmod +x "_QDIR_"YCQCTHREADED.sh"
 QUIT
 
SH(CALL,FILE) ;
 CLOSE FILE
 O FILE:(newversion)
 S QF=0
 F I=1:1:10 DO  Q:QF
 .S L=$P($T(@CALL+I),";",2,9999)
 .I L["** END **" S QF=1 QUIT
 .USE FILE W L,!
 .U 0 W L,!
 .QUIT
 CLOSE FILE
 QUIT
 
RUN(STEP) ;
 S UNIX=^TSTEP($J,STEP)
 ZSYSTEM UNIX
 QUIT
 
 ; CQCGETALLLOCATIONS
BASH1 ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config 
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCGETALLLOCATIONS $1
 ; ** END **
 
 ; CQCAPI 
BASH2 ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCAPI $1 $2
 ; ** END **
 
 ; CQCCREATEBUILDER 
BASH3 ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCCREATEBUILDER $1 $2 $3
 ; ** END **
 
 ; CQCTHREADED 
BASH4 ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCTHREADED $1 $2 $3 $4
 ; ** END **
 ;
