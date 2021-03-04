TST1 ; ; 3/1/21 4:38pm
 W !,"ORIGINAL UPRN: "
 R ORIG
 W !,"ASSERTED UPRN: "
 R ASSUPRN
 
 ; FOR ORIG UPRN COLLECT ADDRESS DETAILS
 ; FOR ASSERTED UPRN COLLECT ADDRESS DETAILS
 ; FOR EVERY ORIG ADDRESS MAP TO THE LAST ASSERTED ADDRESSES
 
 K ^TADR($J)
 D STT(ORIG,0)
 D STT(ASSUPRN,1)
 
 ;S UPRN=""
 ;K ^ZASSERT,^ZASSERT2,^ZASSERT3
 
 I '$D(^TADR($J,ASSUPRN)) W !,"EH?" QUIT
 S FIRSTASS=$O(^TADR($J,ASSUPRN,""))
 S FIRSTADD=^TADR($J,ASSUPRN,FIRSTASS,"O")
 S ORIGADD=""
 ;K ^ZASSERT,^ZASSERT2,^ZASSERT3
 F  S ORIGADD=$O(^TADR($J,ORIG,ORIGADD)) Q:ORIGADD=""  DO
 .S LORIGADD=$$LC^LIB(ORIGADD)
 .;f zi=1:1:$length(LORIGADD) q:$e(LORIGADD,zi)'=","
 .;i zi>1 s LORIGADD=$e(LORIGADD,zi,$l(LORIGADD))
 .S ^ZASSERT(LORIGADD)=ASSUPRN
 .S ^ZASSERT(LORIGADD,"O")=^TADR($J,ORIG,ORIGADD,"O")
 .S ^ZASSERT2(LORIGADD)=FIRSTADD
 .S ^ZASSERT2(LORIGADD,"O")=^TADR($J,ORIG,ORIGADD,"O")
 .S ^ZASSERT3(LORIGADD)=ASSUPRN_"~"_ORIG
 .QUIT
 QUIT
 
EXPORT ;
 ; create a sample upload file
 ;
 S F="/tmp/assert_upload.txt"
 C F
 O F:(newversion)
 U F
 S origadd=""
 S D=$C(9)
 f  s origadd=$order(^ZASSERT(origadd)) q:origadd=""  do
 .s newuprn=$p(^ZASSERT3(origadd),"~",1)
 .s origuprn=$p(^ZASSERT3(origadd),"~",2)
 .s origfmtd=^ZASSERT(origadd,"O")
 .s newfmtd=^ZASSERT2(origadd)
 .;
 .;
 .;
 .;
 .U F W newuprn,D,origuprn,D,origfmtd,D,newfmtd,!
 .quit
 CLOSE F
 
 QUIT
 
CONSUME ; consume an upload file
 S F="/tmp/assert_upload.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .;U 0 W !,STR
 .S origuprn=$P(STR,$C(9),2)
 .S newuprn=$P(STR,$C(9),1)
 .S origaddress=$P(STR,$C(9),3)
 .S zuprn=$$GETUPRN(origaddress)
 .i zuprn'=origuprn u 0 w !,zuprn," * ",origuprn,!,origaddress,!,"uprn mismatch (orig)" quit
 .S newaddress=$P(STR,$C(9),4)
 .S zuprn=$$GETUPRN(newaddress)
 .i zuprn'=newuprn u 0 w !,"uprn mismatch (new)" quit
 .S lorigaddress=$$TR^LIB($$TR^LIB($$LC^LIB(origaddress)," ",""),",","")
 .S lnewaddress=$$TR^LIB($$TR^LIB($$LC^LIB(newaddress)," ",""),",","")
 .;
 .;
 .;
 .;
 .;
 .;
 .;f zi=1:1:$length(lorigaddress) q:$e(lorigaddress,zi)'=","
 .;i zi>1 s lorigaddress=$e(lorigaddress,zi,$l(lorigaddress))
 .S ^ZASSERT(lorigaddress)=newuprn
 .S ^ZASSERT(lorigaddress,"O")=origaddress
 .S ^ZASSERT2(lorigaddress)=newaddress
 .S ^ZASSERT2(lorigaddress,"O")=origaddress
 .S ^ZASSERT3(lorigaddress)=newuprn_"~"_origuprn
 .QUIT
 C F
 QUIT
 
GETUPRN(zorigadd) 
 K ^TPARAMS($J)
 S ^TPARAMS($J,"commercials")=1 ; commercials on
 D GETUPRN^UPRNMGR(zorigadd,"","","",0,0)
 k b
 D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 quit $get(b("UPRN"))
 
 K ^TST1
 S (N1,UPRN)="",T=0
 F  S N1=$O(^UPRNX("X",N1)) Q:N1=""  DO
 .F  S UPRN=$O(^UPRNX("X",N1,UPRN)) Q:UPRN=""  DO
 ..S ^TST1(UPRN)=$G(^TST1(UPRN))+1
 ..S ^TST1(UPRN,N1)=""
 ..S T=T+1
 W !,T
 QUIT
 
STT(UPRNX,ASS) ;
 ;W !,"UPRN (10034510842)? "
 ;R UPRN
 ;K ^TADR($J)
 W !
 S (N1,N2)=""
 F  S N1=$O(^UPRN("U",UPRNX,N1)) Q:N1=""  DO
 .F  S N2=$O(^UPRN("U",UPRNX,N1,N2)) Q:N2=""  DO
 ..S ADR=$GET(^UPRN("U",UPRNX,N1,N2,"O"))
 ..;
 ..;W !,$P(ADR,"~",9) ; <= POSTCODE
 ..;W !,ADR
 ..S FLAT=$$IN^LIB($P(ADR,"~"))
 ..S BUILD=$$IN^LIB($P(ADR,"~",2))
 ..S BNO=$$IN^LIB($P(ADR,"~",3))
 ..S DEPTH=$$IN^LIB($P(ADR,"~",4))
 ..S STREET=$$IN^LIB($P(ADR,"~",5))
 ..S DEPLOC=$$IN^LIB($P(ADR,"~",6))
 ..S LOC=$$IN^LIB($P(ADR,"~",7))
 ..S TOWN=$$IN^LIB($P(ADR,"~",8))
 ..S POST=$$UC^LIB($P(ADR,"~",9))
 ..S LEVEL=$$IN^LIB($P(ADR,"~",10))
 ..W !,FLAT,",",BUILD,",",BNO,",",DEPTH,",",STREET,",",DEPLOC,",",LOC,",",TOWN,",",POST ;; ,",",LEVEL
 ..S ADR=FLAT_","_BUILD_","_BNO_","_DEPTH_","_STREET_","_DEPLOC_","_LOC_","_TOWN_","_POST
 ..;
 ..; CHECK THAT THE ADDRESS CANDIDATE RETURNS THE ASSERTED UPRN!
 ..S Q=0
 ..I ASS DO  Q:Q
 ...K ^TPARAMS($J)
 ...S ^TPARAMS($J,"commercials")=1
 ...W !,ADR
 ...D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 ...K b
 ...D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 ...set ZUPRN=$get(b("UPRN"))
 ...W !,ZUPRN," * ",UPRNX
 ...I ZUPRN'=UPRNX S Q=1
 ...QUIT
 ..;
 ..S LADR=$$TR^LIB($$LC^LIB(ADR)," ","")
 ..S LADR=$$TR^LIB(LADR,",","")
 ..S ^TADR($J,UPRNX,LADR)=""
 ..S ^TADR($J,UPRNX,LADR,"O")=ADR
 ..Q
 .Q
 QUIT
 
 
SPELL ;
 W !,"ADDRESS STRING ?"
 R ADR
 F I=1:1:$L(ADR,",") DO
 .S LINE=$P(ADR,",",I)
 .F ZQ=1:1:$L(LINE," ") DO
 ..S WORD=$P(LINE," ",ZQ)
 ..W !,WORD
 ..S CORR=$$C(WORD)
 ..I CORR'=WORD W !,"*",CORR
 ..QUIT
 .QUIT
 QUIT
 
C(VAR) ; CORRECT
 N OUT
 S VAR=$$LC^LIB(VAR)
 S OUT=VAR
 I $D(^UPRNS("CORRECT",VAR)) S OUT=^(VAR)
 QUIT OUT
 
 ;
 ; DUMP OUT UPRNS FOR ABP STUFF
DUMP ;
 S F="/tmp/uprn_dump.txt"
 C F
 O F:(newversion)
 S A=""
 F  S A=$O(^UPRN("U",A)) Q:A=""  DO
 .U F W A,!
 .QUIT
 CLOSE F
 QUIT
