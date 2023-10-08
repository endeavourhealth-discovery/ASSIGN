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
	I file="" q
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
	I file="" q
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
	. . S ^UPRNI("D",adno)=$$scotm(rec)
	c file
	Q	
scotm(rec) ;
	n saon,paon,street,locality,town,county,pout,pin,d,post,var,addr,first
	s rec=$$csv^UPRNU(rec)
	s d=$c(9)
	S rec=$$lt^UPRNL($p(rec,d,4,20))
	s saon=$p(rec,d,1),paon=$p(rec,d,2),street=$p(rec,d,3),locality=$p(rec,d,4),town=$p(rec,d,5)
	s county=$p(rec,d,6),pout=$p(rec,d,8),pin=$p(rec,d,9)
	i saon?1"0"1n.n,$l(saon)=5 s saon=""
	s post=pout_" "_pin
	s addr=""
	f var="saon","paon","street","locality","town","county","post" d
	. i @var'="" s addr=addr_$s(addr'="":",",1:"")_$$lt^UPRNL(@var)
	q addr
	;	