REFRESH ; ; 10/21/22 8:48am
 quit
 
ALL ;
 S ^REFRESH(1)=$$HT^STDDATE($P($H,",",2))
 D STT("patient")
 D STT("patient_address")
 D STT("episode_of_care")
 D STT("patient_address_match")
 S ^REFRESH(2)=$$HT^STDDATE($P($H,",",2))
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
 
 F I=1:1000000 DO  Q:QF=1
 .S sql="select * from [test01].[dbo].["_table_"] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .if table="patient" set sql="select id, date_of_death, person_id, ethnic_code_concept_id, date_of_birth from [compass_gp].[dbo].[patient] ORDER BY id OFFSET "_I_" ROWS FETCH NEXT "_(I+999999)_" ROWS ONLY;"
 .w !,sql
 .DO RUN^DOWNLOAD(sql)
 .S QF=1
 .if table="patient_address" S QF=$$COLLADR^DOWNLOAD()
 .if table="patient" S QF=$$COLLASUM^DOWNLOAD()
 .if table="episode_of_care" S QF=$$COLLEOC^DOWNLOAD()
 .quit
 
 quit
