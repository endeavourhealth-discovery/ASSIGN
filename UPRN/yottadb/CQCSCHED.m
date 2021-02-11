CQCSCHED ; ; 2/11/21 10:30am
 ; CQC scheduler
 ; Runs load & collects raw epoch files every day
 ;
 ; job STT^CQCSCHED:(in="/dev/null":out="/dev/null":err="error.log")
 ; $ydb_dist/mupip intrpt 18790 (where 18790 is $job)
 ;
STT ;
 S ^DSYSTEM("CQCSCHED")=$JOB
 set $ZINT="I $$JOBEXAM^CQCSCHED($ZPOS)"
 for i=1:1 do  q:$d(^DSYSTEM("STOP-CQC"))
 .hang 5
 .set ht=$piece($H,",",2)
 .; 7AM (do a CQC load)
 .if ht>25200,ht<27000 do
 ..if $data(^DSYSTEM("RUNCQC",+$horolog)) quit
 ..S ^DSYSTEM("RUNCQC",+$horolog)=""
 ..;;;;;;D REFRESH^RUNCQC
 ..quit
 .; 3PM (ftp)
 .if ht>54000,ht<55800 do
 ..if $data(^DSYSTEM("SFTP",+$horolog)) quit
 ..S ^DSYSTEM("SFTP",+$horolog)=""
 ..D RUN^SFTP
 ..quit
 .quit
 S ^DSYSTEM("CQCSCHED-STOP")=$H
 QUIT
 
JOBEXAM(%ZPOS) 
 s idx=$o(^interupt(""),-1)+1
 S ^interupt(idx)=$get(%ZPOS)
 D LOG
 QUIT
 
LOG ;
 K ^LOG
 S %D=$H,%I="exam"
 S %TOP=$STACK(-1),%N=0
 F %LVL=0:1:%TOP S %N=%N+1,^LOG("log",%D,$J,%I,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 S %X="^LOG(""log"",%D,$J,%I,""error"",""symbols"","
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 QUIT
