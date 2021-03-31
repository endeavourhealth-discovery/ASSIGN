RUNCQC ; ; 3/24/21 12:42pm
 ;
 ; internal_nel_gp_pid
 ; D STRING^RUNCQC("subscriber_pi")
 ; String all the calls together!
STRING(config) ;
 ; CQCGETALLLOCATIONS
 ; K ^BACKUP to start again
 K ^CQCAPI
 DO RUN1
 
 ; CQCAPI
 S locfile=$$RUN2()
 ; rate limiting (600 requests per minute for each client)
 W !,"Hanging 64 seconds!"
 H 64
 S provfile=$$RUN2A()
 
 ; CQCCREATEBUILDER 
 ; config, source_data, builder_file
 DO:locfile'="" RUN3(config,locfile,"/tmp/cqc-builder.txt")
 DO:provfile'="" RUN3(config,provfile,"/tmp/builder-prov.txt")
 
 ; CQCTHREADED
 ; config, serviceuuid, builder_file, systemuuid
 DO:locfile'="" RUN4(config,"3579048b-4cdb-4118-ab41-d85d275d6cb6","/tmp/cqc-builder.txt","93a50faa-f64d-4d0b-a6aa-4b2367b14fac")
 DO:provfile'="" RUN4(config,"3579048b-4cdb-4118-ab41-d85d275d6cb6","/tmp/builder-prov.txt","93a50faa-f64d-4d0b-a6aa-4b2367b14fac")
 QUIT
 
 K ^TSTEP($J)
 
REFRESH ; 
 K ^TSTEP($J)
 D RUN1 ; CQCGETALLLOCATIONS
 S csv=$$RUN2() ; CQCAPI
 ; do the comparison here
 S db=""
 ;S csv="/tmp/cqc_api-"_^CQCAPI_".csv"
 S builder="/tmp/cqc-builder.txt"
 S serviceuuid="3579048b-4cdb-4118-ab41-d85d275d6cb6"
 S serviceid="93a50faa-f64d-4d0b-a6aa-4b2367b14fac"
 F  S db=$o(^ICONFIG("DB",db)) q:db=""  do
 .D RUN3(db,csv,builder) ; CQCCREATEBUILDER
 .D RUN4(db,serviceuuid,builder,serviceid) ; CQCTHREADED
 .quit
 QUIT
 
RUN1 ; CQCGETALLLOCATIONS (all locations in London)
 S ^TSTEP($J,1)="cd /home/ubuntu;sudo ./queueReader/YCQCGETALLLOCATIONS.sh /tmp/cqc-location-ids-1.csv"
 
 D RUN(1)
 
 QUIT
 
RUN2() ; CQCAPI
 ;S ^CQCAPI=$GET(^CQCAPI)+1
 ;S id=^CQCAPI
 
 S id=1
 S ^TSTEP($J,2)="cd /home/ubuntu;sudo ./queueReader/YCQCAPI.sh /tmp/cqc-location-ids-1.csv /tmp/cqc_api-1.csv /tmp/providers.txt"
 
 D RUN(2)
 
 S file="/tmp/cqc_api-1.csv"
 
 i $get(^BACKUP("L"))>0 S file=$$STT^CQCCOMP2(file_".txt","L")
 
 I '$data(^BACKUP("L")) S ^BACKUP("L")=1 D BACKUP^CQCCOMP2(file_".txt","L",1)
 
 ;I id>1 do
 ;.do ^CQCCOMP
 ;.S file="/tmp/deltas-"_^DELTAS_".csv"
 ;.quit
 
 QUIT file
 
RUN2A() ; CQCPROVAPI
 ;
 ;
 S ^TSTEP($J,2)="cd /home/ubuntu;sudo ./queueReader/YCQCPROVAPI.sh /tmp/providers.txt /tmp/out_providers.csv"
 D RUN(2)
 S file="/tmp/out_providers.csv"
 i $get(^BACKUP("P"))>0 S file=$$STT^CQCCOMP2(file_".txt","P")
 
 I '$data(^BACKUP("P")) S ^BACKUP("P")=1 D BACKUP^CQCCOMP2(file_".txt","P",1)
 
 QUIT file
 
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
 D SH("BASH2A",QDIR_"YCQCPROVAPI.sh")
 zsystem "chmod +x "_QDIR_"YCQCPROVAPI.sh"
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
 
 ; CQCAPI / CQCPROVAPI 
BASH2 ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCAPI $1 $2 $3
 ; ** END **
 
BASH2A ;
 ;#!/bin/bash
 ;# pull in environment variables for mysql connection to config
 ;. /opt/setenv.sh
 ;
 ;java -Xmx1g -XX:+UseG1GC -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:+CrashOnOutOfMemoryError -jar /opt/queueReader/eds-queuereader-1.0-SNAPSHOT-jar-with-dependencies.jar CQCPROVAPI $1 $2
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
