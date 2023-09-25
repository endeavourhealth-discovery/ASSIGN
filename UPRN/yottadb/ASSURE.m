ASSURE ;
	S ^ADNO=1
	D ^UPRNTEST("0","5.4","","/mnt/c/Users/david/CloudStation/msm/SHARED/ABP/Assurance")
	Q
IMPORT(source) ;
	d files(source)
	K ^UPRNI("D")
	D UNMATCHED(source)
	D MATCHED(source)
	Q
	;
files(source) ;	
	n file
	s file=$G(^UPRNF("matched",source))
	w !,source," source matched file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("matched",source))
	s ^UPRNF("matched",source)=file
	s file=$G(^UPRNF("unmatched",source))
	w !,source," source unmatched file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("unmatched",source))
	s ^UPRNF("unmatched",source)=file
	q
	;	
MATCHED(source) ;
	n file,rec,del,adno,header,uprn
	s file=^UPRNF("matched",source)
	u 0 w !,"Importing "_file_"..."
	s del=$c(9)
	o file
	s adno=$O(^UPRNI("D",""),-1)
	i source="SCOT" u file r header
	for  u file r rec  q:$zeof  d
	. s adno=adno+1
	. i source="WALES" d
	. . s ^UPRNI("D",adno)=$p(rec,$c(9),1)
	. . S uprn=$p(rec,del,2)
	. . i uprn'="" S ^UPRNI("M",source,adno)=uprn
	. i source="SCOT" d  
	. . S ^UPRNI("D",adno)=$$scotm($$csv^UPRNU(rec))
	c file
	Q
UNMATCHED(source) ;
	n file,rec,adno,del
	s file=""
	s file=^UPRNF("unmatched",source)
	u 0 w !,"Importing "_file_"..."
	s del=$c(9)
	o file
	s adno=$O(^UPRNI("D",""),-1)
	i source="SCOT" u file r header
	for  u file r rec  q:$zeof  d
	. s adno=adno+1
	. i source="WALES" d
	. . s ^UPRNI("D",adno)=$p(rec,$c(9),1)
	. i source="SCOT" d
	. . S ^UPRNI("D",adno)=$$scotm($$csv^UPRNU(rec))
	c file
	Q	
scotm(rec) ;
	n addr,i
	s addr=$P(rec,$c(9),6)
	f i=$l(addr,","):-1:1 s post=$p(addr,",",i) i $$validp^UPRN($tr(post," ")) q
	s addr=$p(addr,",",0,i)
	q addr
	;	