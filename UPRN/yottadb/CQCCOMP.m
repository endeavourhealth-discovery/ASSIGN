CQCCOMP ; ; 2/10/21 2:53pm
 ; COMPARE PREVIOUS VERSION WITH LATEST VERSION
 ;
 S latest=$get(^CQCAPI)
 I latest="" w !,"no record of latest" quit
 S prev=+$get(^CQCAPI)-1
 I prev=-1 w !,"no record of previous" quit
 ; load the files by location-Id
 S lfile="/tmp/cqc_api-"_latest_".csv.txt"
 s pfile="/tmp/cqc_api-"_prev_".csv.txt"
 ;
 ; make a backup of the prev and latest files
 f f="/tmp/cqc_api-"_latest_".csv","/tmp/cqc_api-"_prev_".csv","/tmp/cqc_api-"_latest_".csv.txt","/tmp/cqc_api-"_prev_".csv.txt" do
 .do BACKUP(f)
 .quit
 
 K ^CQCCSV(latest),^CQCCSV(prev)
 d LOAD(lfile,latest),LOAD(pfile,prev)
 d CMP(latest,prev)
 QUIT
 
BACKUP(file) 
 S l=1
 c file o file:(readonly)
 f  u file r str q:$zeof  do
 .S ^BACKUP(file,l)=str,l=$i(l)
 .quit
 close file
 QUIT
 
CSV(rec,line) ;
 S d=""""
 s csv=line_","
 f i=1:1:$l(rec,$c(9)) s csv=csv_d_$p(rec,$c(9),i)_d_","
 s csv=$e(csv,1,$l(csv)-1)
 quit csv
 
CMP(latest,prev) 
 n locid
 s locid="",T=0
 ; load the csv data for the latest file
 ;
 K ^TDELTAS($J)
 S line=1
 f  s locid=$order(^CQCCSV(latest,locid)) q:locid=""  do
 .s prec=$get(^CQCCSV(prev,locid))
 .i prec="" q
 .s lrec=^CQCCSV(latest,locid)
 .i prec'=lrec do
 ..S ^TDELTAS($J,locid)=$$CSV(lrec,line)
 ..quit
 .s line=$i(line)
 .quit
 ;
 S ^DELTAS=$g(^DELTAS)+1
 S f="/tmp/deltas-"_^DELTAS_".csv"
 C f
 o f:(newversion)
 S locid=""
 F  S locid=$order(^TDELTAS($J,locid)) q:locid=""  do
 .u f w ^(locid),!
 .quit
 close f
 quit
 
 
LOCID(csv) ;
 n locid
 S locid=$p(csv,$c(9),15)
 quit locid
 
LOAD(file,lpno) ;
 n locid
 S FILE=file
 c file
 o file:(readonly)
 u file r str
 f  u file r str q:$zeof  do
 .;U 0 W !,str
 .s locid=$$LOCID(str)
 .S ^CQCCSV(lpno,locid)=$P(str,$c(9),2,9999)
 c file
 QUIT
