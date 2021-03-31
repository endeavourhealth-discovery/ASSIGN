EMISCH ; ; 3/31/21 9:26am
 D ORGS
 K ^OUTPUT
 D STT
 D GOLD
 S (PARENT,ORG)=""
 S F="/tmp/goldVemis.txt"
 C F
 O F:(newversion)
 U F
 S D=$C(9)
 W "CCG",D,"ORG",D,"ODS",D,"EMIS",D,"GOLD",!
 F  S PARENT=$O(^OUTPUT(PARENT)) Q:PARENT=""  DO
 .W $P(^ORGZ(PARENT),"~"),!
 .F  S ORG=$O(^OUTPUT(PARENT,ORG)) Q:ORG=""  DO
 ..S EMIS=$GET(^OUTPUT(PARENT,ORG,"E"))
 ..S GOLD=$GET(^OUTPUT(PARENT,ORG,"G"))
 ..W D,$P(^ORGZ(ORG),"~"),D,$P(^ORGZ(ORG),"~",2),D,EMIS,D,GOLD,!
 ..QUIT
 .QUIT
 CLOSE F
 QUIT
 
PATSDETS(GLOB) ;
 S (ORG,NOR)=""
 S F="/tmp/"_$$LC^LIB($E(GLOB,2,99))_"_pats.txt"
 C F
 O F:(newversion)
 U F
 S D=$C(9)
 W "id",D,"org_id",D,"ods_code",D,"org_name",D,"address",D,"sex",D,"age",!
 F  S ORG=$O(@GLOB@(ORG)) Q:ORG=""  DO
 .F  S NOR=$O(@GLOB@(ORG,NOR)) Q:NOR=""  DO
 ..S ADR=$$TR^LIB(^ASUM(NOR,"address"),"~",",")
 ..S AGE=^ASUM(NOR,"age")
 ..S GENDER=^ASUM(NOR,"gender")
 ..I GENDER=1335245 S GENDER="F"
 ..I GENDER=1335244 S GENDER="M"
 ..S ORGNAM=$P(^ORGZ(ORG),"~",1)
 ..S ODSCODE=$P(^ORGZ(ORG),"~",2)
 ..W NOR,D,ORG,D,ODSCODE,D,ORGNAM,D,ADR,D,GENDER,D,AGE,!
 ..QUIT
 .QUIT
 C F
 QUIT
 
NOTIN(A,B) ;
 S T=0
 S F=""
 I A="^GOLD" S F="/tmp/assign-not-in-emis.txt"
 I A="^EMIS" S F="/tmp/emis-not-in-assign.txt"
 I F="" QUIT
 
 CLOSE F
 O F:(newversion)
 USE F
 
 S D=$C(9)
 W "patient_id",D,"org_id",D,"ods_code",D,"org_name",D,"patient_address",D,"sex",D,"age",!
 
 S (ORG,NOR)=""
 F  S ORG=$O(@A@(ORG)) Q:ORG=""  DO
 .F  S NOR=$O(@A@(ORG,NOR)) Q:NOR=""  DO
 ..I '$D(@B@(ORG,NOR)) DO
 ...S ADR=$$TR^LIB(^ASUM(NOR,"address"),"~",",")
 ...S AGE=^ASUM(NOR,"age")
 ...S GENDER=^ASUM(NOR,"gender")
 ...;I GENDER=1335245 S GENDER="F"
 ...;I GENDER=1335244 S GENDER="M"
 ...S GENDER=$S(GENDER=1335245:"F",GENDER=1335244:"M",1:"?")
 ...S ORGNAM=$P(^ORGZ(ORG),"~",1)
 ...S ODSCODE=$P(^ORGZ(ORG),"~",2)
 ...W NOR,D,ORG,D,ODSCODE,D,ORGNAM,D,ADR,D,GENDER,D,AGE,!
 ...QUIT
 ..QUIT
 .QUIT
 ;W !,"TOT = ",T
 CLOSE F
 QUIT
 
ORGS ;
 S Q5="select * from "_db_".organization"
 S FILE="/tmp/orgs.txt"
 S KEY=^ICONFIG("CHOMES","KEY")
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY,Q5,FILE)
 S FILE="/tmp/orgs.txt"
 K ^ORGZ
 C FILE
 O FILE:(readonly)
 U FILE R STR
 F  U FILE R STR Q:$ZEOF  DO
 .S ORGID=$P(STR,$C(9),1)
 .S ODSCODE=$P(STR,$C(9),2)
 .S NAME=$P(STR,$C(9),3)
 .S PARENT=$P(STR,$C(9),7)
 .S ^ORGZ(ORGID)=NAME_"~"_ODSCODE_"~"_PARENT
 .QUIT
 C FILE
 QUIT
 
STT ;
 S key=^ICONFIG("CHOMES","KEY")
 S config="internal_nel_gp_pid"
 ;Lives in a residential home (finding)
 D GO("394923006",key,"/tmp/liveinrh.txt",config)
 ;Lives in a nursing home (finding) 
 D GO("160734000",key,"/tmp/livesinnh.txt",config)
 ;Lives in care home (finding)
 D GO("248171000000108",key,"/tmp/livesinch.txt",config)
 ;no longer lives in a care home
 D NOCH
 D MERGE
 QUIT
 
MERGE ;
 K ^EMIS
 F FILE="/tmp/liveinrh.txt","/tmp/livesinnh.txt","/tmp/livesinch.txt" DO
 .C FILE
 .O FILE:(readonly)
 .F  U FILE R STR Q:$ZEOF  DO
 ..S NOR=$P(STR,$C(9),3)
 ..I '$D(^ASUM(NOR)) QUIT
 ..S ORG=$P(STR,$C(9),2)
 ..S dat=$P(STR,$C(9),7)
 ..S d=$p(dat,"-",3)_"."_$p(dat,"-",2)_"."_$p(dat,"-")
 ..S h=$$DH^STDDATE(d)
 ..s left=$order(^NOCHALL(ORG,NOR,""),-1)
 ..i +left>h u 0 w !,ORG," * ",NOR," no longer lives in care home" q
 ..I '$D(^EMIS(ORG,NOR)) DO
 ...S ^EMIS(ORG)=$GET(^EMIS(ORG))+1
 ...S ^EMIS(ORG,NOR)=""
 ...S PARENT=$P(^ORGZ(ORG),"~",3)
 ...S ^OUTPUT(PARENT,ORG,"E")=$GET(^OUTPUT(PARENT,ORG,"E"))+1
 ...;S ^OUTPUT(PARENT,ORG,"E",NOR)=""
 ...QUIT
 ..QUIT
 .C FILE
 .QUIT
 QUIT
 
GOLD ;
 K ^GOLD
 S Q1="select p.organization_id, p.id as patient_id, pa.id as patient_address_id, pa.address_line_1, pa.address_line_2, pa.address_line_3, pa.address_line_4, pa.city, pm.uprn, pa.postcode from internal_nel_gp_pid.patient_address_match pm join internal_nel_gp_pid.patient_address_match_gold g on g.uprn=pm.uprn join internal_nel_gp_pid.patient_address pa on pa.id=pm.patient_address_id join internal_nel_gp_pid.patient p on pa.patient_id = p.id where p.current_address_id=pm.patient_address_id"
 S key=^ICONFIG("CHOMES","KEY")
 S zfile="/tmp/gold.txt"
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",key,Q1,zfile)
 C zfile
 O zfile:(readonly)
 U zfile R STR
 F  U zfile R STR Q:$ZEOF  DO
 .S ORG=$P(STR,$C(9))
 .S NOR=$P(STR,$C(9),2)
 .I '$D(^ASUM(NOR)) QUIT
 .S ^GOLD(ORG)=$GET(^GOLD(ORG))+1
 .S ^GOLD(ORG,NOR)=""
 .S PARENT=$P(^ORGZ(ORG),"~",3)
 .S ^OUTPUT(PARENT,ORG,"G")=$GET(^OUTPUT(PARENT,ORG,"G"))+1
 .;S ^OUTPUT(PARENT,ORG,"G",NOR)=""
 .QUIT
 C zfile
 QUIT
 
NOCH ;
 S key=^ICONFIG("CHOMES","KEY")
 S db="internal_nel_gp_pid"
 S Q1="select o.id, o.organization_id, o.patient_id, o.clinical_effective_date, c.code as snomed_code, c.name as original_term, c.description from "_db_".observation o join "_db_".concept c on c.dbid = o.non_core_concept_id where (c.code= 'EMISNQNO158' or c.code = 'EMISNQNO159')"
 S zfile="/tmp/noch.txt"
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",key,Q1,zfile)
 K ^NOCHALL
 close zfile
 open zfile:(readonly)
 use zfile r str
 f  u zfile r str q:$zeof  do
 .S nor=$p(str,$c(9),3)
 .I '$D(^ASUM(nor)) quit
 .s orgid=$P(str,$c(9),2)
 .S dat=$p(str,$c(9),4)
 .s d=$p(dat,"-",3)_"."_$p(dat,"-",2)_"."_$p(dat,"-",1)
 .set h=$$DH^STDDATE(d)
 .S ^NOCHALL(orgid,nor,h)=""
 .quit
 close zfile
 QUIT
 
GO(snomed,key,file,db) 
 S Q1="select o.id, o.organization_id, o.patient_id, c.code as snomed_code, c.name as original_term, c.description, o.clinical_effective_date from "_db_".observation o join "_db_".concept_map cm on cm.legacy= o.non_core_concept_id join "_db_".concept c on c.dbid = cm.core where c.code= '"_snomed_"'"
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",key,Q1,file)
 QUIT
