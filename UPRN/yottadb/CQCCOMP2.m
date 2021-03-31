CQCCOMP2 ; ; 3/19/21 3:32pm
 QUIT
 
 ; file = cqc_api-1.csv.txt
 ; file = out_providers.csv.txt
 ;
 ; W $$STT^CQCCOMP2("/tmp/cqc_api-1.csv.txt","L")
 ; W $$STT^CQCCOMP2("/tmp/out_providers.csv.txt","P")
 ;
STT(file,locprov) 
 S id=$I(^BACKUP(locprov))
 D BACKUP(file,locprov,id)
 if id=1 quit file
 ; flush the previous file to disk
 ;
 ;
 D CMP(locprov)
 s file=""
 i $data(^TDELTAS($J)) do
 .s file="/tmp/deltas.txt"
 .o file:(newversion)
 .s locid=""
 .f  s locid=$o(^TDELTAS($J,locid)) q:locid=""  do
 ..use file w ^(locid),!
 ..q
 .close file
 .quit
 
 QUIT file
 
CMP(locprov) ;
 K ^TDELTAS($J)
 S latest=$o(^BACKUP(locprov,""),-1)
 S prev=(latest-1)
 i prev=0 w !,"?" quit
 ; has anything changed?
 set (locid,l)="",line=1
 f  s locid=$order(^BACKUP(locprov,latest,locid)) q:locid=""  do
 .f  s l=$o(^BACKUP(locprov,latest,locid,l)) q:l=""  do
 ..s lrec=^(l)
 ..s prec=^BACKUP(locprov,prev,locid,l)
 ..i prec'=lrec S ^TDELTAS($J,locid)=$$CSV^CQCCOMP(lrec,line),line=$i(line)
 ..quit
 .quit
 quit
 
 ; ** REDUNDANT **
FLUSH(file,id) ;
 S l=""
 S file=file_".prev"
 open file:(newversion)
 F  S l=$order(^BACKUP(file,id,l)) Q:l=""  do
 .U file write ^(l),!
 .quit
 close file
 quit
 
BACKUP(file,locprov,id) 
 S l=1
 c file o file:(readonly)
 f  u file r str q:$zeof  do
 .;S ^BACKUP(locprov,id,l)=str,l=$i(l)
 .;
 .I locprov="L" set idx=$p(str,$c(9),15) ; location_id
 .I locprov="P" set idx=$p(str,$c(9),16) ; provider_id
 .I idx="" quit ; fixed in java code
 .S ^BACKUP(locprov,id,idx,l)=str,l=$i(l)
 .quit
 close file
 QUIT
