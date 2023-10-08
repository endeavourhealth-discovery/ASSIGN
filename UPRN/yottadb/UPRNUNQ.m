UPRNUNQ	;uniqu addresses from an upload
	K ^TEMP($J)
	k ^TEMP1($J)
	s adno=""
	for  s adno=$O(^UPRNI("D",adno)) q:adno=""  d
	. s rec=^UPRNI("D",adno)
	. I '$D(^TEMP1($J,rec)) d
	. . s ^TEMP($J,$O(^TEMP($J,""),-1)+1)=rec
	. . S ^TEMP1($j,rec)=""
	K ^UPRNI("D")
	M ^UPRNI("D")=^TEMP($J)
	q	