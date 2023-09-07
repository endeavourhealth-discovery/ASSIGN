ASSURE ;
	S ^ADNO=1
	D ^UPRNTEST("0","5.4","","/mnt/c/Users/david/CloudStation/msm/SHARED/ABP/Assurance")
	Q
IMPORT ;
	D IMPORT^UPRNTEST(^UPRNF("assuranceimport"),"SCOT")
	D SCOT1
	Q
SCOT1 ;
	K ^UPRNI("D")
	s adno=""
	for  s adno=$O(^UPRNI("SCOT",adno)) q:adno=""  D
	. s rec=^(adno)
	. s rec=$$csv^UPRNU(rec)
	. s ^UPRNI("D",adno)=$$format^UPRNAS(rec)
q
	;
	;
	;
