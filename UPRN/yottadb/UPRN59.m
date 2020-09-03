UPRN59 ; ; 9/3/20 1:33pm
DIFFER ; 
U W !,"UPRN: "
 R UPRN
 I UPRN="." QUIT
 W !
 
S W !
 F I=1:1:5 DO
 .I $D(^EPOCH(I,UPRN)) W !,I," ",^FILES(I)
 .QUIT
 W !,"file? "
 R I
 I I="." G U
 
 I '$D(^EPOCH(I,UPRN)) W !,"NO EPOCH FOR UPRN" G S
 
 N Z
 
 S ^FILES(1)="ID15_StreetDesc_Records.csv"
 S ^FILES(2)="ID21_BLPU_Records.csv"
 S ^FILES(3)="ID24_LPI_Records.csv"
 S ^FILES(4)="ID28_DPA_Records.csv"
 S ^FILES(5)="ID32_Class_Records.csv"
 
 ;K ^HDRS
 i '$d(^HDRS) DO
 .S Z=""
 .S DIR="/tmp/epoch77/"
 .F  S Z=$O(^FILES(Z)) Q:Z=""  DO
 ..S F=DIR_^FILES(Z)
 ..W !,F
 ..C F
 ..O F:(readonly)
 ..U F R STR
 ..C F
 ..W !,STR
 ..F I=1:1:$L(STR,",") S ^HDRS(Z,I)=$$TR^LIB($P(STR,",",I),"""","")
 ..QUIT
 .QUIT
 
 S STR=$G(^BASE(I,UPRN),"?")
 S DELTA=^EPOCH(I,UPRN)
 
 ;S UPRN=$$TR^LIB($P(STR,",",4),"""","")
 
 K DIFFS
 
 W !!!,^FILES(I)
 W !,"BASE : "
 I STR="?" W STR
 I STR'="?" DO
 .F Z=1:1:$L(STR,",") DO
 ..I $P(STR,",",Z)'=$P(DELTA,",",Z) W "*",$P(STR,",",Z),"," Q ; W %("CBD"),"*",$P(STR,",",Z),%("CNO"),"," Q
 ..W $P(STR,",",Z),","
 ..QUIT
 
 W !,"DELTA: "
 I STR'="?" DO
 .F Z=1:1:$L(DELTA,",") DO
 ..I $P(DELTA,",",Z)'=$P(STR,",",Z) W "*",$P(DELTA,",",Z),"," S DIFFS(Z)="" QUIT
 ..W $P(DELTA,",",Z),","
 ..QUIT
 .QUIT
 I STR="?" W DELTA
 
 W !
 S Z="",DIFS=""
 F  S Z=$O(DIFFS(Z)) Q:Z=""  D
 .W $G(^HDRS(I,Z)),","
 .S DIFS=DIFS_$GET(^HDRS(I,Z))_","
 .QUIT
 
 G S
 
 W !!,UPRN
 F ZI=1:1:5 DO
 .I ZI=I QUIT
 .;I $GET(^EPOCH(ZI,UPRN))="" QUIT
 .;BREAK
 .W !,^FILES(ZI)
 .I $G(^BASE(ZI,UPRN))'="" W !,"B: ",$GET(^BASE(ZI,UPRN))
 .I $G(^EPOCH(ZI,UPRN))'="" W !,"U: ",$GET(^EPOCH(ZI,UPRN))
 .QUIT
 
 ; CONSTRUCT AN ADDRESS STRING
 ; 1 = STREET, 2 = BLPU, 3 = LPI, 4 = DPA, 5 = CLASS
 ; STREET (1) CONTAINS USRN INFO
 ; BLPU (2) CONTAINS X, Y, LONG, LAT + POSTCODE LOCATOR
 ; LPI (3) CONTAINS USRN, POA_TEXT
 ; DPA (4) CONTAINS THE ADDRESS DATA
 S ADR=""
 DO
 .;BREAK
 .; GET THE ADDRESS FROM EITHER THE BASELINE OR EPOCH
 .I I=4 DO
 ..S REC=$G(^EPOCH(4,UPRN))
 ..I REC="" S REC=$GET(^BASE(4,UPRN))
 ..I REC="" QUIT
 ..;BREAK
 ..S ORGNAME=$$TR^LIB($P(REC,",",6),"""","")
 ..S DEPNAME=$$TR^LIB($P(REC,",",7),"""","")
 ..S SUBNAME=$$TR^LIB($P(REC,",",8),"""","")
 ..S BUILDNAM=$$TR^LIB($P(REC,",",9),"""","")
 ..S BUILDNO=$$TR^LIB($P(REC,",",10),"""","")
 ..S DTHRO=$$TR^LIB($P(REC,",",12),"""","")
 ..S LOCAL=$$TR^LIB($P(REC,",",14),"""","")
 ..S POSTTOWN=$$TR^LIB($P(REC,",",15),"""","")
 ..S POSTCODE=$$TR^LIB($P(REC,",",16),"""","")
 ..S ADREC=ORGNAME_","_DEPNAME_","_SUBNAME_","_BUILDNAM_","_BUILDNO_","_DTHRO_","_LOCAL_","_POSTTOWN_","_POSTCODE
 ..S ZEPOCH=$G(^EPOCH(4,UPRN))
 ..S ZBASE=$G(^BASE(4,UPRN))
 ..S ^TEST(UPRN)=ADREC
 ..S ^TEST(UPRN,I,"DIF")=DIFS
 ..;S ^ZTEST(UPRN,I,"E")=$$RET(ZEPOCH)
 ..;S ^ZTEST(UPRN,I,"B")=$$RET(ZBASE)
 ..;S ^ZTEST(UPRN,I,"DIF")=DIFS
 ..QUIT
 .I I=3 DO
 ..S ZEPOCH=$GET(^EPOCH(3,UPRN))
 ..S ZBASE=$GET(^BASE(3,UPRN))
 ..S ^ZTEST(UPRN,I,"DIF")=DIFS
 ..;S ^ZTEST(UPRN,I,"E")=$$RET2(ZEPOCH)
 ..;S ^ZTEST(UPRN,I,"B")=$$RET2(ZBASE)
 ..QUIT
 .QUIT
 
 ;;R *Y
 
 G S
