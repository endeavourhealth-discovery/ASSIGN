EXP1 ;
		k ^RESULT
	S file="/home/david/.yottadb/r2.06_x86_64/g/samples/false.txt"
	open file:(readonly)
	s d=$c(9)
	u file r header
	S row=0
	for  u file r rec q:rec=""  d
	. s row=row+1
	. s uprn1=$p(rec,d)
	. s adrec=$p(rec,d,15)
	. D GETUPRN^UPRNMGR(adrec,"","","","","")
	. s apiuprn=$O(^TUPRN($J,"MATCHED",""))
	. s ^RESULT(row,"uprn1")=uprn1
	. S ^RESULT(row,"uprn2")=apiuprn
	. S ^RESULT(row,"candidate")=$TR(adrec,"""","")
	. i apiuprn'="" d
	. . s table=$O(^TUPRN($j,"MATCHED",apiuprn,""),-1)
	. . i table'="" d
	. . . s key=$O(^TUPRN($j,"MATCHED",apiuprn,table,""),-1)
	. . . s address=$$GETADDRESS^UPRNU(apiuprn,table,key)
	. . . s ^RESULT(row,"address")=address
	close file
	;
	S file="/home/david/.yottadb/r2.06_x86_64/g/samples/truer.txt"
	o file:(NEWVERSION)
	u file
	s row=""
	for  s row=$o(^RESULT(row)) q:row=""  d
	. w ^RESULT(row,"candidate"),$c(9),^RESULT(row,"uprn1"),$c(9),^RESULT(row,"uprn2"),$C(9),$g(^RESULT(row,"address")),!            
	c file
	Q