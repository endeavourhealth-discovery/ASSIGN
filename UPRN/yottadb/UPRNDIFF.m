UPRNDIFF	;
	;d IMPORT^ASSURE("SCOT","FLAP")
	s from="",to="",every="",out="",diffout=1
	;D ^UPRNTEST("FLAP","5.4.3",from,to,every,out,diffout)
	D out^UPRNTEST("FLAP","5.4.3","","","",1)
	q
UNMATCHED(from,to) ;
	n adno,file
	s to=$g(to,100000000)
	s file="/mnt/c/temp/ummatched.txt"
	o file:newversion
	s adno=from
	for  s adno=$O(^UPRNI("D",adno)) q:adno=""  q:(adno>to)  d
	. I $D(^UPRNI("M","5.4.2",adno)) q
	. u file w adno_$c(9)_^UPRNI("D",adno),!
	c file
	q
MATCHED(from,to)	;
	s to=$g(to,100000000)
	s file="/mnt/c/temp/matched.txt"
	o file:newversion
	s adno=from
	for  s adno=$O(^UPRNI("M","5.4.2",adno)) q:adno=""  q:(adno>to)  d
	. u file w adno_$c(9)_^UPRNI("D",adno)_$c(9)_^UPRNI("M","5.4.2",adno)
	c file
	q