DOWNLOAD ; ; 10/31/22 12:51pm
 S QF=0
 ;K ^MATCH
 ;K ^ADR
 K ^ASUM
 ;K ^EOC
 F I=1:1000000 DO  Q:QF=1
 .;set sql="select * from [test01].[dbo].[patient_address_match] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .;set sql="select * from [compass_gp].[dbo].[patient_address] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .set sql="select id, date_of_death from [compass_gp].[dbo].[patient] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .;set sql="select * from [compass_gp].[dbo].[episode_of_care] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .W !,sql
 .;R *Y
 .D RUN(sql)
 .;S QF=$$COLLADR()
 .;S QF=$$COLLECT()
 .S QF=$$COLLASUM()
 .;S QF=$$COLLEOC()
 .;w !,"ok" R *Y
 .QUIT
 quit
 
EOF() ;
 s f="/tmp/uprnrtns/download.txt"
 c f
 o f:(readonly)
 u f r str,str,str
 close f
 quit $s(str="":1,1:0)
 
MATCH ;
 new nor,id
 K ^MATCH,^D("MATCH")
 S (nor,id)="",c=1
 S ^D("MATCH",1)=$$HT^STDDATE($P($H,",",2))
 s in=""
 f  s nor=$o(^ADR(nor)) q:nor=""  do
 .f  s id=$o(^ADR(nor,id)) q:id=""  do
 ..i c#1000=0  do
 ...s in=$e(in,1,$l(in)-1)
 ...s sql="select * from [test01].[dbo].[patient_address_match] where patient_address_id in ("_in_")"
 ...;w !,sql r *y
 ...D RUN(sql)
 ...s e=$$COLLMATCH()
 ...W !,c
 ...s in=""
 ...quit
 ..s in=in_id_","
 ..s c=c+1
 ..quit
 I in'="" do
 .s in=$e(in,1,$l(in)-1)
 .s sql="select * from [test01].[dbo].[patient_address_match] where patient_address_id in ("_in_")"
 .D RUN(sql)
 .s e=$$COLLMATCH()
 .quit
 S ^D("MATCH",2)=$$HT^STDDATE($P($H,",",2))
 quit
 
COLLMATCH() ;
 new id,adrid
 i $$EOF() Q 1
 s f="/tmp/uprnrtns/download.txt"
 close f
 o f:(readonly)
 u f r str,str ; header
 f  u f r str q:$zeof!(str="")  do
 .S str=$$TR^LIB(str,"NULL","")
 .s id=$p(str,"~",1)
 .s adrid=$p(str,"~",2)
 .;;;s $p(str,"~",4)=""
 .S ^MATCH(adrid,id)=$p(str,"~",3,99)
 .quit
 close f
 quit 0
 
COLLASUM() ; dead patient only
 I $$EOF() q 1
 s f="/tmp/uprnrtns/download.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof!(str="")  do
 .s dod=$p(str,"~",2)
 .s id=$p(str,"~",1)
 .s personid=$p(str,"~",3)
 .s ethnic=$p(str,"~",4)
 .s dob=$p(str,"~",5)
 .;i dod="NULL" quit
 .;I dod="NULL" s ^ASUM(id)="" quit
 .s:dod'="NULL" ^ASUM(id,"dod")=dod
 .s:ethnic'="NULL" ^ASUM(id,"ethnic")=ethnic
 .s:dob'="NULL" ^ASUM(id,"dob")=dob
 .S ^ASUM(id)=personid
 .quit
 close f
 quit 0
 
COLLEOC() ;
 I $$EOF() q 1
 s f="/tmp/uprnrtns/download.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof!(str="")  do
 .s nor=$p(str,"~",3),id=$p(str,"~",1)
 .s person=$p(str,"~",4),regtype=$p(str,"~",5)
 .s datereg=$p(str,"~",7),regend=$p(str,"~",8)
 .i datereg="NULL" s datereg=""
 .i regend="NULL" s regend=""
 .S org=$p(str,"~",2)
 .S ^EOC(nor,id)=person_"~"_regtype_"~"_datereg_"~"_regend_"~"_org
 .quit
 close f
 quit 0
 
 
COLLADR() ;
 i $$EOF() q 1
 s f="/tmp/uprnrtns/download.txt"
 close f
 o f:(readonly)
 ;u f r str if $zeof close f q 1
 ;u f r str
 u f r str,str
 f  u f r str q:$zeof!(str="")  do
 .s id=$p(str,"~",1)
 .s nor=$p(str,"~",3)
 .S start=$p(str,"~",12)
 .s end=$p(str,"~",13)
 .s person=$p(str,"~",4)
 .s org=$p(str,"~",2)
 .S use=$p(str,"~",11)
 .i start="NULL" s start=""
 .i end="NULL" S end=""
 .set lsoa=$p(str,"~",15) ; 2011
 .set msoa=$p(str,"~",17) ; 2011
 .s ^ADR(nor,id)=person_"~"_start_"~"_end_"~"_org_"~"_use_"~"_lsoa_"~"_msoa
 .quit
 close f
 quit 0
 
COLLECT() ;
 s f="/tmp/uprnrtns/download.txt"
 close f
 o f:(readonly)
 ;u f r str if $zeof close f q 1
 ;u f r str
 f  u f r str q:$zeof!(str="")  do
 .s id=$p(str,"~",1)
 .s adrid=$p(str,"~",2)
 .s str=$$TR^LIB(str,"NULL","")
 .S ^MATCH(adrid,id)=$P(str,"~",3,99)
 .quit
 close f
 quit 0
 
RUN(sql) ;
 S H=^ICONFIG("MSSQL","HOST")
 S U=^ICONFIG("MSSQL","USER")
 S P=^ICONFIG("MSSQL","PASS")
 
 set sql=""""_sql_""""
 
 S CMD="/opt/mssql-tools/bin/sqlcmd -W -S "_H_" -U '"_U_"' -P '"_P_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/download.txt"
 zsystem CMD
 
 quit
