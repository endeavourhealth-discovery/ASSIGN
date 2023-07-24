CURL3 ; ; 7/24/23 9:53am
 quit
 
COGNITO(token) ;
 new ok,j,b,p,y
 if token="" q 0
 s ok=0
 s y=$p(token,"Bearer ",2)
 S ^BEARER=token
 s p=$$DECODE^BASE64($p(y,".",2))
 i p["Vt5ScFwss" do
 .k b
 .D DECODE^VPRJSON($name(p),$name(b),$name(err))
 .set ZCOGID=$get(b("sub"))
 .set un=ZCOGID
 .; call node token validation endpoint here (when it has been deployed)
 .s ok=1
 .quit
 quit ok
