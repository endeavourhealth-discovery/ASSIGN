CHOMES ; ; 3/30/21 3:30pm
 D REP($J)
 QUIT
 ;
REP(job) ;
 K ^link($j)
 S FILE="/tmp/jsource-"_job_".txt"
 C FILE
 O FILE:(readonly)
 U FILE R STR
 F  U FILE R str Q:$ZEOF  DO
 .I str'["|" Q
 .S uprn=$p(str,"|",1),type=$p(str,"|",2),json=$p(str,"|",3,9999)
 .I type="ODS" S type="TRUD-AD-MATCH"
 .I type="T" S type="CQC-AD-MATCH"
 .S ^link($J,type,uprn)=json
 .QUIT
 CLOSE FILE
 
 ;S FILE="/tmp/registrations-"_job_".txt"
 ;K ^ELREG($J)
 ;C FILE
 ;O FILE:(readonly)
 ;U FILE R STR
 ;F  U FILE R str Q:$ZEOF  DO
 ;.s nor=$p(str,$c(9)),org=$p(str,$c(9),2)
 ;.set ^ELREG($J,nor)=org
 ;.QUIT
 ;CLOSE FILE
 
 ;
 
 ;
 
 ;S FILE="/tmp/closed_orgs-"_job_".txt"
 ;k ^closed($j)
 ;C FILE
 ;O FILE:(readonly)
 ;U FILE R STR
 ;F  U FILE R STR Q:$ZEOF  DO
 ;.S ^closed($j,$p(STR,$C(9)))=""
 ;.QUIT
 ;C FILE
 
 S FILE="/tmp/de-reg_orgs-"_job_".txt"
 k ^closed($j)
 C FILE
 O FILE:(readonly)
 U FILE R STR
 F  U FILE R STR Q:$ZEOF  DO
 .S ^closed($j,$p(STR,$C(9)))=$P(STR,$C(9),2)
 .QUIT
 
 S FILE="/tmp/orgs-"_job_".txt"
 K ^ELORGS($J)
 C FILE
 O FILE:(readonly)
 U FILE R STR
 F  U FILE R STR Q:$ZEOF  DO
 .S ORGID=$P(STR,$C(9),1)
 .S ODSCODE=$P(STR,$C(9),2)
 .S NAME=$P(STR,$C(9),3)
 .S PARENT=$P(STR,$C(9),7)
 .S ^ELORGS($J,ORGID)=NAME_"~"_ODSCODE_"~"_PARENT
 .QUIT
 CLOSE FILE
 
 S FILE="/tmp/carehomes-"_job_".txt"
 K ^CAREHOMES($J)
 C FILE
 O FILE:(readonly)
 USE FILE R STR
 F  U FILE R STR Q:$ZEOF  DO
 .S ORGID=$P(STR,$C(9))
 .S ^CAREHOMES($J,ORGID)=""
 .QUIT
 C FILE
 
 S FILE="/tmp/servicetypes-"_job_".txt"
 C FILE
 O FILE:(readonly)
 U FILE R STR
 K ^SERVT($J)
 F  U FILE R STR Q:$ZEOF  DO
 .S ORGID=$P(STR,$C(9),1)
 .S ST=$P(STR,$C(9),5)
 .S ^SERVT($J,ORGID,ST)=""
 .QUIT
 CLOSE FILE
 
 S FILE="/tmp/specialisms-"_job_".txt"
 C FILE
 O FILE:(readonly)
 U FILE R STR
 K ^OSPEC($J)
 F  U FILE R STR Q:$ZEOF  DO
 .S ORGID=$P(STR,$C(9),1)
 .S ST=$P(STR,$C(9),5)
 .S ^OSPEC($J,ORGID,ST)=""
 .QUIT
 CLOSE FILE
 
 S FILE="/tmp/TRUD-AD-MATCH+CQC-API-"_job_".txt"
 CLOSE FILE
 O FILE:(readonly)
 U FILE R STR
 k ^TOT($J),^csv($j),^SUMM($J)
 k ^csv2($j)
 F  U FILE R str Q:$ZEOF  DO
 .s orgid=$p(str,$c(9))
 .s nor=$p(str,$c(9),2)
 .;;;;;i $data(^closed($J,orgid)) quit
 .;i '$data(^ELREG($J,nor)) quit
 .I '$data(^ASUM(nor)) quit
 .s carehome="n"
 .i $d(^CAREHOMES($J,orgid)) s carehome="y"
 .;if carehome="n" quit
 .;s patorg=^ELREG($job,nor)
 .s patorg=^ASUM(nor)
 .s type=$p(str,$c(9),4)
 .I type="cqc_uprn" s type="CQC-API"
 .I type="ods_disco_uprn" s type="TRUD-AD-MATCH"
 .;
 .S ^TOT($j,type)=$get(^TOT($j,type))+1
 .; *** WRONG
 .;
 .;
 .s add1=$p(str,$c(9),5),add2=$p(str,$c(9),6),add3=$p(str,$c(9),7),add4=$p(str,$c(9),8),city=$p(str,$c(9),9)
 .s uprn=$p(str,$c(9),10),postcode=$p(str,$c(9),11)
 .s address=$s(add1="NULL":"",1:add1)_","_$s(add2="NULL":"",1:add2)_","_$s(add3="NULL":"",1:add3)_","_$s(add4="NULL":"",1:add4)_","_$s(city="NULL":"",1:city)_","_postcode
 .S matchdate=$p(str,$c(9),12)
 .S D=$$DH($P(matchdate," ")),T=$$TH($P(matchdate," ",2))
 .s ^csv($j,patorg,nor,uprn,type)=carehome_"~"_$$st(orgid)_"~"_$$ospec(orgid)_"~"_address
 .s:$d(^closed($j,orgid)) ^csv($j,patorg,nor,uprn,type,"closed")=$g(^closed($j,orgid))
 .s ^csv2($j,patorg,nor,uprn,D,T,type)=carehome_"~"_$$st(orgid)_"~"_$$ospec(orgid)_"~"_address
 .s json=$get(^link($j,type,uprn))
 .s:json'="" ^csv($j,patorg,nor,uprn,type,"ABP")=json
 .s rec=^ELORGS($j,patorg),parent=$p(rec,"~",3)
 .s ^SUMM($j,parent,patorg,nor)=""
 .QUIT
 CLOSE FILE
 
 S FILE="/tmp/CQC-AD-MATCH-"_job_".txt"
 C FILE
 O FILE:(readonly)
 U FILE R STR
 F  U FILE R str q:$zeof  do
 .s orgid=$p(str,$c(9))
 .s nor=$p(str,$c(9),2)
 .;;;;;i $data(^closed($J,orgid)) quit
 .;i '$data(^ELREG($J,nor)) quit
 .i '$data(^ASUM(nor)) quit
 .s carehome="n"
 .i $d(^CAREHOMES($j,orgid)) s carehome="y"
 .;if carehome="n" quit
 .;s patorg=^ELREG($J,nor)
 .S patorg=^ASUM(nor)
 .s type="CQC-AD-MATCH"
 .S ^TOT($J,type)=$get(^TOT($J,type))+1
 .s add1=$p(str,$c(9),4),add2=$p(str,$c(9),5),add3=$p(str,$c(9),6),add4=$p(str,$c(9),7),city=$p(str,$c(9),8)
 .s uprn=$p(str,$c(9),9),postcode=$p(str,$c(9),10)
 .s matchdate=$p(str,$c(9),11)
 .s D=$$DH($P(matchdate," ")),T=$$TH($P(matchdate," ",2))
 .s address=$s(add1="NULL":"",1:add1)_","_$s(add2="NULL":"",1:add2)_","_$s(add3="NULL":"",1:add3)_","_$s(add4="NULL":"",1:add4)_","_$s(city="NULL":"",1:city)_","_postcode
 .s ^csv($j,patorg,nor,uprn,type)=carehome_"~"_$$st(orgid)_"~"_$$ospec(orgid)_"~"_address
 .s:$d(^closed($j,orgid)) ^csv($j,patorg,nor,uprn,type,"closed")=$GET(^closed($j,orgid))
 .s ^csv2($j,patorg,nor,uprn,D,T,type)=carehome_"~"_$$st(orgid)_"~"_$$ospec(orgid)_"~"_address
 .s json=$get(^link($j,type,uprn))
 .s:json'="" ^csv($j,patorg,nor,uprn,type,"ABP")=json
 .s rec=^ELORGS($j,patorg),parent=$p(rec,"~",3)
 .s ^SUMM($J,parent,patorg,nor)=""
 .QUIT
 C FILE
 
 k ^SUMM2($J)
 S (parent,patorg,nor)=""
 f  s parent=$o(^SUMM($J,parent)) q:parent=""  do
 .f  s patorg=$o(^SUMM($J,parent,patorg)) q:patorg=""  do
 ..f  s nor=$o(^SUMM($J,parent,patorg,nor)) q:nor=""  do
 ...s ^SUMM2($j,parent,patorg)=$get(^SUMM2($j,parent,patorg))+1
 
 s f="/tmp/carehomes_summ_v1.csv"
 c f
 o f:(newversion)
 S (parent,patorg)=""
 u f w "org_id,name,ods_code,total",!
 f  s parent=$o(^SUMM2($j,parent)) q:parent=""  do
 .S REC=^ELORGS($j,parent)
 .w !,$P(REC,"~",1),",",$P(REC,"~",2),!
 .f  s patorg=$order(^SUMM2($J,parent,patorg)) q:patorg=""  do
 ..S REC=$GET(^ELORGS($j,patorg))
 ..W patorg,",","""",$P(REC,"~",1),"""",",",$P(REC,"~",2),",",^SUMM2($j,parent,patorg),!
 ..quit
 .quit
 c f
 
 K ^RECON("ORG_V2")
 
 ; build ^RECON("ORG_V2") matchdate fix
 ;s (patorg,nor,uprn,d,t,type)=""
 ;f  s patorg=$o(^csv2($j,patorg)) q:patorg=""  do
 ;.f  s nor=$o(^csv2($j,patorg,nor)) q:nor=""  do
 ;..f  s uprn=$o(^csv2($j,patorg,nor,uprn)) q:uprn=""  do
 ;...f  s d=$o(^csv2($j,patorg,nor,uprn,d)) q:d=""  do
 ;....i $o(^csv2($j,patorg,nor,uprn,d))'="" q
 ;....f  s t=$o(^csv2($j,patorg,nor,uprn,d,t)) q:t=""  do
 ;.....i $o(^csv2($j,patorg,nor,uprn,d,t))'="" q
 ;.....f  s type=$o(^csv2($j,patorg,nor,uprn,d,t,type)) q:type=""  do
 ;......
 
 s f="/tmp/carehomes_by_orgs_v1.csv"
 c f
 o f:(newversion)
 u f w "organization,patient_id,patient_address,P-UPRN,Match type,Match address,cqc_carehome,service_types,specialism",!
 s (patorg,nor,uprn,type)=""
 f  s patorg=$o(^csv($j,patorg)) q:patorg=""  do
 .S REC=$GET(^ELORGS($J,patorg))
 .W $P(REC,"~",1),",",$P(REC,"~",2),!
 .f  s nor=$o(^csv($j,patorg,nor)) q:nor=""  do
 ..f  s uprn=$o(^csv($j,patorg,nor,uprn)) q:uprn=""  do
 ...f  s type=$o(^csv($j,patorg,nor,uprn,type)) q:type=""  do
 ....s rec=^(type)
 ....;S ^RECON("ORG_V2",nor)=""
 ....s address=$p(rec,"~",4),carehome=$p(rec,"~",1),st=$p(rec,"~",2),ospec=$P(rec,"~",3)
 ....;S ^RECON("ORG_V2",patorg,nor,type)=carehome_"~"_st_"~"_ospec
 ....s abpjson=$get(^csv($job,patorg,nor,uprn,type,"ABP"))
 ....s closed=$get(^csv($j,patorg,nor,uprn,type,"closed"))
 ....S ^RECON("ORG_V2",patorg,nor,type)=carehome_"~"_st_"~"_ospec_"~"_abpjson_"~"_uprn_"~"_closed
 ....; decode the json
 ....K B
 ....D DECODE^VPRJSON($NAME(abpjson),$NAME(B),$NAME(E))
 ....S org=$get(B("ABPAddress","Organisaton"))
 ....s street=$get(B("ABPAddress","Street"))
 ....s flat=$get(B("ABPAddress","Flat"))
 ....s build=$get(B("ABPAddress","Building"))
 ....s number=$get(B("ABPAddress","Number"))
 ....s depthro=$get(B("ABPAddress","Dependent_thoroughfare"))
 ....s deploc=$get(B("ABPAddress","Dependent_locality"))
 ....s local=$get(B("ABPAddress","Locality"))
 ....s town=$get(B("ABPAddress","Town"))
 ....s postcode=$get(B("ABPAddress","Postcode"))
 ....s abpadd=org_","_street_","_flat_","_build_","_number_","_depthro_","_deploc_","_local_","_town_","_postcode
 ....i type="CQC-API" S abpadd=""
 ....u f w patorg,",",nor,",","""",address,"""",",",uprn,",",type,",","""",abpadd,"""",",",carehome,",",st,",",ospec,!
 ....quit
 ...quit
 ..w !
 ..quit
 .w !
 .quit
 close f
 
 ;
 QUIT
ospec(orgid) ;
 s s="",specs=""
 f  s s=$o(^OSPEC($J,orgid,s)) q:s=""  d
 .s specs=specs_s_"|"
 .quit
 quit specs
 ;
 
st(orgid) ;
 s st="",stypes=""
 f  s st=$o(^SERVT($J,orgid,st)) q:st=""  do
 .s stypes=stypes_st_"|"
 .quit
 quit stypes
 
GO(db,KEY) ; D GO^CHOMES("internal_nel_gp_pid")
 W !,"getting sources"
 S CURL="curl -s -X GET -i "_^ICONFIG("BASEURL")_"/api2/jsourceall > /tmp/jsource-"_$j_".txt"
 
 ZSYSTEM CURL
 ;QUIT
 
 ;W !,"getting registered patients"
 ; REGISTERED PATIENTS
 ;S Q1="SELECT p.id, p.organization_id FROM "_db_".patient p join "_db_".episode_of_care e on e.patient_id = p.id join "_db_".concept c on c.dbid = e.registration_type_concept_id where c.code = 'R' and p.date_of_death IS NULL and e.date_registered <= now() and (e.date_registered_end > now() or e.date_registered_end IS NULL)"
 ;S FILE="/tmp/registrations-"_$j_".txt"
 ;D STT("2AA7F19EAD0B04A3FD5E",KEY,Q1,FILE)
 ;
 w !,"running TRUD-AD-MATCH+CQC-API sql"
 ; TRUD-AD-MATCH+CQC-API.txt
 S Q2="select oa.id as orgv2_id, p.id as patient_id, pa.id as patient_address_id, name, pa.address_line_1, pa.address_line_2, pa.address_line_3, pa.address_line_4, pa.city, pm.uprn, pa.postcode, pm.match_date from "_db_".organization_additional oa join "_db_".patient_address_match pm on pm.uprn = oa.value join "_db_".patient_address pa on pa.id=pm.patient_address_id join "_db_".patient p on pa.patient_id = p.id where (name = 'ods_disco_uprn' or name = 'cqc_uprn') and p.current_address_id=pm.patient_address_id"
 S FILE="/tmp/TRUD-AD-MATCH+CQC-API-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q2,FILE)
 ;
 ; CQC-AD-MATCH.txt
 ;
 w !,"running CQC-AD-MATCH sql"
 S Q3="select l.managing_organization_id as orgv2_id, p.id as patient_id, pa.id as patient_address_id, pa.address_line_1, pa.address_line_2, pa.address_line_3, pa.address_line_4, pa.city, pm.uprn, pa.postcode, pm.match_date from "_db_".patient_address_match pm join "_db_".location_v2 l on l.uprn=pm.uprn join "_db_".patient_address pa on pa.id=pm.patient_address_id join "_db_".patient p on pa.patient_id = p.id where p.current_address_id=pm.patient_address_id"
 S FILE="/tmp/CQC-AD-MATCH-"_$J_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q3,FILE)
 ;
 ; CLOSED_ORGS
 w !,"running closed orgs sql"
 S Q4="select id as orgv2_id, value from "_db_".organization_additional oa where name='close_date'"
 S FILE="/tmp/closed_orgs-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q4,FILE)
 ;
DZ w !,"running deregistered sql"
 S QZ="select id as orgv2_id, value from "_db_".organization_additional oa where name='cqc_deregdate'"
 S FILE="/tmp/de-reg_orgs-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,QZ,FILE)
 
 ; ORGS
 w !,"running get orgs sql"
 S Q5="select * from "_db_".organization"
 S FILE="/tmp/orgs-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q5,FILE)
 
 ;
 ;
 w !,"running care home flag sql"
 S Q6="SELECT * FROM "_db_".organization_additional where name = 'cqc_carehome' and value = 'Y'"
 S FILE="/tmp/carehomes-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q6,FILE)
 
 w !,"running service_type sql"
 S Q7="SELECT * FROM "_db_".organization_additional where name = 'service_type'"
 S FILE="/tmp/servicetypes-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q7,FILE)
 
 w !,"running specialism sql"
 S Q8="SELECT * FROM "_db_".organization_additional where name = 'specialisms/services'"
 S FILE="/tmp/specialisms-"_$j_".txt"
 D STT("2AA7F19EAD0B04A3FD5E",KEY,Q8,FILE)
 QUIT
 
 ; D STT^CHOMES("2AA7F19EAD0B04A3FD5E",KEY)
STT(RC4PASS,KEY,QUERY,FILE) ;
 ;
 S HOST=^ICONFIG("CHOMES","HOST")
 ;
 S USER=^ICONFIG("CHOMES","USER")
 ;
 S PASS=$$DERCFOUR^EWEBRC4(RC4PASS,KEY)
 I PASS="" U 0 W !,"PASS IS NULL" QUIT
 U 0 W !,PASS
 ;
 D QUERIES(HOST,USER,PASS,QUERY,FILE)
 QUIT
 
 ; RUN QUERY
QUERIES(HOST,USER,PASS,QUERY,FILE) ;
 ;
 S PATH=$GET(^ICONFIG("CHOMES","MYSQL-PATH"))
 I PATH="" S PATH="/usr/bin/mysql"
 ;S FILE="/tmp/temp-"_$j_".txt"
 S CMD=PATH_" -h "_HOST_" --user="_USER_" --password="_PASS_" --execute """_QUERY_""" > "_FILE
 W !,CMD
 ZSYSTEM CMD
 QUIT
 
TH(%TM) ;
 D %CTN^%H
 Q %TIM
 
DH(DAT) ; 2021-02-08
 S D=$P(DAT,"-",3)_"."_$P(DAT,"-",2)_"."_$P(DAT,"-",1)
 Q $$DH^STDDATE(D)
