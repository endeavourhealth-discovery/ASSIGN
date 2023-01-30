SKID ; ; 1/27/23 2:30pm
 ; a background job that runs every night that converts nhs_numbers
 ; into pseudo nhs_numbers
 quit
 
RALF(skid) ; ** REDUNDANT (takes to long to run)
 new saltname
 set saltname="RALFSKID"_$tr($j(skid,2)," ",0)
 S ^S("DBRALF",1)=$$HT^STDDATE($P($H,",",2))
 
 set sql="select patient_id, ralf from [compass_gp].[dbo].[patient_address_ralf] where salt_name='"_saltname_"'"
 w !,sql
 D RUN(sql)
 quit
 
UPDATES ;
 new nor,i,c
 set nor="",c=1
 K ^TUPDATE,^L
 S ^S("TUPDATE",1)=$$HT^STDDATE($P($H,",",2))
 f  s nor=$o(^ASUM(nor)) q:nor=""  do
 .i c#1000=0 w !,c
 .s c=c+1
 .; NULL NHS NUMBER?
 .if $get(^ASUM(nor,"nhsno"))="" quit
 .if $d(^SPIT("N",30,nor)) quit
 .;for i=1:1:30 i '$data(^SPIT("N",i,nor)) set ^TUPDATE(nor)="",^L=nor
 .set ^TUPDATE(nor)="",^L=nor
 .quit
 S ^S("TUPDATE",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
UPD2 ;
 new nor,c,in,sql
 s (nor,in)="",c=1
 s sql="select patient_id, skid, salt_name from [compass_gp].[dbo].[patient_pseudo_id] where patient_id in ("
 f  s nor=$o(^TUPDATE(nor)) q:nor=""  do
 .i nor'?1n.n quit
 .i c#2000=0 do
 ..S in=$e(in,1,$l(in)-1)
 ..s $p(sql,"(",2)=in_");"
 ..;
 ..D RUN(sql)
 ..;w !,"done" r *y
 ..D UPD2COLL
 ..s in=""
 ..quit
 .s in=in_nor_","
 .s c=c+1
 .quit
 
 if in'="" do
 .S in=$e(in,1,$l(in)-1)
 .s $p(sql,"(",2)=in_");"
 .d RUN(sql)
 .D UPD2COLL
 .quit
 quit
 
EOF() ;
 new f
 s f="/tmp/uprnrtns/patients.txt"
 c f
 o f:(readonly)
 u f r str,str,str
 close f
 quit $s(str="":1,1:0)
 
UPD2COLL ;
 new f,c,str,nor,pseudo,salt,skid
 I $$EOF() quit
 s f="/tmp/uprnrtns/patients.txt"
 c f
 o f:(readonly)
 set c=0
 u f r str,str
 
 f  u f r str q:$zeof!(str="")  do
 .;use 0 w !,str
 .S nor=$p(str,"~",1)
 .set pseudo=$p(str,"~",2)
 .set salt=$p(str,"~",3)
 .;W !,salt
 .set skid=+$e(salt,$l(salt)-1,$l(salt))
 .I $data(^SPIT("N",skid,nor)) quit
 .use 0 w !,nor," ",pseudo," ",salt
 .S ^SPIT("N",skid,nor)=pseudo
 .quit
 c f
 ;w !,"rows: ",c r:c>4 *y
 quit
 
DBSKIP(skid) ;
 set saltname="CompassSKID"_$tr($j(skid,2)," ",0)
 W !,saltname
 set select="patient_id, skid"
 
 set sql="select "_select_" from [compass_gp].[dbo].[patient_pseudo_id] where salt_name='"_saltname_"' "
 set sql=sql_"ORDER BY id OFFSET 0 ROWS FETCH NEXT 1000000 ROWS ONLY;"
 w !,sql
 quit
 
DB(skid) ; nhs numbers
 new saltname
 
 ;k ^SPIT(skid)
 
 S ^S("DB",skid,1)=$$HT^STDDATE($P($H,",",2))
 
 set saltname="CompassSKID"_$tr($j(skid,2)," ",0)
 W !,saltname
 
 set sql="select patient_id, skid from [compass_gp].[dbo].[patient_pseudo_id] where salt_name='"_saltname_"'"
 w !,sql
 d RUN(sql)
 
 S ^S("DB",skid,2)=$$HT^STDDATE($P($H,",",2))
 
 S ^S("COLLDB",skid,1)=$$HT^STDDATE($P($H,",",2))
 D COLLECTDB(skid)
 S ^S("COLLDB",skid,2)=$$HT^STDDATE($P($H,",",2))
 quit
 
COLLECTDB(skid) ;
 new f,nor,d,str,c
 
 K ^SPIT("N",skid)
 ;K ^SPIT("P",skid)
 
 s f="/tmp/uprnrtns/patients.txt"
 c f
 o f:(readonly)
 u f r str,str,str
 if str="" close f q
 close f
 o f:(readonly)
 u f r str,str
 set d="~",c=1
 f  u f r str q:$zeof!(str="")  do
 .i c#100000=0 use 0 w !,c
 .s nor=$p(str,"~",1)
 .s pseudo=$p(str,"~",2) 
 .set ^SPIT("N",skid,nor)=pseudo
 .;set ^SPIT("P",skid,pseudo)=$get(^SPIT("P",skid,pseudo))_nor_"~"
 .set c=c+1
 .quit
 close f
 quit
 
U3(user,skid) ;
 new c
 
 set ^T(user,"SKID")="INDEXING SKIDS"
 
 w !,"indexing skids"
 
 set c=""
 K ^TEMP($J)
 f  s c=$o(^U3(user,c)) q:c=""  do
 .set str=^U3(user,c)
 .set pseudo=$p(str,$c(9),1)
 .S ^TEMP($J,pseudo)=""
 .quit
 
 K ^SPIT("P",skid)
 
 s nor=""
 f  s nor=$o(^SPIT("N",skid,nor)) q:nor=""  do
 .s pseudo=^SPIT("N",skid,nor)
 .i $d(^TEMP($J,pseudo)) do
 ..set ^SPIT("P",skid,pseudo)=$get(^SPIT("P",skid,pseudo))_nor_"~"
 ..quit
 .quit
 
 K ^TEMP($J)
 K ^T(user,"SKID")
 quit
 
IDX(skid) ; *** REDUNDANT
 new nor
 set nor=""
 f  s nor=$order(^SPIT("N",skid,nor)) q:nor=""  do
 .set pseudo=^SPIT("N",skid,nor)
 .set ^SPIT("P",skid,pseudo)=$get(^SPIT("P",skid,pseudo))_nor_"~"
 .quit
 quit
 
STT ;
 new qf,i
 s qf=0
 kill ^ZPAT
 S ^S("STT",1)=$$HT^STDDATE($P($H,",",2))
 F i=0:1000000 do  quit:qf=1
 .set sql="select id, nhs_number from [compass_gp].[dbo].[patient] ORDER BY id OFFSET "_i_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .do RUN(sql)
 .s qf=$$COLLECT()
 .; test
 .;s qf=1
 .quit
 S ^S("STT",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
WRITE ;
 ; write out the contents of ^ZPAT
 new id,nhsno
 S ^S("WRITE",1)=$$HT^STDDATE($P($H,",",2))
 set f="/tmp/uprnrtns/patients.txt"
 close f
 o f:(newversion)
 s id=""
 for  set id=$order(^ZPAT(id)) quit:id=""  do
 .set nhsno=^ZPAT(id)
 .if nhsno="NULL" quit
 .u f w id,$char(9),nhsno,!
 .quit
 close f
 S ^S("WRITE",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
WRITEMATCH ; create a file of uprn's that need anonymising
 new nor,id
 K ^TEMP($j)
 s (nor,id)=""
 s f="/tmp/uprnrtns/uprns.txt"
 c f
 o f:(newversion)
 use f
 S ^S("WRITEMATCH",1)=$$HT^STDDATE($P($H,",",2))
 f  s nor=$o(^MATCH(nor)) q:nor=""  do
 .f  s id=$o(^MATCH(nor,id)) q:id=""  do
 ..s rec=^(id)
 ..s uprn=$p(rec,"~",1)
 ..i $d(^TEMP($J,uprn)) quit
 ..set ^TEMP($J,uprn)=""
 ..w id,$c(9),uprn,!
 ..quit
 .quit
 close f
 S ^S("WRITEMATCH",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
TEST ;
 new f,str,f2,salt,cmd,skid
 s f="/tmp/uprnrtns/patients.txt"
 s test="/tmp/uprnrtns/patients_test.txt"
 o test:(newversion)
 c f
 o f:(readonly)
 f i=1:1:10 do
 .u f r str
 .;u 0 w !,str
 .use test w str,!
 .quit
 c f,test
 S skid=3
 s salt=^SALTS("pseudo_salts",skid,"salt")
 set cmd="/tmp/ralfs.sh /tmp/uprnrtns/patients_test.txt notused /tmp/uprnrtns/nhs_number_spit.txt "_salt
 w !,cmd
 zsystem cmd
 quit
 
SPIT(skid) ;
 ;new f,str,nor,pseudo
 K ^SPIT("N",skid)
 K ^SPIT("P",skid)
 
 s f="/tmp/uprnrtns/nhs_number_spit.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .;use 0 w !,str r *y
 .set nor=$p(str,$c(9),1)
 .set pseudo=$p(str,$c(9),2)
 .;set ^SPIT(skid,pseudo,nor)=""
 .set ^SPIT("N",skid,nor)=pseudo
 .set ^SPIT("P",skid,pseudo)=$get(^SPIT("P",skid,pseudo))_nor_"~"
 .quit
 close f
 quit
 
SKIDS ;
 new i
 for i=1:1:5 D RUNJAR(i)
 quit
 
 ; find base64 salt using salt key name (not id)
FIND(skid) ;
 new i,name,base64
 set (i,base64)=""
 f  s i=$order(^SALTS("ralf_salts",i)) q:i=""  do  quit:base64'=""
 .set name=^SALTS("ralf_salts",i,"saltKeyName")
 .set n=+$e(name,$l(name)-1,$l(name))
 .I n=skid s base64=^SALTS("ralf_salts",i,"salt")
 .quit
 quit base64
 
RUNRALF(skid) ;
 new cmd,salt
 S ^S("RUNRALF",1)=$$HT^STDDATE($P($H,",",2))
 ;set salt=^SALTS("ralf_salts",skid,"salt")
 set salt=$$FIND(skid)
 set cmd="/tmp/ralfs.sh /tmp/uprnrtns/uprns.txt notused /tmp/uprnrtns/pseudoralf.txt "_salt
 w !,cmd
 zsystem cmd
 ;S ^S("RUNRALF",2)=$$HT^STDDATE($P($H,",",2))
 s f="/tmp/uprnrtns/pseudoralf.txt"
 close f
 o f:(readonly)
 k ^RALF(skid)
 f  u f r str q:$zeof  do
 .set uprn=$p(str,$c(9),1)
 .set pseudo=$p(str,$c(9),2)
 .S ^RALF(skid,uprn)=pseudo
 .quit
 close f
 S ^S("RUNRALF",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
RUNJAR(skid) ;
 new cmd,salt
 S ^S("RUNJAR",1)=$$HT^STDDATE($P($H,",",2))
 s salt=^SALTS("pseudo_salts",skid,"salt")
 set cmd="/tmp/ralfs.sh /tmp/uprnrtns/patients.txt notused /tmp/uprnrtns/nhs_number_spit.txt "_salt
 w !,cmd
 zsystem cmd
 D SPIT(skid)
 S ^S("RUNJAR",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
COLLECT() ;
 new f,d,id,nhsno,str
 s f="/tmp/uprnrtns/patients.txt"
 c f
 o f:(readonly)
 u f r str,str,str
 if str="" close f q 1
 close f
 o f:(readonly)
 set d="~"
 f  u f r str q:$zeof  do
 .;u 0 w !,str
 .s id=$p(str,d,1)
 .if id'?1n.n quit
 .s nhsno=$p(str,d,2)
 .i nhsno="NULL" quit
 .s ^ZPAT(id)=nhsno
 .quit
 close f
 quit 0
 
RUN(sql) ;
 new h,u,p,cmd
 S h=^ICONFIG("MSSQL","HOST")
 S u=^ICONFIG("MSSQL","USER")
 S p=^ICONFIG("MSSQL","PASS")
 set sql=""""_sql_""""
 S cmd="/opt/mssql-tools/bin/sqlcmd -W -S "_h_" -U '"_u_"' -P '"_p_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/patients.txt"
 w !,cmd
 zsystem cmd
 i $zsystem'=0 set ^CMD(+$H,$piece($h,",",2))=sql
 quit
