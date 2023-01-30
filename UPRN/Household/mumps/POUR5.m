POUR5 ; ; 1/27/23 12:39pm
 quit
 
H(h) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=h_$c(13,10)
 quit
 
WEBHELP(result,arguments) ;
 K ^TMP($J)
 ;do H("<h1 style=""background-color:DodgerBlue;"">PoR utility v0.4 (Help)</h1>")
 ; do H("<b>Hello world</b>")
 set f="/tmp/PoR_tech_docx.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .D H(str)
 .quit
 close f
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
