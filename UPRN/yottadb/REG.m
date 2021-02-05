REG ; GETS A LIST OF CURRENTLY REGISTERED PATIENTS ; 2/3/21 7:55pm
 ;
 ; D RUN^REG("2AA7F19EAD0B04A3FD5E","KEY","internal_nel_gp_pid")
RUN(pass,key,db) ;
 n file
 S file="/tmp/active_orgs.txt"
 S Q1="SELECT * FROM "_db_".organization oz where (select id from "_db_".observation o where oz.id=o.organization_id limit 1)"
 D STT^CHOMES(pass,key,Q1,file)
 C file
 O file:(readonly)
 S key=^ICONFIG("CHOMES","KEY")
 u file r str
 F  u file r str q:$zeof  do
 .;u 0 w !,str
 .S orgid=$p(str,$c(9))
 .D NOCH(pass,key,db,orgid)
 .quit
 close file
 QUIT
 
 ; D NOCH^REG("2AA7F19EAD0B04A3FD5E","KEY","internal_nel_gp_pid")
NOCH(pass,key,db,orgid) ; no longer lives in a care home
 ;n file
 S Q1="select o.id, o.organization_id, o.patient_id, o.clinical_effective_date, c.code as snomed_code, c.name as original_term, c.description from "_db_".observation o join "_db_".concept c on c.dbid = o.non_core_concept_id where (c.code= 'EMISNQNO158' or c.code = 'EMISNQNO159') and o.organization_id='"_orgid_"'"
 S zfile="/tmp/noch-"_$j_".txt"
 D STT^CHOMES(pass,key,Q1,zfile)
 K ^NOCH(orgid)
 close zfile
 open zfile:(readonly)
 use zfile r str
 i str'="" do
 .f  u zfile r str q:$zeof  do
 ..S nor=$p(str,$c(9),3)
 ..S dat=$p(str,$c(9),4)
 ..s d=$p(dat,"-",3)_"."_$p(dat,"-",2)_"."_$p(dat,"-",1)
 ..set h=$$DH^STDDATE(d)
 ..u 0 w !,nor
 ..S ^NOCH(orgid,nor,h)=orgid
 ..quit
 .quit
 close zfile
 QUIT
 
 ; D STT^REG("2AA7F19EAD0B04A3FD5E","KEY","internal_nel_gp_pid")
STT(pass,key,db) ;
 S Q1="SELECT p.id, p.date_of_birth, p.gender_concept_id, p.organization_id, pa.address_line_1, pa.address_line_2, pa.address_line_3, pa.address_line_4, pa.city, pa.postcode FROM "_db_".patient p join "_db_".episode_of_care e on e.patient_id = p.id join "_db_".concept c on c.dbid = e.registration_type_concept_id join "_db_".patient_address pa on pa.id=p.current_address_id where c.code = 'R' and p.date_of_death IS NULL and e.date_registered <= now() and (e.date_registered_end > now() or e.date_registered_end IS NULL)"
 ;quit
 
 S file="/tmp/registered-"_$j_".txt"
 W !,"Running SQL"
 D STT^CHOMES(pass,key,Q1,file)
 W !,"Finished running SQL"
 K ^ASUM
 close file
 open file:(readonly)
 u file r str
 f  u file r str q:$zeof  do
 .s nor=$p(str,$c(9),1)
 .s org=$p(str,$c(9),4)
 .S gender=$p(str,$c(9),3)
 .s dob=$p(str,$c(9),2)
 .s add1=$p(str,$c(9),5)
 .S:add1="NULL" add1=""
 .s add2=$p(str,$c(9),6)
 .S:add2="NULL" add2=""
 .s add3=$p(str,$c(9),7)
 .s:add3="NULL" add3=""
 .s add4=$p(str,$c(9),8)
 .s:add4="NULL" add4=""
 .s city=$p(str,$c(9),9)
 .s:city="NULL" city=""
 .s postcode=$p(str,$c(9),10)
 .s:postcode="NULL" postcode=""
 .S ^ASUM(nor)=org
 .S ^ASUM(nor,"gender")=gender
 .S ^ASUM(nor,"age")=$$AGE(dob)
 .S ^ASUM(nor,"address")=add1_"~"_add2_"~"_add3_"~"_add4_"~"_city_"~"_postcode
 .quit
 close file
 QUIT
 
AGE(dob) ;
 S TDAY=$$DA^STDDATE($$HD^STDDATE(+$H))
 S TDOB=$P(dob,"-",3)_"."_$P(dob,"-",2)_"."_$P(dob,"-")
 S JN=$$DA^STDDATE(TDOB)
 S DA2=$A($E(TDAY,5)),MO2=$A($E(TDAY,4)),YEC2=($A($E(TDAY,1))-33)_($A($E(TDAY,2))-33)_($A($E(TDAY,3))-33)
 S DA1=$A($E(JN,5)),MO1=$A($E(JN,4)),YEC1=($A($E(JN,1))-33)_($A($E(JN,2))-33)_($A($E(JN,3))-33)
 S YEARS=YEC2-YEC1
 I MO2>MO1 Q YEARS
 I MO2<MO1 S YEARS=YEARS-1 Q YEARS
 I DA2>DA1 Q YEARS
 I DA2<DA1 S YEARS=YEARS-1 Q YEARS
 Q YEARS
