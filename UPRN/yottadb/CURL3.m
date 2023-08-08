CURL3 ; ; 7/24/23 9:53am
 quit
 
COGNITO(token) ;
 new ok,j,b,p,y
 if token="" q 0
 s ok=0
 SET ^BEARER1=token
 s y=$p(token,"Bearer ",2)
 S ^BEARER=token
 s p=$$DECODE^BASE64($p(y,".",2))
 i p["Vt5ScFwss" do
 .k b
 .D DECODE^VPRJSON($name(p),$name(b),$name(err))
 .set ZCOGID=$get(b("sub"))
 .set un=ZCOGID
 .S ok=$$EMAILCHK(.b)
 .i ok=-2 quit
 .s ok=$$VALTOKEN(token)
 .i ok="false"!(ok="") set ok=-3 quit
 .s ok=1
 .quit
 quit ok
 
EMAILCHK(b) 
 new zok,email,domain
 set zok=-2
 set email=$$LC^LIB($get(b("email")))
 set domain=$$LC^LIB($p(email,"@",2))
 i $get(^ICONFIG("COG-DOMAIN",domain))'="" set zok=1
 i $get(^ICONFIG("COG-EMAIL",email))'="" set zok=1
 quit zok
 
VALTOKEN(token) 
 n command,x,cnt,oldio
 
 S oldio=$io
 
 set endpoint=$GET(^ICONFIG("COGNITO-ENDPOINT"))
 set cmd="curl -H ""Authorization: "_token_""" "_endpoint
 
 D SH(cmd)
 
 s f="/tmp/sh"_$j_".sh"
 set cmd="cd /tmp && chmod +x "_f_" && ./sh"_$j_".sh"
 O "D":(shell="/bin/sh":command=cmd):0:"pipe"
 U "D"
 set cnt=1
 F  U "D" R x Q:$zeof  set x(cnt)=x,cnt=$i(cnt)
 c "D"
 
 o f:(readonly)
 c f:delete
 use oldio
 
 set cnt=$O(x(""),-1)
 
 S ^x=$get(x(cnt))
 S x=$get(x(cnt))
 quit x
 
SH(cmd) ;
 new f
 s f="/tmp/sh"_$j_".sh"
 close f
 o f:(newversion)
 use f w cmd
 close f
 quit