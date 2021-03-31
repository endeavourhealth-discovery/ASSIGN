RECON ; ; 3/30/21 3:43pm
 ;
 ; D STT^RECON("394923006","1407334","KEY","/tmp/394923006.txt","internal_nel_gp_pid")
 ; D STT^RECON("160734000","1407334","KEY","/tmp/160734000.txt","internal_nel_gp_pid")
 ; D STT^RECON("248171000000108","1407334","KEY","/tmp/248171000000108.txt","internal_nel_gp_pid")
COLLECTSNO(orgid) ; D COLLECTSNO^RECON("1407334")
 S key=^ICONFIG("CHOMES","KEY")
 D NOCH^REG("2AA7F19EAD0B04A3FD5E",key,"internal_nel_gp_pid",orgid)
 ; "1407334"
 D STT^RECON("394923006",orgid,key,"/tmp/394923006.txt","internal_nel_gp_pid")
 D STT^RECON("160734000",orgid,key,"/tmp/160734000.txt","internal_nel_gp_pid")
 D STT^RECON("248171000000108",orgid,key,"/tmp/248171000000108.txt","internal_nel_gp_pid")
 D MERGE(orgid)
 QUIT
 ;
STT(snomed,orgid,key,file,db) ;
 S Q1="select o.id, o.organization_id, o.patient_id, c.code as snomed_code, c.name as original_term, c.description, o.clinical_effective_date from "_db_".observation o join "_db_".concept_map cm on cm.legacy = o.non_core_concept_id join "_db_".concept c on c.dbid = cm.core where c.code= '"_snomed_"' and o.organization_id = '"_orgid_"'"
 ;W !,Q1
 D STT^CHOMES("2AA7F19EAD0B04A3FD5E",key,Q1,file)
 QUIT
 
REP ;
 ; D STT^REG("2AA7F19EAD0B04A3FD5E","KEY-BLAH","internal_nel_gp_pid")
 ; merge each of the snomed files into a list of patient_ids
 ; then, check if the patient is registered
 D MERGE
 QUIT
 
MERGE(orgid) ;
 ;K ^TSNO($J)
 K ^RECON("SNO")
 F FILE="248171000000108","160734000","394923006" DO
 .S F="/tmp/"_FILE_".txt"
 .C F
 .O F:(readonly)
 .U F R STR
 .F  U F R STR Q:$ZEOF  DO
 ..;U 0 W !,$P(STR,$C(9),3)
 ..S NOR=$P(STR,$C(9),3)
 ..S ORG=$P(STR,$C(9),2)
 ..S dat=$P(STR,$C(9),7)
 ..;U 0 W !,DAT R *Y
 ..S d=$p(dat,"-",3)_"."_$p(dat,"-",2)_"."_$p(dat,"-")
 ..S h=$$DH^STDDATE(d)
 ..I '$D(^ASUM(NOR)) quit
 ..; left care home?
 ..; and is the sno_clin_date < left_clin_date
 ..s left=$order(^NOCH(orgid,NOR,""),-1)
 ..;u 0 W !,+left,">",h
 ..i +left>h u 0 w !,NOR," no longer lives in care home" q
 ..S ^RECON("SNO",ORG,NOR,FILE)=""
 ..QUIT
 .QUIT
 CLOSE F
 QUIT
 ;
LIST(ORG) ;
 ;F NODE="ORG_V2","SNO" DO
 F NODE="SNO" DO
 .S NOR=""
 .S F="/tmp/"_NODE_".txt"
 .C F
 .O F:(newversion)
 .F  S NOR=$O(^RECON(NODE,ORG,NOR)) Q:NOR=""  DO
 ..U F W NOR,!
 ..QUIT
 .CLOSE F
 .QUIT
 
 S (NOR,TYPE)=""
 S F="/tmp/ORG_V2.txt"
 C F
 O F:(newversion)
 U F
 F  S NOR=$O(^RECON("ORG_V2",ORG,NOR)) Q:NOR=""  DO
 .W NOR,","
 .F  S TYPE=$O(^RECON("ORG_V2",ORG,NOR,TYPE)) Q:TYPE=""  DO
 ..W ^(TYPE),"~"
 ..QUIT
 .W !
 .QUIT
 C F
 QUIT
 
CROSS1(ORG) ;
 K ^TMP($J)
 ; ID IF ANY OF THE SOURCES THINK THIS PAT LIVE IN A CAREHOME?
 S (NOR,TYPE)=""
 F  S NOR=$O(^RECON("ORG_V2",ORG,NOR)) Q:NOR=""  DO
 .F  S TYPE=$O(^RECON("ORG_V2",ORG,NOR,TYPE)) Q:TYPE=""  DO
 ..S REC=^(TYPE)
 ..I $P(REC,"~",1)="y" S ^TMP($J,"ORG_V2",NOR)="y"
 ..Q
 .I '$D(^TMP($J,"ORG_V2",NOR)) S ^TMP($J,"ORG_V2",NOR)="n"
 .QUIT
 S (NOR,SNO)=""
 K ^TDONE($J)
 F  S NOR=$O(^RECON("SNO",ORG,NOR)) Q:NOR=""  DO
 .F  S SNO=$O(^RECON("SNO",ORG,NOR,SNO)) Q:SNO=""  DO
 ..S ^TMP($J,"SNO",SNO)=$GET(^TMP($J,"SNO",SNO))+1
 ..; HAS THIS PATIENT  ALREADY BEEN COUNTED?
 ..I $D(^TDONE($J,NOR)) QUIT
 ..;S ^TDONE($J,NOR)=""
 ..I $GET(^TMP($J,"ORG_V2",NOR))="y" S ^TMP($J,"s",SNO,"y")=$get(^TMP($J,"s",SNO,"y"))+1,^TDONE($J,NOR)=""
 ..I $GET(^TMP($J,"ORG_V2",NOR))="n" S ^TMP($J,"s",SNO,"n")=$get(^TMP($J,"s",SNO,"n"))+1
 ..I $GET(^TMP($J,"ORG_V2",NOR))="" S ^TMP($J,"s",SNO,"nf")=$get(^TMP($J,"s",SNO,"nf"))+1
 ..QUIT
 .;S ^TDONE($J,NOR)=""
 .QUIT
 D CROSS
 QUIT
 
CROSS ; cross-tab
 S SNO=""
 S LINCH="248171000000108"
 S LINNH="160734000"
 S LINRC="394923006"
 
 S F="/tmp/cross_tab.csv"
 C F
 O F:(newversion)
 USE F
 W ",uprn assigned cqc ch,not asigned cqc ch,record not found,total",!
 W "snomed lives in ch,"
 
 ;S TOTA=$G(^TMP($J,"s",LINCH,"y"))+$G(^TMP($J,"s",LINCH,"n"))+$G(^TMP($J,"s",LINCH,"nf"))
 
 W $G(^TMP($J,"s",LINCH,"y")),",",$G(^TMP($J,"s",LINCH,"n")),",",$G(^TMP($J,"s",LINCH,"nf"))
 W !
 
 W "snomed lives in nh,"
 W $G(^TMP($J,"s",LINNH,"y")),",",$G(^TMP($J,"s",LINNH,"n")),",",$G(^TMP($J,"s",LINNH,"nf"))
 W !
 
 W "snomed lives in rc,"
 W $G(^TMP($J,"s",LINRC,"y")),",",$G(^TMP($J,"s",LINRC,"n")),",",$G(^TMP($J,"s",LINRC,"nf"))
 W !
 
 CLOSE F
 
 QUIT
 
LINELVL(ORG) ;
 ; collect all the patient ids
 S F="/tmp/line_level_"_ORG_".csv"
 C F
 O F:(newversion)
 USE F
 K ^TPATS($J)
 F NODE="SNO","ORG_V2" DO
 .S NOR=""
 .F  S NOR=$O(^RECON(NODE,ORG,NOR)) Q:NOR=""  DO
 ..;
 ..S ^TPATS($J,NOR)=""
 ..QUIT
 .QUIT
 W "patient_id,uprn,snomed,match_type,care home,service_type,specialism,age,sex,add1,add2,add3,add4,city,postcode,abp_flat,abp_building,abp_number,abp_dep_throughfare,abp_street,abp_dep_locality,abp_locality,abp_town,abp_postcode,abp_organization,de-registered",!
 S NOR=""
 F  S NOR=$O(^TPATS($J,NOR)) Q:NOR=""   DO
 .S SNO=""
 .F  S SNO=$O(^RECON("SNO",ORG,NOR,SNO)) Q:SNO=""  DO
 ..I '$D(^ASUM(NOR)) QUIT
 ..;I $D(^closed($j,ORG)) Quit
 ..S AGE=^ASUM(NOR,"age")
 ..S A=^ASUM(NOR,"address")
 ..S ADD1=$P(A,"~",1),ADD2=$P(A,"~",2),ADD3=$P(A,",",3)
 ..S ADD4=$P(A,"~",4),CITY=$P(A,"~",5),POSTCODE=$P(A,"~",6)
 ..S GENDER=^ASUM(NOR,"gender")
 ..I GENDER=1335245 S GENDER="F"
 ..I GENDER=1335244 S GENDER="M"
 ..W NOR,",,",SNO,",,,,,",AGE,",",GENDER,","
 ..W ADD1,",",ADD2,",",ADD3,",",ADD4,",",CITY,",",POSTCODE
 ..W !
 ..QUIT
 .S TYPE=""
 .F  S TYPE=$O(^RECON("ORG_V2",ORG,NOR,TYPE)) Q:TYPE=""  DO 
 ..S REC=^(TYPE)
 ..S CH=$P(REC,"~"),ST=$P(REC,"~",2),SPEC=$P(REC,"~",3)
 ..S J=$P(REC,"~",4),UPRN=$P(REC,"~",5),CLOSED=$P(REC,"~",6)
 ..K B
 ..D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 ..S AGE=^ASUM(NOR,"age")
 ..S A=^ASUM(NOR,"address")
 ..S ADD1=$P(A,"~",1),ADD2=$P(A,"~",2),ADD3=$P(A,",",3)
 ..S ADD4=$P(A,"~",4),CITY=$P(A,"~",5),POSTCODE=$P(A,"~",6)
 ..S ABPFLAT=$GET(B("ABPAddress","Flat"))
 ..S ABPBUILD=$GET(B("ABPAddress","Building"))
 ..S ABPNUM=$GET(B("ABPAddress","Number"))
 ..s ABPTFARE=$GET(B("ABPAddress","Dependent_thoroughfare"))
 ..S ABPSTREET=$GET(B("ABPAddress","Street"))
 ..S ABPDEPLOCAL=$GET(B("ABPAddress","Dependent_locality"))
 ..S ABPLOCALITY=$GET(B("ABPAddress","Locality"))
 ..S ABPTOWN=$GET(B("ABPAddress","Town"))
 ..S ABPPOSTCODE=$GET(B("ABPAddress","Postcode"))
 ..S ABPORG=$GET(B("ABPAddress","Organisation"))
 ..S GENDER=^ASUM(NOR,"gender")
 ..I GENDER=1335245 S GENDER="F"
 ..I GENDER=1335244 S GENDER="M"
 ..;BREAK:J'=""
 ..W NOR,",",UPRN,",,",TYPE,",",CH,",",ST,",",SPEC,",",AGE,",",GENDER,","
 ..W ADD1,",",ADD2,",",ADD3,",",ADD4,",",CITY,",",POSTCODE,","
 ..W ABPFLAT,",",ABPBUILD,",",ABPNUM,",",ABPTFARE,",",ABPSTREET,","
 ..W ABPDEPLOCAL,",",ABPLOCALITY,",",ABPTOWN,",",ABPPOSTCODE,",",ABPORG,",",$s(CLOSED'="":"y",1:"")
 ..W !
 ..QUIT
 .W !
 .QUIT
 C F
 QUIT
