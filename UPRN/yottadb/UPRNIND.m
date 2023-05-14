UPRNIND ;Rebuilds all the UPRN indexes [ 05/14/2023  9:29 AM ]
 n
 S ^STATS("START")=$H
 s d="~"
 K ^UPRNX
 ;
REDO ;First the name uprn BLPU table
 D BLPU
 
 
GO ;Next the post office DPA table
 D INDMAIN
 
 ;Next the local authority LPI table
 S ^STATS("END")=$H
 Q
 
BLPU ;Index on BLPU record
 s i=1
 s d="~"
 s uprn=""
 for  s uprn=$O(^UPRN("U",uprn)) q:uprn=""  d
 .s rec=^(uprn)
 .;i '$$isok(uprn) q
 .s post=$p(rec,d,2)
 .S ^UPRNX("X1",post,uprn)=""
 q
 
UPC ;Checks for any parent child links
 Q
 q
 
INDMAIN ;Index on DPA table
 s i=1
 s d="~"
 s (uprn,key)=""
REENT for  s uprn=$O(^UPRN("U",uprn)) q:uprn=""  d
 .;I '$$isok(uprn) q
 .s table=""
 .for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d
 ..for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d
 ...s rec=^UPRN("U",uprn,table,key)
 ...q:rec=""
 ...s flat=$p(rec,d,1)
 ...s build=$p(rec,d,2)
 ...s bno=$p(rec,d,3)
 ...s depth=$p(rec,d,4)
 ...s street=$p(rec,d,5)
 ...s deploc=$p(rec,d,6)
 ...s loc=$p(rec,d,7)
 ...s town=$p(rec,d,8)
 ...s post=$p(rec,d,9)
 ...s org=$p(rec,d,10)
 ...s dep=$p(rec,d,11)
 ...s ptype=$p(rec,d,12)
 ...d setind
 ...s i=i+1
 ...I '(i#10000) w i," "
 q
 
 q
 
setind ;Sets indexes
 d setind1
 i flat["/"!(bno["/") d
 .s xflat=flat,xbno=bno
 .s flat=$tr(flat,"/","-")
 .s bno=$tr(bno,"/","-")
 .d setind1
 .s flat=xflat,bno=xbno
 .quit
 quit
 
setind1 ;Sets indexes
 n i
 i town'="" S ^UPRNS("TOWN",town)=""
 i loc'="" S ^UPRNS("TOWN",loc)=""
 i $l(street," ")>6 q
 i $l(build," ")>6 q
 s pstreet=$$plural^UPRNU(street)
 s pbuild=$$plural^UPRNU(build)
 s pdepth=$$plural^UPRNU(depth)
 s same=0
 i pstreet=street,pbuild=build,pdepth=depth s same=1
 s indrec=post_" "_flat_" "_build_" "_bno_" "_depth_" "_street_" "_deploc_" "_loc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 S ^UPRNX("X",indrec,uprn,table,key)=""
 i 'same d
 .s indrec=post_" "_flat_" "_pbuild_" "_bno_" "_pdepth_" "_pstreet_" "_deploc_" "_loc
 .for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 .s indrec=$$lt^UPRNL(indrec)
 .S ^UPRNX("X",indrec,uprn,table,key)=""
 i deploc'="" d
 .s ^UPRNX("X5",post,street_" "_deploc,bno,build,flat,uprn,table,key)=""
 i depth'="" d
 .s ^UPRNX("X5",post,depth_" "_street,bno,build,flat,uprn,table,key)=""
 .s ^UPRNX("X5",post,street,bno,depth,flat_" "_build,uprn,table,key)=""
 .i 'same d
 ..s ^UPRNX("X5",post,pstreet,bno,pdepth,flat_" "_pbuild,uprn,table,key)=""
 s ^UPRNX("X5",post,street,bno,build,flat,uprn,table,key)=""
 i 'same d
 .s ^UPRNX("X5",post,pstreet,bno,pbuild,flat,uprn,table,key)=""
 i depth'="" d
 .set ^UPRNX("X3",depth,bno,post,uprn,table,key)=""
 .set ^UPRNX("X3",pdepth,bno,post,uprn,table,key)=""
 .D indexstr("STR",depth)
 .i pdepth'=depth D indexstr("STR",pdepth)
 i deploc'="",street="" d
 .S ^UPRNX("X5",post,deploc,bno,build,flat,uprn,table,key)=""
 i depth'="",street="" d
 .S ^UPRNX("X5",depth,bno,build,flat,uprn,table,key)=""
 .i 'same d
 ..S ^UPRNX("X5",pdepth,bno,pbuild,flat,uprn,table,key)=""
 i street'="" d
 .set ^UPRNX("X3",street,bno,post,uprn,table,key)=""
 .i 'same d
 ..set ^UPRNX("X3",pstreet,bno,post,uprn,table,key)=""
 .set ^UPRNX("X3",$tr(street," "),bno,post,uprn,table,key)=""
 .I depth'="" d
 ..set ^UPRNX("X3",depth_" "_street,bno,post,uprn,table,key)=""
 ..i 'same d
 ...set ^UPRNX("X3",pdepth_" "_pstreet,bno,post,uprn,table,key)=""
 .do indexstr("STR",street)
 .i pstreet'=street do indexstr("STR",pstreet)
 i build'="" d
 .set ^UPRNX("X3",build,flat,post,uprn,table,key)=""
 .i 'same d
 ..set ^UPRNX("X3",pbuild,flat,post,uprn,table,key)=""
 .do indexstr("BLD",build)
 .i pbuild'=build do indexstr("BLD",pbuild)
 i build'="",flat'="",street'="" d
 .set ^UPRNX("X2",build,street,flat,post,bno,uprn,table,key)=""
 I flat'="",bno'="",street'="",build'="" d
 .S ^UPRNX("X4",post,street,bno,flat,build,uprn,table,key)=""
 if build="",org'="" d
 .set ^UPRNX("X5",post,street,bno,org,flat,uprn,table,key)=""
 .i 'same d
 ..set ^UPRNX("X5",post,pstreet,bno,org,flat,uprn,table,key)=""
 .if flat'="" d
 ..set ^UPRNX("X3",org,flat,post,uprn,table,key)=""
 ..do indexstr("BLD",org)
 I street'="",bno'="",build'="",flat'="" d
 .S ^UPRNX("X5A",post,street,build,flat,bno,uprn,table,key)=""
 .i 'same d
 ..S ^UPRNX("X5A",post,pstreet,pbuild,flat,bno,uprn,table,key)=""
 I pstreet'=street!(pbuild'=build) d
 .I deploc'="" d
 ..s ^UPRNX("X5",post,pstreet_" "_deploc,bno,pbuild,flat,uprn,table,key)=""
 .I pdepth'="" d
 ..s ^UPRNX("X5",post,pdepth_" "_pstreet,bno,pbuild,flat,uprn,table,key)=""
eind q
indexstr(index,term)         ;Indexes street or building etc
 n strno,i,word
 if '$d(^UPRNX("X."_index,term)) d
 .S ^UPRNX("X."_index)=$G(^UPRNX("X."_index))+1
 .S strno=^UPRNX("X."_index)
 .S ^UPRNX("X."_index,term)=strno
 .I term[" " d
 ..s ^UPRNS("X."_index,$tr(term," "))=term
 .s ^UPRNX(index,strno)=term
 s strno=^UPRNX("X."_index,term)
 f i=1:1:$l(term," ") d
 .s word=$p(term," ",1)
 .q:word=""
 .i $D(^UPRNS("CORRECT",word)) d
 ..s word=^UPRNS("CORRECT",word)
 .I $D(^UPRNS("ROAD",word)) q
 .I $D(^UPRNX("X."_index,word)) q
 .s ^UPRNX("X.W",word,index,strno)=""
 q
isok(uprn)        ;
 n (uprn)
 s class=$G(^UPRN("CLASS",uprn))
 i class="" q 1
 i '$D(^UPRN("CLASSIFICATION",class)) q 1
 s res=$G(^UPRN("CLASSIFICATION",class,"residential"))
 i res="Y" q 1
 q 0
