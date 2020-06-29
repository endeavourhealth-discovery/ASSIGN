AUTH	;
	set ^%W(17.6001,"B","POST","token/login","TOKEN^AUTH",8)=""
	QUIT

UUID() ; GENERATE A RANDOM UUID (Version 4) 
	new I,J,ZS 
	set ZS="0123456789abcdef",J="" 
	for I=1:1:36 S J=J_$select((I=9)!(I=14)!(I=19)!(I=24):"-",I=15:4,I=20:"a",1:$extract(ZS,$random(16)+1)) 
	quit J 

VAR(body,var)
	new i,val
	for i=1:1:$length(body,"&") if $p($piece(body,"&",i),"=",1)=var S val=$piece($piece(body,"&",i),"=",2)
	Q val
	
TOKEN(arguments,body,result)	;
	;
	;{"Token":{"access_token": "xxx"}}
	;
	K ^TMP($J)
	M ^BODY=body
	M ^args=arguments
	M ^HTTPREQ=HTTPREQ

	;new password,username,clientsecret,clientid,err,zbody

	set zbody=$get(body(1))
	
	set password=$$VAR(zbody,"password")
	set username=$$VAR(zbody,"username")
	set clientsecret=$$VAR(zbody,"client_secret")
	set clientid=$$VAR(zbody,"client_id")
	
	set rec=""
	if username'="" do
	.set rec=$get(^BUSER("USER",username))
	.set zpassword=$piece(rec,"~",1)
	.set zclientsecret=$piece(rec,"~",2)
	.set zclientid=$piece(rec,"~",3)
	.quit

	if rec="" D SETERROR^VPRJRUT("400","undefined") Q 1
	
	; ** TO DO RC-4 the password
	
	set err=0
	if zpassword'=password set err=1
	if zclientsecret'=clientsecret set err=1
	if zclientid'=clientid set err=1
	if err D SETERROR^VPRJRUT("400","undefined") Q 1
	
	set token=$$UUID()
	set ^TOKEN(token)=$H

	set result("mime")="application/json, text/plain, */*"
	set ^TMP($J,1)="{""Token"":{""access_token"": """_token_"""}}"
	set result=$na(^TMP($j))

	QUIT 1