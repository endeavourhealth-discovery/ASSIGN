EXP ; ; 9/4/23 9:49am
STT 
	;W !,$h
	;s adrec=^UPRNI("D",125520)
	;s adrec=^UPRNI("D",124220)
	;s adrec=^UPRNI("D",^ADNO)
	;s adrec="MAITLAND PAR4K CARE HOME MAITLAND PARK ROAD LONDON, NW52DU"
	;s adrec="Flat 2S0Soda Studios,268 Kingsland Road,,,London,E84DG"
	;s adrec="69 Powerscroft Road,Clapton,,,London,E50PT"
	;s adrec="1 Lewick st,Stratford,,,London,E153DD"
	;s adrec="FLAT 1 BEAUCHIEF HOUSE 3, ST JULIAN TERRACE, TENBY, SA70 7BL"
	;s adrec="PLOT 8, TALYGARN COURT, TALYGARN MANOR, TALYGARN, PONTYCLUN, CF72 9UH"
	;s adrec="8 WEST VICTORIA DOCK ROAD,PANMURE COURT,CITY QUAY, DUNDEE,DD1 3BH"
	;s adrec=^UPRNI("D",7078366)
	;D ^ZLINK
	S adrec=^UPRNI("D",3153)
	W !,adrec,!
	D SETSWAPS^UPRNU
	D GETUPRN^UPRNMGR(adrec,"","","","","")
	s uprn=$O(^TUPRN($J,"MATCHED",""))
	K ^DLS
	i uprn'="" M ^DLS=^UPRN("U",uprn)
	S END=$P($H,",",2)
	;W !,"All ",END-START
	K ^TIMING
	q