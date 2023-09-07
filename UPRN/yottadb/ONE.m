ONE      ;NEW PROGRAM [ 08/17/2023  12:04 PM ]
	D ^RR
STT      S START=$P($H,",",2)
	;W !,$h
	s adrec=^UPRNI("D",139674)
	s adrec=^UPRNI("D",97006)
	s adrec=^UPRNI("D",127983)
	s adrec=^UPRNI("D",216742)
	s adrec=^UPRNI("D",122474)
	;s adrec=^UPRNI("D",^ADNO)
	;s adrec="MAITLAND PARK CARE HOME MAITLAND PARK ROAD LONDON, NW52DU"
	;s adrec="Flat 20Soda Studios,268 Kingsland Road,,,London,E84DG"
	;s adrec="69 Powerscroft Road,Clapton,,,London,E50PT"
	;s adrec="1 Lewick st,Stratford,,,London,E153DD"
	W !,adrec,!
	D GETUPRN^UPRNMGR(adrec,"","","","",1)
	S END=$P($H,",",2)
	;W !,"All ",END-START
	K ^TIMING
	q
~