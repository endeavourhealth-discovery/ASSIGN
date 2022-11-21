POUR3 ; ; 11/21/22 10:21am
 quit
 
SETUP ;
 set ^%W(17.6001,"B","GET","salt/stt","STT^POUR3",650912)=""
 S ^%W(17.6001,650912,"AUTH")=2
 
 S ^%W(17.6001,"B","POST","salt/save","SAVE^POUR3",650920)=""
 S ^%W(17.6001,650920,"AUTH")=2
 quit
 
STT(result,arguments) ;
 new c
 kill ^TMP($j)
 
 D REFRESH("")
 
 ;do H("<html>")
 
 ;do H("<form action=""/salt/save"" method=""post"">")
 ;do H("<table border=1>")
 
 ;do H("<td>SALT</td><td><input type=""text"" name=""salt""></td><tr>")
 ;do H("<td></td><td><input type=""submit"" name=""submit"">")
 ;do H("</table>")
 ;do H("</form>")
 ;do H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
REFRESH(error) ;
 do H("<html>")
 do H("<h1 style=""background-color:DodgerBlue;"">PoR utility v0.3</h1>")
 do H("<form action=""/salt/save"" method=""post"">")
 
 do H("<p>Please enter the salt name that you used to pseudonymise the nhs numbers in the file you intend to upload</p>")
 
 do H("<table border=1>")
 
 do H("<td>SALT</td><td><input type=""text"" name=""salt"" maxlength=""50"" size=""50""></td><tr>")
 if error'="" do H("<td></td><td style=""color:Tomato;"">"_error_"</td><tr>")
 do H("<td></td><td><input type=""submit"" name=""submit""><tr>")
 
 do H("</table>")
 do H("</form>")
 do H("</html>")
 quit
 
SAVE(arguments,body,result) 
 new s,r,a
 
 k ^TMP($J)
 
 kill ^POUR3
 m ^POUR3("body")=body
 m ^POUR3("args")=arguments
 
 ; validate salt
 set body=$get(body(1))
 set salt=$p($piece(body,"salt=",2),"&")
 
 do SALTS(.s)
 
 S ^S=salt
 if salt'="",'$data(s(salt)) D REFRESH("salt does not exist")
 
 if $data(s(salt)) do
 .s a("salt")=salt
 .do STT^POUR2(.r,.a)
 .quit
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
SALTS(salts) ;
 new element
 set element=""
 kill salts
 for  s element=$order(^SALTS("pseudo_salts",element)) q:element=""  do
 .s name=^(element,"saltKeyName")
 .set salts(name)=""
 .quit
 quit
 
H(H) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=H_$c(13,10)
 quit
