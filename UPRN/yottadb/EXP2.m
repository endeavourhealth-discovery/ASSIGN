EXP2 ;
	k ^RESULT
	S file="/home/david/.yottadb/r2.06_x86_64/g/samples/testdata.txt"
	open file:(readonly)
	s d=$c(9)
	u file
	S row=0
	for  u file r rec q:rec=""  d
	. s adno=$p(rec,d)
	. s adrec=$p(rec,d,2)
	. D GETUPRN^UPRNMGR(adrec,"","","","","")
	. s apiuprn=$O(^TUPRN($J,"MATCHED",""))
	. s ^RESULT(adno,"uprn")=apiuprn
	. S ^RESULT(adno,"candidate")=$TR(adrec,"""","")
	. i apiuprn'="" d
	. . s table=$O(^TUPRN($j,"MATCHED",apiuprn,""),-1)
	. . i table'="" d
	. . . s key=$O(^TUPRN($j,"MATCHED",apiuprn,table,""),-1)
	. . . s address=$$GETADDRESS^UPRNU(apiuprn,table,key)
	. . . s ^RESULT(adno,"address")=address
	close file
	;
	S file="/home/david/.yottadb/r2.06_x86_64/g/samples/710.txt"
	o file:(NEWVERSION)
	u file
	s row=""
	for  s row=$o(^RESULT(row)) q:row=""  d
	. w row,$c(9),^RESULT(row,"candidate"),$c(9),^RESULT(row,"uprn"),$c(9),$g(^RESULT(row,"address")),!          
	c file
	Q