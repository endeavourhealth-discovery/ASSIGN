ASSURE ;
	Q
IMPORT(source,vold) ;
	d files(source,vold)
	D UNMATCHED(source)
	D MATCHED(source,vold)
	D ALL(source,vold)
	Q
	;
files(source,vold) ;	
	n file
	s file=$G(^UPRNF("matched",source))
	u 0
	d matchfile
	d unmatchfile
	d allfile
	q
matchfile ;
	w !,source," ",vold," source matched file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("matched",source))
	i file="" q
	s ^UPRNF("matched",source)=file
	O file:readonly
	c file
	q
unmatchfile ;	
	u 0	
	s file=$G(^UPRNF("unmatched",source))
	w !,source," source unmatched file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("unmatched",source))
	i file="" q
	o file:readonly
	c file
	s ^UPRNF("unmatched",source)=file
	q
allfile ;	
	u 0
	s file=$G(^UPRNF("all",source))
	w !,source," source all file  ("_file_") :" r file
	i file="" s file=$g(^UPRNF("all",source))
	i file="" q
	o file:readonly
	c file
	s ^UPRNF("all",source)=file
	q
	;	
MATCHED(source,vold) ;
	n file,rec,del,adno,header,uprn,uarn,scotno
	s file=$g(^UPRNF("matched",source))
	I file="" q
	k ^X
	u 0 w !,"Importing "_file_"..."
	s del=$c(9)
	o file:readonly
	s adno=$O(^UPRNI("D",""),-1)
	i source["SCOT" u file r header
	for  u file r rec  q:$zeof  d
	. S rec=$tr(rec,"$",",")
	. I $e(rec,$l(rec))="," s rec=$e(rec,1,$l(rec)-1)
	. s adno=adno+1
	. i source="WALES" d
	. . s ^UPRNI("D",adno)=$p(rec,$c(9),1)
	. . S uprn=$p(rec,del,2)
	. . i uprn'="" S ^UPRNI("M",source,adno)=uprn
	. i source="SCOT" d 
	. . s rec=$$csv^UPRNU(rec)
	. . s uarn=$P(rec,$c(9),2)
	. . I '$D(^UPRNI("UARNX",uarn)) d  q
	. . . u 0 w !,rec
	. . S scotno=^UPRNI("UARNX",uarn)
	. . S ^UPRNI("M",vold,scotno)=$P(rec,$c(9),4)
	. . S ^UPRNI("ADDRESS",vold,scotno)=$p(rec,$c(9),3)
	. . S ^UPRNI("SCORE",vold,scotno)=$p(rec,$c(9),5)
	. i source="LONDON" d
	. . S ^UPRNI("D",adno)=$p(rec,"~")
	. . I $p(rec,"~",2)'="" d
	. . . S ^UPRNI("M","4.2.1",adno)=$p(rec,"~",2)
	c file
	Q
ALL(source,version) 	;
		n d,rec,file,adno,uprn,header
		s d=$c(9)
		s file=$G(^UPRNF("all",source))
		i file="" q
		O file
		k ^UPRNI("M",version)
		i source="5.5.1" u file r header
		for  u file r rec  q:$zeof  d
		. s adno=$p(rec,d,1)
		. s uprn=$p(rec,d,2)
		. i uprn'="" d
		. . S ^UPRNI("M",version,adno)=uprn
		c file
		q
UNMATCHED(source) ;
	n file,rec,adno,del,orec,header
	s file=""
	s file=$g(^UPRNF("unmatched",source))
	I file="" q
	u 0 w !,"Importing "_file_"..."
	s del=$c(9)
	o file
	s adno=$O(^UPRNI("D",""),-1)
	i source["SCOT" u file r header
	I source["PAUL" u file r header
	for  u file r rec  q:$zeof  d
	. s adno=adno+1
	. i source="WALES" d
	. . s ^UPRNI("D",adno)=$p(rec,$c(9),1)
	. I source="SCOTNHS" d
	. . s adno=$p(rec,",")
	. . s rec=$p(rec,",",2,10)
	. . s rec=$tr(rec,"$",",")
	. . s ^UPRNI("D",adno)=rec
	. i source="SCOT" d
	. . s orec=rec
	. . s rec=$$csv^UPRNU(rec)
	. . S ^UPRNI("D",adno)=$$scotm(rec)
	. . s ^UPRNI("UARN",adno)=$p(rec,$c(9),3)
	. . S ^UPRNI("UARNX",$p(rec,$c(9),3))=adno
	. . S ^UPRNI("D",adno)=$$scotm(rec)
	c file
	Q	
scotm(rec) ;
	n saon,paon,street,locality,town,county,pout,pin,d,post,var,addr,first
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
result(version,from,to) ;
		n adno,file,uprn,class,d,rec,uarn,txt
		s adno=from
		s file="/mnt/c/temp/Results.txt"
		s d=$c(9)
		o file:newversion
		u file
		s adno=from-1
		s txt=""
		i to="" s to=100000000
		for  s adno=$O(^UPRNI("D",adno)) q:adno=""  q:(adno>to)  d
		. i '(adno#1000) u 0 w !,adno u file W txt s txt=""
		. s uprn=$G(^UPRNI("M",version,adno))
		. s class=$s(uprn'="":^UPRN("CLASS",uprn),1:"")
		. s rec=^UPRNI("D",adno)_d_uprn_d_class
		. s uarn=$g(^UPRNI("UARN",adno))
		. i uarn'="" d
		. . s rec=uarn_d_rec
		. . s txt=txt_rec_$c(13)
		. . ;u file W rec,!
		. e  d
		. . s txt=txt_rec_$c(13)
		. . ;u file w rec,!
		i txt'="" u file w txt
		c file
		q
compare(version)	;
	n file,adno,d,uprn,addr,vuprn,address,table,key
		k ^UPRNI("C","PAUL")
		s file="/mnt/c/tmp/scot_seq_out.txt"
		s d=$c(9)
		o file:readonly
		u file r rec
		for  u file r rec  q:$zeof  d
		. s adno=$p(rec,d)
		. s uprn=$p(rec,d,2)
		. s addr=$p(rec,d,3)
		. S ^UPRNI("C","PAUL",adno)=uprn
		c file
		s adno=""
		for  s adno=$O(^UPRNI("C","PAUL",adno)) q:adno=""  d
		. s uprn=^UPRNI("C","PAUL",adno)
		. S vuprn=$G(^UPRNI("M",version,adno))
		. i uprn'=vuprn d
		. . u 0 w !!,adno,"Pauls = ",uprn," ",version_" = ",vuprn," : ",^UPRNI("D",adno)
		. . u 0 w !,"Pauls match :"
		. . i uprn'="" d
		. . . d getalladdr^UPRNU(uprn,.address)
		. . . u 0 w address(1)
		. . u 0 w !,"Current match :"
		. . i vuprn'="" d
		. . . s table=$O(^UPRNI("M",version,adno,""))
		. . . s key=$O(^UPRNI("M",version,adno,table,""))
		. . . u 0 w ^UPRN("U",vuprn,table,key,"O")
		. . r t
		q
	;		
	;	
	;	