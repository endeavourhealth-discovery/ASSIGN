QA ; ; 7/8/21 12:56pm
 ;
 set ^%W(17.6001,"B","POST","api2/postit","POST^QA",248)=""
 set ^%W(17.6001,248,0)="POST"
 set ^%W(17.6001,248,1)="api2/postit"
 set ^%W(17.6001,248,2)="POST^QA"
 set ^%W(17.6001,248,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","api2/getqa","GETQA^QA",250)=""
 S ^%W(17.6001,250,"AUTH")=2
 S ^%W(17.6001,250,0)="GET"
 S ^%W(17.6001,250,1)="api2/getqa"
 S ^%W(17.6001,250,2)="GETQA^QA"
 
 quit
 
ZCEG ;
 K ^NOR
 S F="/tmp/zceg.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S STR=$$TR^LIB(STR,$C(13),"")
 .;U 0 W !,STR,"~",^NOPE(STR)
 .U 0 W !,STR
 .S ADRID=""
 .F  S ADRID=$O(^NOPE(STR,ADRID)) Q:ADRID=""  DO
 ..S NOR=$GET(^REG2(ADRID))
 ..I NOR="" QUIT
 ..U 0 W !,"adr: ",ADRID," nor: ",^REG2(ADRID)
 ..S ^NOR(NOR)=""
 ..QUIT
 .U 0 W !
 .;R *Y
 .QUIT
 C F
 
 S F="/tmp/nor.txt"
 CLOSE F
 O F:(newversion)
 S NOR=""
 F  S NOR=$O(^NOR(NOR)) Q:NOR=""  DO
 .U F W NOR,!
 .QUIT
 CLOSE F
 QUIT
 
RUN ;
 S ADR=""
 F  S ADR=$O(^UN(ADR)) Q:ADR=""  DO
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .W !,ADR
 .W !,$GET(^temp($j,1))
 .R *Y
 .QUIT
 QUIT
 
NOPE2 ;
 S ADR=""
 F  S ADR=$O(^NOPE(ADR)) Q:ADR=""  DO
 .K ^TPARAMS($J)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .K B
 .D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .S UPRN=$GET(B("UPRN"))
 .I UPRN'="" W !,ADR," * ",UPRN
 .QUIT
 QUIT
 
STEP7A ; ADDRESSES THAT NOW RETURN A UPRN
 ; ALSO CHECK IF THE ADDRESS CANDIDATE IS MISSING FROM patient_address_match?
 S ADR=""
 S (T,C)="",COUNT=1
 S F2="/tmp/QAREPORT.nope.txt"
 C F2
 O F2:(newversion)
 
 S NEPOCH=^ICONFIG("EPOCH")
 S NALG=^ICONFIG("ALG-VERSION")
 
 F  S ADR=$O(^NOPE(ADR)) Q:ADR=""  DO
 .K B
 .K ^TPARAMS($J)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .I $GET(B("UPRN"))'="" DO
 ..;W !,ADR," * ",B("UPRN") S C=C+1
 ..; CALL LIVE TO SEE IF MISSING FROM patient_address_match?
 ..S J=$$CURL(ADR)
 ..K ZB
 ..D DECODE^VPRJSON($NAME(J),$NAME(ZB),$NAME(E))
 ..S FINEE=""
 ..I $GET(ZB("UPRN"))'="" S FINEE="?"
 ..S PATADRID=""
 ..S D=$C(9)
 ..S (XEPOCH,XALG,XUPRN,XMATCHRULE,XQUAL,XCLASSCODE,XSTARTDATE,XPOSTCODE)=""
 ..;S NEPOCH=76
 ..;S NALG="4.2.1c"
 ..S (ID,FINEN)=""
 ..S NUPRN=$GET(B("UPRN")),NMATCHRULE=$GET(B("Algorithm")),NQUAL=$GET(B("Qualifier"))
 ..S NCLASSCODE=$GET(B("Classification")),NSTARTDATE="",NPOSTCODE=$GET(B("ABPAddress","Postcode"))
 ..F  S PATADRID=$O(^NOPE(ADR,PATADRID)) Q:PATADRID=""  DO
 ...U F2
 ...W COUNT,D,PATADRID,D,ID,D,ADR,D,XEPOCH,D,XALG,D,XUPRN,D,XMATCHRULE,D,XQUAL,D,XCLASSCODE,D,XSTARTDATE,D,XPOSTCODE,D
 ...W NEPOCH,D,NALG,D,NUPRN,D,NMATCHRULE,D,NQUAL,D,NCLASSCODE,D,NSTARTDATE,D,NPOSTCODE,D,FINEE,D,FINEN
 ...W !
 ...S COUNT=COUNT+1
 ...QUIT
 ..QUIT
 .S T=T+1
 .QUIT
 CLOSE F2
 
 W !,C
 W !,T
 
 D DISTINCT
 QUIT
 
DISTINCT ;
 K ^TDONE($J)
 S F2="/tmp/QAREPORT.nope.1.txt"
 S F="/tmp/QAREPORT.nope.txt"
 C F,F2
 O F:(readonly)
 O F2:(newversion)
 F  U F R STR Q:$ZEOF  DO
 .;U 0 W !,STR
 .;I $D(^TDONE($J,ADR)) QUIT
 .S ADR=$P(STR,$C(9),4)
 .I $D(^TDONE($J,ADR)) QUIT
 .S ^TDONE($J,ADR)=""
 .U 0 W !,ADR
 .U F2 W STR,!
 .QUIT
 CLOSE F,F2
 QUIT
 
CURL(ADR) ;
 S ADR=$$TR^LIB(ADR," ","%20")
 S ADR=$$TR^LIB(ADR,"'","%27")
 U 0 W !,ADR
 S URL="https://"_^ICONFIG("BASE")_"/api2/getinfo?adrec="_ADR_" > /tmp/curl.txt"
 S CMD="curl -s -u "_^U_":"_^P_" "_URL
 zsystem CMD
 S J=""
 S F="/tmp/curl.txt"
 CLOSE F
 O F:(readonly)
 ; Q:$ZEOF
 F  U F R STR Q:STR=""  S J=J_STR
 C F
 QUIT J
 
 ; include addresses not in patient_address_match, but now return a UPRN
 ; *** REDUNDANT ***
STEP7(Q) ; 
 S ADR="",T=0,C=0
 F  S ADR=$O(^CANDS(Q,ADR)) Q:ADR=""  DO
 .I $D(^CANDS(Q,ADR,"IDS")) QUIT
 .K ^TPARAMS($J)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .K B
 .D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .;W !,ADR
 .S C=C+1
 .I $GET(B("UPRN"))'="" W !,">> ",ADR S T=T+1
 .I C#500=0 W !,C," (",T,")"
 .QUIT
 QUIT
 
STEP6(Q) ; UPDATE SYSTEM TO EPOCH 76 (DONE)
 ; RUN THE CANDIDATE ADDRESSES BACK THROUGH THE SYSTEM
 S ADR="",ZC=1
 
 S COUNT=1
 S D=$C(9)
 
 S F2="/tmp/NQAREPORT("_Q_").txt"
 CLOSE F2
 O F2:(newversion)
 
 ;S ADR="175 lea bridge road,,,,london,e107pn"
 S ADR=""
 
 S NEPOCH=^ICONFIG("EPOCH")
 S NALG=^ICONFIG("ALG-VERSION")
 
 F  S ADR=$O(^CANDS(Q,ADR)) Q:ADR=""  DO
 .; patient_address_match UPRN
 .S UPRN=^CANDS(Q,ADR)
 .; get epoch-76 UPRN by running the address through the algorithm
 .K ^TPARAMS($J)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .K B
 .D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .S UPRN76=$GET(B("UPRN"))
 .I UPRN76'=UPRN DO
 ..;U 0 W !,UPRN76," * ",UPRN ; R *Y
 ..S C=""
 ..F  S C=$O(^CANDS(Q,ADR,"IDS",C)) Q:C=""  DO
 ...S REC=^(C)
 ...S ID=$P(REC,"~",1),PATADRID=$P(REC,"~",2)
 ...S XEPOCH=$P(REC,"~",3),XALG=$P(REC,"~",4),XUPRN=$P(REC,"~",5),XMATCHRULE=$P(REC,"~",6),XQUAL=$P(REC,"~",7)
 ...S XCLASSCODE=$P(REC,"~",8),XSTARTDATE=$P(REC,"~",9),XPOSTCODE=$P(REC,"~",10)
 ...I XEPOCH="NULL" S XEPOCH=75
 ...S NUPRN=$GET(B("UPRN")),NMATCHRULE=$GET(B("Algorithm")),NQUAL=$GET(B("Qualifier"))
 ...S NCLASSCODE=$GET(B("Classification")),NSTARTDATE="",NPOSTCODE=$GET(B("ABPAddress","Postcode"))
 ...; Flag if new UPRN exists on existing Epoch (Y/N)
 ...S FINEE=$$FLAG(UPRN76,XEPOCH) ; 75
 ...; Flag if new UPRN exists on new Epoch (Y/N)
 ...S FINEN=$$FLAG(UPRN76,NEPOCH) ; 76
 ...USE F2
 ...W COUNT,D,PATADRID,D,ID,D,ADR,D,XEPOCH,D,XALG,D,XUPRN,D,XMATCHRULE,D,XQUAL,D,XCLASSCODE,D,XSTARTDATE,D,XPOSTCODE,D
 ...W NEPOCH,D,NALG,D,NUPRN,D,NMATCHRULE,D,NQUAL,D,NCLASSCODE,D,NSTARTDATE,D,NPOSTCODE,D,FINEE,D,FINEN
 ...W !
 ...;R *Y
 ...S COUNT=COUNT+1
 ...QUIT
 ..QUIT
 .U 0 W !,ZC
 .I ZC#50=0 U 0 W !,ZC
 .S ZC=ZC+1
 .QUIT
 
 CLOSE F2
 
 QUIT
 
FLAG(UPRN,EPOCH) ;
 ; CHECK IF UPRN EXISTS IN BASELINE?
 S FLAG="N"
 I $D(^OS(EPOCH,"BLPU",UPRN)) S FLAG="Y"
 I $D(^OS(EPOCH,"DPA",UPRN)) S FLAG="Y"
 I $D(^OS(EPOCH,"LPI",UPRN)) S FLAG="Y"
 QUIT FLAG
 
STEP5(F,D) ;
 K ^CEGADR
 ;S F="/tmp/ceg-adr.txt"
 O F:(readonly)
 U F R STR,STR
 F  U F R STR Q:$ZEOF  DO
 .S STR=$$TR^LIB(STR,$C(13),"")
 .;S STR=$$LC^LIB(STR)
 .S REC=$P(STR,D,2,99)
 .S REC=$TR(REC,D,"~")
 .S ID=$P(STR,D,1)
 .F I=1:1:$L(REC,"~") I $P(REC,"~",I)="NULL" S $P(REC,"~",I)=""
 .;S REC=$TR(REC,"~",",")
 .;F I=1:1:$L(REC,"~") I $P(REC,"~",I)="NULL" S $P(REC,"~",I)=""
 .S ^CEGADR(ID)=$$LC^LIB(REC)
 .QUIT
 CLOSE F
 QUIT
 
Q(Q) ;
 S Q=Q+1
 I Q>4 S Q=1
 QUIT Q
 
REG2(F,D) ; LOAD THE CURRENT ADDRESS IDS OF ALL REGISTERED PATIENTS
 K ^REG2
 ;S F="/tmp/reg2.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S STR=$$TR^LIB(STR,$C(13),"")
 .S NOR=$P(STR,D,1)
 .S ADRID=$P(STR,D,2)
 .S ^REG2(ADRID)=NOR
 .S ^REG2(ADRID,NOR)=""
 .QUIT
 CLOSE F
 QUIT
 
CNT ;
 K ^CNT
 S (ADRID,NOR)=""
 F  S ADRID=$O(^REG2(ADRID)) Q:ADRID=""  DO
 .F  S NOR=$O(^REG2(ADRID,NOR)) Q:NOR=""  DO
 ..S ^CNT(ADRID)=$GET(^CNT(ADRID))+1
 QUIT
 
STEP5A(F,D) ;S F="/tmp/ceg-patient-address-match.txt"
 CLOSE F
 K ^CANDS,^CIDX
 O F:(readonly)
 S Q=0
 U F R STR,STR
 S ZC=1
 F  U F R STR Q:$ZEOF  DO
 .S STR=$$TR^LIB(STR,$C(13),"")
 .S STR=$TR(STR,D,"~")
 .S ID=$P(STR,"~",1)
 .S ADRID=$P(STR,"~",2)
 .; CURRENT ADDRESS ID OF A REGISTERED PATIENT?
 .I '$D(^REG2(ADRID)) QUIT
 .S POSTCODE=$P(STR,"~",9)
 .S UPRN=$P(STR,"~",3)
 .S XEPOCH=$P(STR,"~",4)
 .S XALG=$P(STR,"~",5)
 .S XUPRN=$P(STR,"~",3)
 .S XMATCHRULE=$P(STR,"~",6)
 .S XQUAL=$P(STR,"~",7)
 .S XCLASSCODE=$P(STR,"~",8)
 .S XSTARTDATE=""
 .S XPOSTCODE=$P(STR,"~",9)
 .;U 0 W !,POSTCODE
 .;U 0 W !,^CEGADR(ADRID)
 .;U 0 R *Y
 .S STR2=$GET(^CEGADR(ADRID))
 .I STR2="" U 0 W !,"? ",ADRID QUIT
 .; CONSTRUCT ADDRESS CANDIDATE
 .;
 .S ADR=$P(STR2,"~",1)_","_$P(STR2,"~",2)_","_$P(STR2,"~",3)_","_$P(STR2,"~",4)_","_$P(STR2,"~",5)_","_$P(STR2,"~",6)
 .S ADR=$$LC^LIB(ADR)
 .; reduce the amout of processing - and duplicates
 .I $D(^CIDX(ADR)) QUIT
 .S Q=$$Q(Q)
 .S ^CIDX(ADR)=""
 .S ^CANDS(Q,ADR)=UPRN
 .S C=$O(^CANDS(Q,ADR,"IDS",""),-1)+1
 .S ^CANDS(Q,ADR,"IDS",C)=ID_"~"_ADRID_"~"_XEPOCH_"~"_XALG_"~"_XUPRN_"~"_XMATCHRULE_"~"_XQUAL_"~"_XCLASSCODE_"~"_XSTARTDATE_"~"_XPOSTCODE
 .I ZC#10000=0 U 0 W !,ZC
 .S ZC=ZC+1
 .QUIT
 CLOSE F
 
 ;QUIT
 
STEP5C ; ADD THE ADR CANDIDATES TO ^CANDS WHERE THERE IS NO PATIENT_ADDRESS_MATCH RECORD IN THE SYSTEM
 W !,"STEP-C"
 ;R *Y
 
 K ^NOPE
 
 S ADRID="",ZC=1
 S Q=0
 F  S ADRID=$O(^CEGADR(ADRID)) Q:ADRID=""  DO
 .I '$D(^REG2(ADRID)) QUIT
 .S STR2=^CEGADR(ADRID)
 .;
 .S ADR=$P(STR2,"~",1)_","_$P(STR2,"~",2)_","_$P(STR2,"~",3)_","_$P(STR2,"~",4)_","_$P(STR2,"~",5)_","_$P(STR2,"~",6)
 .S ADR=$$LC^LIB(ADR)
 .;
 .I '$D(^CIDX(ADR)) S ^NOPE(ADR,ADRID)=ADRID
 .I ZC#10000=0 W !,ZC
 .S ZC=ZC+1
 .QUIT
 QUIT
 
NOPE ;
 S F="/tmp/nope_ceg_gp.txt"
 C F
 O F:(newversion)
 S ADR=""
 F  S ADR=$O(^NOPE(ADR)) Q:ADR=""  DO
 .U F W ADR,!
 .QUIT
 CLOSE F
 QUIT
 
STEP4 ;
 K ^CHK
 S UPRN=""
 F  S UPRN=$O(^PM(UPRN)) Q:UPRN=""  DO
 .F EPOCH=76:1:81 DO
 ..I $D(^OS(EPOCH,"BLPU",UPRN)) W !,"BLPU: ",UPRN S ^CHK(EPOCH,UPRN)=""
 ..I $D(^OS(EPOCH,"LPI",UPRN)) W !,"LPI: ",UPRN S ^CHK(EPOCH,UPRN)=""
 ..I $D(^OS(EPOCH,"DPA",UPRN)) W !,"DPA: ",UPRN S ^CHK(EPOCH,UPRN)=""
 .QUIT
 ;
 QUIT
 
STEP3 ;
 K ^OS
 F ZZ=75:1:81 DO
 .S F="/tmp/epoch"_ZZ_"/ID21_BLPU_Records.csv"
 .D LOAD(F,"BLPU",ZZ)
 .S F="/tmp/epoch"_ZZ_"/ID24_LPI_Records.csv"
 .D LOAD(F,"LPI",ZZ)
 .S F="/tmp/epoch"_ZZ_"/ID28_DPA_Records.csv"
 .D LOAD(F,"DPA",ZZ)
 .QUIT
 QUIT
 
LOAD(F,NODE,EPOCH) 
 S ZC=1
 C F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S UPRN=$P(STR,",",4)
 .S ^OS(EPOCH,NODE,UPRN)=""
 .I ZC#10000=0 U 0 W !,ZC
 .S ZC=ZC+1
 .QUIT
 CLOSE F
 QUIT
 
STEP2(F,D) ; load the UPRNs into ^PM global
 K ^PM
 ;S F="/tmp/ceg-patient-address-match.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S UPRN=$P(STR,D,3)
 .S ^PM(UPRN)=""
 .QUIT
 CLOSE F
 QUIT
 
UNIQUE ;
 K ^UN
 S F="/tmp/ceg-adr.txt"
 C F
 O F:(readonly)
 U F R STR,STR
 S C=1
 F  U F R STR Q:$ZEOF  DO
 .;U 0 W !,STR
 .S STR=$$TR^LIB(STR,$C(13),"")
 .F I=1:1:$L(STR,"~") I $P(STR,"~",I)="NULL" S $P(STR,"~",I)=""
 .;S STR=$$TR^LIB(STR,$C(13),"")
 .S ID=$P(STR,"~",1)
 .S STR=$$TR^LIB(STR,"~",",")
 .S STR=$P(STR,",",2,999)
 .S C=$I(C)
 .I C#10000 U 0 W !,C
 .S ^UN(STR)=""
 .S ^UN(STR,ID)=""
 .QUIT
 CLOSE F
 QUIT
 
GETQA(result,arguments) 
 K ^TMP($J)
 set result("mime")="application/json, text/plain, */*"
 ;S ^TMP($J,1)="test"
 set result=$na(^TMP($j))
 quit
 
READ ;
 K ^TCAND
 K ^ZJ
 S file="/tmp/cands.txt"
 c file
 o file:(readonly)
 s qf=0,count=1
 for i=1:1 use file r str q:$zeof  do  q:qf
 .if str=$c(13) quit
 .if $E(str,1,20)=$tr($j("",20)," ","-") s qf=1 Q
 .;U 0 W !,str
 .S ^TCAND(count)=$$TR^LIB(str,$C(13),"")
 .S count=count+1
 .quit
 close file
 ; run the candidate addresses through the system
 f zi=1:1:$o(^TCAND(""),-1) do
 .S ADR=^TCAND(zi)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S ^ZJ(zi)=$GET(^temp($j,1))
 .quit
 QUIT
 
POST(arguments,body,result) 
 set result("mime")="text/html"
 M ^FILES=body
 ; write the file out
 S file="/tmp/cands.txt"
 c file
 o file:(newversion)
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 f i=1:1:$o(body(""),-1) do
 .use file w body(i)
 .quit
 close file
 s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result=$na(^TMP($J))
 ;J READ
 QUIT 1
