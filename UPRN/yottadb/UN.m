UN ; ; 9/3/20 11:28am
 W !
 ZWR ^IMPORT
 W !
 W !,"epoch? "
 R EPOCH
 S F2="/tmp/OUT_"_EPOCH_".TXT"
 C F2
 O F2:(newversion)
 S F="/tmp/UN.TXT"
 C F
 O F:(readonly)
 S C=0
 F  U F R STR Q:$ZEOF  DO
 .D GETUPRN^UPRNMGR(STR,"","","",0,0)
 .K b
 .D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 .set UPRN=$get(b("UPRN"))
 .;u 0 w !,UPRN,"~",STR,! R *Y
 .U F2 W UPRN,"~",STR,!
 .S C=C+1
 .I C#1000=0 U 0 W !,STR
 .QUIT
 C F,F2
 QUIT
CALC ;
 W !,"EPOCH 1 (e.g. 76) ?"
 R EPOCH1 ; e.g. 76
 Q:EPOCH1=""
 W !,"EPOCH 2 (e.g. 77) ?"
 R EPOCH2 ; e.g. 77
 Q:EPOCH2=""
 
 ; BREAK
 
 S GLOB="^A"_EPOCH1
 K @GLOB
 S F="/tmp/OUT_"_EPOCH1_".TXT"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S CADR=$$TR^LIB($P(STR,"~",2,99),$C(13),"")
 .S UPRN=$P(STR,"~")
 .S @GLOB@(CADR)=UPRN
 .QUIT
 C F
 
 S GLOB="^A"_EPOCH2
 K @GLOB
 S F="/tmp/OUT_"_EPOCH2_".TXT"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S CADR=$$TR^LIB($P(STR,"~",2,99),$C(13),"")
 .S UPRN=$P(STR,"~")
 .S @GLOB@(CADR)=UPRN
 .QUIT
 C F
 
 K ^A,^B,^C,^D
 S CADR="",(A,B,C,D)=0
 S GLOB="^A"_EPOCH1
 S GLOB2="^A"_EPOCH2
 F  S CADR=$O(@GLOB@(CADR)) Q:CADR=""  DO
 .S A76UPRN=@GLOB@(CADR)
 .S A77UPRN=@GLOB2@(CADR)
 .; NULL TO UPRN
 .; UPRN TO NULL
 .; A76UPRN <> A77UPRN (BOTH NOT NULL)
 .I A76UPRN="",A77UPRN'="" S A=A+1 S ^A(CADR)=A76UPRN_"~"_A77UPRN
 .I A76UPRN'="",A77UPRN="" S B=B+1 S ^B(CADR)=A76UPRN_"~"_A77UPRN
 .I A76UPRN'="",A77UPRN'="",A76UPRN'=A77UPRN S C=C+1 S ^C(CADR)=A76UPRN_"~"_A77UPRN
 .I A76UPRN'=A77UPRN S D=D+1
 .I A76UPRN'=A77UPRN W !,CADR," ",A76UPRN,!,CADR," ",A77UPRN,!
 .Q
 
 W !,"NULL TO UPRN ",A
 W !,"UPRN TO NULL ",B
 W !,"76UPRN <> 77UPRN (BOTH NOT NULL) ",C
 W !,"TOTAL DIFFS (D) ",D
 QUIT
