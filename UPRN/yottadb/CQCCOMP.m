CQCCOMP ; ; 2/4/21 3:39pm
 ; COMPARE PREVIOUS VERSION WITH LATEST VERSION
 ;
 S latest=$get(^CQCAPI)
 I latest="" w !,"no record of latest" quit
 S prev=+$get(^CQCAPI)-1
 I prev=-1 w !,"no record of previous" quit
 ; load the files by location-Id
 S lfile="/tmp/cqc_api-"_latest_".csv.txt"
 s pfile="/tmp/cqc_api-"_prev_".csv.txt"
 ; do I kill ^CQCCSV?
 d LOAD(lfile,latest),LOAD(pfile,prev)
 d CMP(latest,prev)
 QUIT
 
CMP(latest,prev) 
 n locid
 s locid="",T=0
 f  s locid=$order(^CQCCSV(latest,locid)) q:locid=""  do
 .s prec=$get(^CQCCSV(prev,locid))
 .i prec="" q
 .s lrec=^CQCCSV(latest,locid)
 .i prec'=lrec w !,locid,!,prec,!,lrec r *y S T=T+1
 .quit
 ; location_ids that no longer exist
 s locid=""
 f  s locid=$o(^CQCCSV(prev,locid)) q:locid=""  do
 .i '$d(^CQCCSV(latest,locid)) w !,"?",locid r *y
 .quit
 quit
 
LOCID(csv) ;
 n locid
 S locid=$p(csv,$c(9),15)
 quit locid
 
LOAD(file,lpno) ;
 n locid
 c file
 o file:(readonly)
 u file r str
 f  u file r str q:$zeof  do
 .;U 0 W !,str
 .s locid=$$LOCID(str)
 .S ^CQCCSV(lpno,locid)=$P(str,$c(9),2,9999)
 c file
 QUIT
