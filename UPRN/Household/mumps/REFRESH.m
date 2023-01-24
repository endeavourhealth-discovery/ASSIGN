REFRESH ; ; 1/24/23 12:05pm
 quit
 
ALL ;
 S ^REFRESH(1)=$$HT^STDDATE($P($H,",",2))
 D ASUMB
 D STT("patient")
 D STT("patient_address")
 D STT("episode_of_care")
 ;D STT("patient_address_match")
 S ^REFRESH(2)=$$HT^STDDATE($P($H,",",2))
 quit
 
ASUMB ;
 new nor,c
 s nor=""
 set c=1
 f  s nor=$o(^ASUM(nor)) q:nor=""  do
 .i c#10000=0 w !,c
 .s c=c+1
 .set ^ASUMB(nor)=""
 .quit
 quit
 
STT(table) ;
 ;
 new tables
 kill tables
 
 s tables("patient_address")=""
 s tables("patient")=""
 s tables("episode_of_care")=""
 s tables("patient_address_match")=""
 i '$d(tables(table)) w !,"table not supported" quit
 
 i table="patient_address" K ^ADR
 i table="patient" K ^ASUM
 i table="episode_of_care" k ^EOC
 i table="patient_address_match",'$D(^ADR) W !,"refresh address table first" quit
 i table="patient_address_match",$D(^ADR) D MATCH^DOWNLOAD quit
 
 F I=0:1000000 DO  Q:QF=1
 .S sql="select * from [compass_gp].[dbo].["_table_"] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .;
 .if table="episode_of_care" set sql="select patient_id, id, person_id, registration_type_concept_id, date_registered, date_registered_end, organization_id from [compass_gp].[dbo].[episode_of_care] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .;
 .if table="patient" set sql="select id, date_of_death, person_id, ethnic_code_concept_id, date_of_birth, gender_concept_id, organization_id from [compass_gp].[dbo].[patient] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .;
 .if table="patient_address" set sql="select id, patient_id, start_date, end_date, person_id, organization_id, use_concept_id, lsoa_2011_code, msoa_2011_code from [compass_gp].[dbo].[patient_address] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .w !,sql
 .DO RUN^DOWNLOAD(sql)
 .S QF=1
 .if table="patient_address" S QF=$$COLLADR^DOWNLOAD()
 .if table="patient" S QF=$$COLLASUM^DOWNLOAD()
 .if table="episode_of_care" S QF=$$COLLEOC^DOWNLOAD()
 .quit
 
 quit
 
topup(nor) ;
 new sql,QF,in,f,str
 
 s sql="select id, date_of_death, person_id, ethnic_code_concept_id, date_of_birth, gender_concept_id, organization_id from [compass_gp].[dbo].[patient] where id = '"_nor_"'"
 D RUN^DOWNLOAD(sql)
 ;
 S QF=$$COLLASUM^DOWNLOAD()
 ;
 
 s sql="select * from [compass_gp].[dbo].[patient_address] where patient_id = '"_nor_"'"
 ;
 
 D RUN^DOWNLOAD(sql)
 S QF=$$COLLADR^DOWNLOAD()
 ;
 
 ; cache patient_address ids, in order to populate match
 set in=""
 if '$$EOF^DOWNLOAD() do
 .s f="/tmp/uprnrtns/download.txt"
 .close f
 .o f:(readonly)
 .u f r str,str
 .set in=""
 .f  u f r str q:$zeof!(str="")  do
 ..s in=in_$p(str,"~",1)_","
 ..quit
 .close f
 .quit
 
 ;set in=$e(in,1,$l(in)-1)
 
 ;for i=1:1:$l(ids,"~") do
 ;.if $piece(ids,"~",i)="" quit
 ;.s in=in_","
 ;.quit
 
 if in'="" do
 .set in=$e(in,1,$l(in)-1)
 .set sql="select * from [compass_gp].[dbo].[patient_address_match] where patient_address_id in ("_in_")"
 .;
 .D RUN^DOWNLOAD(sql)
 .S QF=$$COLLMATCH^DOWNLOAD()
 .;
 .quit
 
 set sql="select * from [compass_gp].[dbo].[episode_of_care] where patient_id = '"_nor_"'"
 D RUN^DOWNLOAD(sql)
 S QF=$$COLLEOC^DOWNLOAD()
 ;
 
 quit
 
set(str) ;
 n id,adrid,rec,uprn,ralf,class,qual,rule,matchdate
 s id=$p(str,"~",1)
 s adrid=$p(str,"~",2)
 s uprn=$p(str,"~",3)
 ;s ralf=$p(str,"~",4)
 s ralf=""
 s class=$p(str,"~",4)
 s qual=$p(str,"~",5)
 s rule=$p(str,"~",6)
 s matchdate=$p(str,"~",7)
 s rec=""
 s $p(rec,"~",1)=uprn
 S $p(rec,"~",2)=ralf
 s $p(rec,"~",4)=class
 s $p(rec,"~",9)=qual
 s $p(rec,"~",10)=rule
 s $p(rec,"~",11)=matchdate
 S ^MATCH(adrid,id)=rec
 quit
 
test2(skid) ; patient_address_ralf
 K ^RALF
 set table="patient_address_ralf"
 s T=0,QF=0
 s select="patient_id, ralf"
 s skid="RALFSKID"_$TR($J(skid,2)," ",0)
 S ^test2(1)=$$HT^STDDATE($P($H,",",2))
 F I=0:1000000 DO  Q:QF
 .S sql="select "_select_" from [compass_gp].[dbo].["_table_"] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .w !,sql
 .D RUN^DOWNLOAD(sql)
 .S QF=$$EOF^DOWNLOAD()
 .W !,QF," press a key:"
 .quit
 S ^test2(2)=$$HT^STDDATE($P($H,",",2))
 quit
 
test ;
 K ^MATCH
 S table="patient_address_match"
 S T=0,QF=0
 S ^test(1)=$$HT^STDDATE($P($H,",",2))
 ; remove uprn_ralf00
 ; 
 s select="id,patient_address_id,uprn,uprn_ralf00,uprn_property_classification,qualifier,match_rule,match_date"
 
 s select="id,patient_address_id,uprn,uprn_property_classification,qualifier,match_rule,match_date"
 ;
 F I=0:1000000 DO  Q:QF
 .S sql="select "_select_" from [compass_gp].[dbo].["_table_"] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT 1000000 ROWS ONLY;"
 .w !,sql
 .D RUN^DOWNLOAD(sql)
 .;s f="/tmp/uprnrtns/download.txt"
 .;c f
 .;o f:(readonly)
 .;u f r str if $zeof c f S QF=1 quit
 .;close f
 .S QF=$$EOF^DOWNLOAD()
 .;W !,QF," press a key:"
 .I QF QUIT
 .s f="/tmp/uprnrtns/download.txt"
 .c f
 .o f:(readonly)
 .u f r str,str
 .f  u f r str q:$zeof!(str="")  do
 ..d set(str)
 ..quit
 .close f
 .W !,QF
 .s T=T+1
 .W !,T
 .Q
 S ^test(2)=$$HT^STDDATE($P($H,",",2))
 q
