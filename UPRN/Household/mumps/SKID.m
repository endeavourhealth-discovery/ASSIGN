SKID ; ; 1/9/23 1:14pm
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
 
DB(skid) ; nhs numbers
 new saltname
 
 ;k ^SPIT(skid)
 
 S ^S("DB",1)=$$HT^STDDATE($P($H,",",2))
 
 set saltname="CompassSKID"_$tr($j(skid,2)," ",0)
 W !,saltname
 
 set sql="select patient_id, skid from [compass_gp].[dbo].[patient_pseudo_id] where salt_name='"_saltname_"'"
 w !,sql
 d RUN(sql)
 
 S ^S("DB",2)=$$HT^STDDATE($P($H,",",2))
 
 S ^S("COLLDB",1)=$$HT^STDDATE($P($H,",",2))
 D COLLECTDB(skid)
 S ^S("COLLDB",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
COLLECTDB(skid) ;
 new f,nor,d,str,c
 
 K ^SPIT("N",skid)
 K ^SPIT("P",skid)
 
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
 .set ^SPIT("P",skid,pseudo)=$get(^SPIT("P",skid,pseudo))_nor_"~"
 .set c=c+1
 .quit
 close f
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
 
RUNRALF(skid) ;
 new cmd,salt
 S ^S("RUNRALF",1)=$$HT^STDDATE($P($H,",",2))
 set salt=^SALTS("ralf_salts",skid,"salt")
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
 quit
