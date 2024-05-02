EXP1 ;
	s d=$c(9)
	s file="/mnt/c/Users/david/CloudStation/msm/SHARED/ABP/Scotland/scot-output.txt"
	open file:(readonly)
	use file r rec
	for  do  q:rec=""
	. use file r rec
	. Q:rec=""
	. s adno=$p(rec,d,1)
	. s uprn=$p(rec,d,2)
	. s addr=$p(rec,d,3)
	. i uprn'="" S ^UPRNI("M","5.4.3",adno)=uprn
	c file
	;	
	q
	k ^V544
	u 0
	s adno="",more=0,diff=0,same=0,samenone=0,nolonger=0
	for  s adno=$O(^UPRNI("D",adno)) q:adno=""  q:(adno>$O(^UPRNI("M","5.4.3",""),-1))  D
	. S ouprn=$G(^V543(adno))
	. s uprn=$G(^UPRNI("M","5.4.3",adno))
	. i ouprn="",uprn'="" d 
	. . s more=more+1
	. . S ^V544("MORE",adno)=^UPRNI("D",adno)
	. . S ^V544("MORE",adno,"NOW")=uprn
	. i uprn'="",ouprn'="",uprn'=ouprn d
	. . s diff=diff+1
	. . S ^V544("DIFF",adno)=^UPRNI("D",adno)
	. . S ^V544("DIFF",adno,"NOW")=uprn
	. . S ^V544("DIFF",adno,"WAS")=ouprn
	. i ouprn'="",uprn'="",uprn=ouprn d
	. . s same=same+1
	. . S ^V544("SAME",adno)=^UPRNI("D",adno)
	. i ouprn="",uprn="" d
	. . s samenone=samenone+1
	. . S ^V544("STILLNONE",adno)=^UPRNI("D",adno)
	. i ouprn'="",uprn="" d
	. . s ^V544("NOMORE",adno)=^UPRNI("D",adno)
	. . s ^V544("NOMORE",adno,"WAS")=ouprn
	. . S nolonger=nolonger+1
	u 0
	w !,"same match = ",same
	w !,"more = ",more
	w !,"different= ",diff
	w !,"same no match =",samenone
	w !,"no longer matched = ",nolonger,!
	;	
	;	
	Q
	;