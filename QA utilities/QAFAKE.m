QAFAKE ; ; 7/8/21 8:41am
STT ;
 
 S EPOCH=$GET(^ICONFIG("EPOCH"))
 S ALGVERSION=$GET(^ICONFIG("ALG-VERSION"))
 I EPOCH="" W !,"MISSING CURRENT EPOCH" QUIT
 I ALGVERSION="" W !,"MISSING ALGORITHM VERSION" QUIT
 
 S C=0
 
 S F="/tmp/pam-fake-"_EPOCH_".txt"
 C F
 O F:(newversion)
 ; read the ceg addresses
 S ADRID="",ID=1
 F  S ADRID=$O(^CEGADR(ADRID)) Q:ADRID=""  DO
 .; CURRENT ADDRESS ID OF A REGISTERED PATIENT?
 .I '$D(^REG2(ADRID)) QUIT
 .S STR2=$GET(^CEGADR(ADRID))
 .S ADR=$P(STR2,"~",1)_","_$P(STR2,"~",2)_","_$P(STR2,"~",3)_","_$P(STR2,"~",4)_","_$P(STR2,"~",5)_","_$P(STR2,"~",6)
 .; has this address already been processed?
 .;I $D(^TDONE($J,ADR)) QUIT
 .S ADR=$$LC^LIB(ADR)
 .I $D(^TDONE($J,ADR)) QUIT
 .S ^TDONE($J,ADR)=""
 .K ^TPARAMS($J)
 .K B
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .;
 .;S C=C+1
 .;I C#1000=0 U 0 W !,C
 .S UPRN=$GET(B("UPRN"))
 .I UPRN'="" DO
 ..;K B
 ..;S J=^temp($j,1)
 ..;D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 ..;S EPOCH=76
 ..;S ALGVERSION="4.2.1c"
 ..S MATCHRULE=$GET(B("Algorithm"))
 ..S QUAL=$G(B("Qualifier"))
 ..S CLASS=$G(B("Classification"))
 ..S ABPPOST=$G(B("ABPAddress","Postcode"))
 ..I CLASS="" U 0 W !,ADR R *Y
 ..U F W ID,"~",ADRID,"~",UPRN,"~",EPOCH,"~",ALGVERSION,"~",MATCHRULE,"~",QUAL,"~",CLASS,"~",ABPPOST,!
 ..S ID=ID+1
 ..I ID#1000=0 U 0 W !,ID
 ..Q
 .Q
 CLOSE F
 QUIT
