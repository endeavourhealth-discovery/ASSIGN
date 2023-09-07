DS ; ; 9/3/23 5:43pm
	g A
	;quit
	;	
AB	K ^CSV
	S C=1
	S F="/tmp/Addresses_Carmarthenshire (1).csv"
	C F
	O F:(readonly)
	U F R STR
	F  U F R STR Q:$ZEOF  DO
	. S ID=$P(STR,",",1)
	. S SYS=$P(STR,",",2)
	. S ADR=$P(STR,",",3,9)
	. D GETUPRN^UPRNMGR(ADR,"","","",0,0)
	. K b
	. D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
	. set UPRN=$get(b("UPRN"))
	. S QUAL=$get(b("Qualifier"))
	. S ALG=$get(b("Algorithm"))
	. S MBUILD=$GET(b("Match_pattern","Building"))
	. S MFLAT=$GET(b("Match_pattern","Flat"))
	. S MNUMBER=$GET(b("Match_pattern","Number"))
	. S MPOSTCODE=$GET(b("Match_pattern","Postcode"))
	. S MSTREET=$GET(b("Match_pattern","Street"))
	. ;S ^CSV(C)=ID_","_ADR_","_UPRN_","_QUAL_","_ALG_","_MBUILD_","_MFLAT_","_MNUMBER_","_MPOSTCODE_","_MSTREET
	. S REC=ID_","_ADR_","_UPRN_","_QUAL_","_ALG_","_MBUILD_","_MFLAT_","_MNUMBER_","_MPOSTCODE_","_MSTREET
	. S REC=$TR(REC,$C(13),"")
	. S ^CSV(C)=REC
	. S C=C+1
	. QUIT
OUT S F="/tmp/welsh_output.csv"
	C F
	O F:(writeonly)
	U F W "ID,ADD1,ADD2,ADD3,ADD4,ADD5,POSTCODE,UPRN,QUALIFIER,ALGORITHM,MATCHBUILD,MATCHFLAT,MATCHNUMBER,MATCHPOSTCODE,MATCHSTREET",!
	S C="" F  S C=$O(^CSV(C)) Q:C=""  U F W ^(C),!
	CLOSE F
	Q
	;	
A W !,"ADR? "
	;R ADREC
	K ^TPARAMS($J)
	SET ADREC="85 WOLDCARR ROAD,ANLABY ROAD, HULL, HU36TR"
	;S ^TPARAMS($J,"commercials")=1
COMM ;write !,"commercials (Y/N)?: "
	;read comm#1
	;if "\y\n\"'[("\"_$$LC^LIB(comm)_"\") goto COMM
	;if $$LC^LIB(comm)="y" set ^TPARAMS($J,"commercials")=1 
	W !
	D GETUPRN^UPRNMGR(ADREC,"","","",0,0)
	;K b
	w !,^temp($j,1)
	quit
	;