REG2 ; ; 9/25/20 9:37am
 set ^%W(17.6001,"B","POST","api/reg2","REG^REG2",621)=""
 set ^%W(17.6001,621,0)="POST"
 set ^%W(17.6001,621,1)="api/reg2"
 set ^%W(17.6001,621,2)="REG^REG2"
 set ^%W(17.6001,621,"AUTH")=1
 Q
REG(arguments,body,result) ;
 K b
 D DECODE^VPRJSON($name(body(1)),$name(b),$name(err))
 S userid=b("userid")
 S name=b("name"),org=b("org")
 S ^ZREG(userid)=$H_"~"_org_"~"_name
 S ^TMP($J,1)="{""status"": ""OK""}"
 set result("mime")="application/json, text/plain, */*"
 S result=$NA(^TMP($J))
 QUIT 1
