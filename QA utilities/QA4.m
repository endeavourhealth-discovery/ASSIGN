QA4 ; ; 5/4/21 9:56am
 QUIT
 
STEP5 ;
 K ^CEGADR
 S F="/tmp/internal_gp_pid_adr.txt"
 C F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .S ID=$P(STR,$C(9),1)
 .S REC=$P(STR,$C(9),2,99)
 .F I=1:1:$L(REC,$C(9)) I $P(REC,$C(9),I)="NULL" S $P(REC,$C(9),I)=""
 .S ^CEGADR(ID)=$$LC^LIB(REC)
 .QUIT
 CLOSE F
 QUIT
 
STEP5A ;
 K ^CIDX
 S F="/tmp/internal_gp_pid_pm.txt"
 C F
 O F:(readonly)
 S D=$C(9)
 F  U F R STR Q:$ZEOF  DO
 .S ADRID=$P(STR,$C(9),2)
 .I '$D(^REG2(ADRID)) QUIT
 .S STR2=$GET(^CEGADR(ADRID))
 .;U 0 W !,STR2
 .I STR2="" U 0 W !,"? ",ADRID QUIT
 .S ADR=$P(STR2,D,1)_","_$P(STR2,D,2)_","_$P(STR2,D,3)_","_$P(STR2,D,4)_","_$P(STR2,D,5)_","_$P(STR2,D,6)
 .S ^CIDX(ADR)=""
 .QUIT
 CLOSE F
 QUIT
 
STEP5C ; ADDRESSES WHERE THERE IS NO PATIENT ADDRESS MATCH RECORD
 K ^CANDS2,^NOPE
 S D=$C(9)
 S ADRID=""
 F  S ADRID=$O(^CEGADR(ADRID)) Q:ADRID=""  DO
 .I '$D(^REG2(ADRID)) QUIT
 .S STR2=^CEGADR(ADRID)
 .S ADR=$P(STR2,D,1)_","_$P(STR2,D,2)_","_$P(STR2,D,3)_","_$P(STR2,D,4)_","_$P(STR2,D,5)_","_$P(STR2,D,6)
 .;W !,ADR
 .I '$D(^CIDX(ADR)) S ^NOPE(ADR)=ADRID ; W !,"NOPE ",ADR S ^NOPE(ADR,ADRID)=""
 .I $D(^CIDX(ADR)) ; W !,"YES ",ADR
 .QUIT
 QUIT
 
NOPE ;
 S F="/tmp/nope.txt"
 C F
 O F:(newversion)
 S ADR=""
 F  S ADR=$O(^NOPE(ADR)) Q:ADR=""  DO
 .U F W ADR,!
 .QUIT
 CLOSE F
 QUIT
 
REG2 ;
 K ^REG2
 S F="/tmp/internal_gp_pid_reg.txt"
 C F
 O F:(readonly)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .;U 0 W !,STR
 .S ADRID=$P(STR,$C(9),2)
 .S ^REG2(ADRID)=""
 .QUIT
 CLOSE F
 ;W !,STR
 QUIT
