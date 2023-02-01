POUR5 ; ; 1/31/23 11:30am
 quit
 
H(h) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=h_$c(13,10)
 quit
 
STOP(result,arguments) ;
 lock ^KRUNNING(un):0.5
 if $t s ^TMP($J,1)="{""upload"": { ""status"": ""You have nothing running to stop""}}"
 else  s ^TSTOP(un)="",^TMP($J,1)="{""upload"": { ""status"": ""Stop flag set - click on Run Status to see if the run has been successfully stopped""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
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
