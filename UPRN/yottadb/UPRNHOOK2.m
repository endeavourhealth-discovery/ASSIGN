UPRNHOOK2	;
LOAD(folder)
	set ^FOLDER=folder
	kill ^temp($j)
	set ^temp($j,1)="{""Response"": {""Error"": ""Folder not found""}}"
	quit 1

SETUP	;
	S ^%W(17.6001,"B","GET","api/getinfo","GETMUPRN^UPRNHOOK2",100)=""
	S ^%W(17.6001,100,"AUTH")=1
	S ^%W(17.6001,100,0)="GET"
	S ^%W(17.6001,100,1)="api/getinfo"
	S ^%W(17.6001,100,2)="GETMUPRN^UPRNHOOK2"

	S ^%W(17.6001,"B","GET","api/getuprn","GETMUPRNI^UPRNHOOK2",101)=""
	S ^%W(17.6001,101,"AUTH")=1
	S ^%W(17.6001,101,0)="GET"
	S ^%W(17.6001,101,1)="api/getuprn"
	S ^%W(17.6001,101,2)="GETMUPRNI^UPRNHOOK2"
	
	S ^%W(17.6001,"B","GET","api/getstatus","GETMSTATUS^UPRNHOOK2",103)=""
	S ^%W(17.6001,103,"AUTH")=1
	S ^%W(17.6001,103,0)="GET"
	S ^%W(17.6001,103,1)="api/getstatus"
	S ^%W(17.6001,103,2)="GETMSTATUS^UPRNHOOK2"

	S ^%W(17.6001,"B","GET","api/load","GETLOAD^UPRNHOOK2",999)=""
	S ^%W(17.6001,999,"AUTH")=1
	S ^%W(17.6001,999,0)="GET"
	S ^%W(17.6001,999,1)="api/load"
	S ^%W(17.6001,999,2)="GETLOAD^UPRNHOOK2"
	quit

GETLOAD(result,arguments)
	N ok
	K ^TMP($J)
	set dir=$Get(arguments("d"))
	set type=$Get(arguments("type"))
	S ^F=dir_"~"_type
	if dir="" S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit
	if type="" S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit
	do LOAD^UPRNMGR(dir,type)
	set result("mime")="application/json, text/plain, */*"
	S ^TMP($J,1)=^temp($j,1)
	set result=$na(^TMP($j))
	quit
	
GETMSTATUS(result,arguments)
	N ok
	K ^TMP($J)
	set ok=$$STATUS^UPRNMGR()
	set result("mime")="application/json, text/plain, */*"
	S ^TMP($J,1)=^temp($J,1)
	set result=$na(^TMP($j))
	quit
	
	; M Web server hook
	; http://192.168.59.134:9080/api/getinfo?adrec=Crystal Palace football club, SE25 6PU
	; TEST
GETMUPRN(result,arguments)
	N HOOK2
	K ^TMP($J)
	
	;set token=$get(HTTPREQ("header","authorization"))
	;if token="" S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit
	;set token=$piece(token,"Bearer ",2)
	;if '$data(^TOKEN(token)) S HTTPERR=500 D SETERROR^VPRJRUT("500","undefined") quit

	set adrec=$Get(arguments("adrec"))
	set noassert=$Get(arguments("noassert"))
	set HOOK2=1
	
	K ^TPARAMS($J)
	set comm=$Get(arguments("commercial"))
	if comm="010" set ^TPARAMS($J,"commercials")=1
	if comm="001" set ^TPARAMS($J,"neutral")=1
	
	set qpost=$Get(arguments("qpost"))
	set country=$Get(arguments("country"))
	set summary=$Get(arguments("summary"))
	set orgpost=$Get(arguments("orgpost"))
	D GETUPRN^UPRNMGR(adrec,qpost,orgpost,country,summary,0,noassert)
	set result("mime")="application/json, text/plain, */*"
	S ^TMP($J,1)=^temp($J,1)
	set result=$na(^TMP($j))
	quit
	
GETMUPRNI(result,arguments)
	K ^TMP($J)
	
	set uprn=$get(arguments("uprn"))
	do GETUPRNI^UPRNMGR(uprn)
	set result("mime")="application/json, text/plain, */*"
	S ^TMP($J,1)=^temp($J,1)
	set result=$na(^TMP($j))	
	quit
	
	; qEWD Web server hook	
GETUPRN(adrec,qpost,orgpost,country,summary)
	kill ^temp($j)
	set adrec=$get(adrec)
	set qpost=$get(qpost)
	set orgpost=$get(orgpost)
	set country=$get(country)
	set summary=$get(summary)
	; GETUPRN(adrec,qpost,orgpost,country,summary) ;Returns the result of a matching request
	S ^HOOK=adrec_"~"_qpost_"~"_orgpost_"~"_country_"~"_summary
	;set ^temp($j,1)="{""Address_format"": ""good"",""Postcode_quality"": ""good"",""Matched"": true,""UPRN"": 100023136739,""Qualifier"": ""Child"",""Algorithm"": ""120-match2b"",""ABPAddress"": {""Number"": 133,""Street"": ""Shepherdess Walk"",""Town"": ""London"",""Postcode"": ""N1 7QA""},""Match_pattern"": {""Postcode"": ""equivalent"",""Street"": ""equivalent"",""Number"": ""equivalent"",""Building"": ""equivalent"",""Flat"": ""matched as child""}}"
	;D GETUPRN^UPRNMGR("Yvonne carter Building,58 turner street,london,E1 2AB","","","england")
	D GETUPRN^UPRNMGR(adrec,qpost,orgpost,country,summary)
	quit 1
	
STATUS()
	k ^temp($j)
	set ^temp($j,1)="{""Status"": {""Commenced"": ""2019-06-09T12:33"",""Completed"": ""2019-06-09T14:33""}}"
	quit 1
