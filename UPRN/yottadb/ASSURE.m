ASSURE ;
	D IMPORT("LONDON")
	Q
IMPORT(source) ;
	d files(source)
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
	k ^X
	u 0 w !,"Importing "_file_"..."
	s del=$c(9)
	o file:readonly
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
	. i source="LONDON" d
	. . S ^UPRNI("D",adno)=$p(rec,"~")
	. . I $p(rec,"~",2)'="" d
	. . . S ^UPRNI("M","4.2.1",adno)=$p(rec,"~",2)
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
result(from,to) ;
		n adno,file,uprn,class,row,d,rec
		s adno=from
		s file="/mnt/c/temp/Results.txt"
		s d=$c(9)
		o file:newversion
		s adno=from-1
		s row=0
		for  s adno=$O(^UPRNI("D",adno)) q:adno=""  q:(adno>to)  d
		. s row=row+1
		. i '(adno#1000) u 0 w !,adno
		. s uprn=$G(^UPRNI("M","5.4.3",adno))
		. s class=$s(uprn'="":^UPRN("CLASS",uprn),1:"")
		. s rec=row_d_^UPRNI("D",adno)_d_uprn_d_class
		. u file w rec,!
		c file
		q
	;	