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
	s adno=585789
	S adrec=^UPRNI("D",adno)
	S ^ADNO=adno
	W !,adrec,!
	D SETSWAPS^UPRNU
	D GETUPRN^UPRNMGR(adrec,"","","","","")
	s apiuprn=$O(^TUPRN($J,"MATCHED",""))
	;d tomatch^UPRN(adno,"5.5.1") ;Match 1 address
	;s directuprn=$O(^TUPRN($J,"MATCHED",""))
	w !,"getuprn : ",apiuprn
	;w !,"tomatch : ",directuprn,!
	q