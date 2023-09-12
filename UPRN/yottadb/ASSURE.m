ASSURE ;
	S ^ADNO=1
	D ^UPRNTEST("0","5.4","","/mnt/c/Users/david/CloudStation/msm/SHARED/ABP/Assurance")
	Q
IMPORT(source) ;
	n aoro
	w !,"Add  or Overwrite (A/O) :" r aoro
	s aoro=$$UC^LIB(aoro)
	d files(source)
	D IMPORT^UPRNTEST(^UPRNF("assuranceimport",source),source)
	D unpack(source,aoro)
	Q
unpack(source,aoro)	;
	if source="SCOT" d SCOT1(aoro)
	if source="WALES" d WALES(aoro)
	Q
WALES(aoro);
	n adno,newadno,rec
	i aoro="O" K ^UPRNI("D")
	s newadno=$O(^UPRNI("D",""),-1)+1
	s adno=""
	for  s adno=$O(^UPRNI("WALES",adno)) q:adno=""  D
	. s rec=^(adno)
	. s newadno=newadno+1
	. s ^UPRNI("D",newadno)=$p(rec,$C(9),1)
	. S ^UPRNI("UPRN","WALES",newadno)=$p(rec,$C(9),2)
	q
	;				
SCOT1(aoro) ;
	n newadno,adno,rec
	i aoro="O" K ^UPRNI("D")
	s adno=""
	s newadno=$O(^UPRNI("D",""),-1)+1
	for  s adno=$O(^UPRNI("SCOT",adno)) q:adno=""  D
	. s rec=^(adno)
	. s rec=$$csv^UPRNU(rec)
	. S newadno=newadno+1
	. s ^UPRNI("D",newadno)=$$format^UPRNAS(rec)
q
	;
	;	
files(source) ;
	n file,att
	s file=""
	s file=$G(^UPRNF("assuranceimport",source))
	w !,"source import path & file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("assuranceimport",source))
	s ^UPRNF("assuranceimport",source)=file
	q	
	;
	;
	;