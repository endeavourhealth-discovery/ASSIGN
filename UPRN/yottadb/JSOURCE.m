JSOURCE ; ; 1/19/21 1:07pm
 set ^%W(17.6001,"B","GET","api2/jsource","STT^JSOURCE",601)=""
 set ^%W(17.6001,601,0)="GET"
 set ^%W(17.6001,601,1)="api2/jsource"
 set ^%W(17.6001,601,2)="STT^JSOURCE"
 
 set ^%W(17.6001,"B","GET","api2/jsourceall","ALL^JSOURCE",671)=""
 set ^%W(17.6001,671,0)="GET"
 set ^%W(17.6001,671,1)="api2/jsourceall"
 set ^%W(17.6001,671,2)="ALL^JSOURCE"
 QUIT
 
ALL(result,arguments) 
 K ^TMP($J)
 S (TYPE,UPRN,ZD,ZT)=""
 S L=1
 F  S TYPE=$O(^SOURCE(TYPE)) Q:TYPE=""  DO
 .F  S UPRN=$O(^SOURCE(TYPE,UPRN)) Q:UPRN=""  DO
 ..S ZD=$O(^SOURCE(TYPE,UPRN,""),-1)
 ..I ZD="" QUIT
 ..S ZT=$O(^SOURCE(TYPE,UPRN,ZD,""),-1)
 ..S OUT=UPRN_"|"_TYPE_"|"_^SOURCE(TYPE,UPRN,ZD,ZT)
 ..S ^TMP($J,L)=OUT_$C(13,10),L=L+1
 ..QUIT
 .QUIT
 S result("mime")="text/plain, */*"
 S result=$NA(^TMP($J))
 QUIT
 
STT(result,arguments) ;
 S j="{""jsource"": { ""status"": ""NOK""}}"
 S uprn=$get(arguments("uprn"))
 S node=$g(arguments("node"))
 S zh=$order(^SOURCE(node,uprn,""),-1)
 I zh="" do  quit
 .S ^TMP($J,1)=j
 .S result=$na(^TMP($J))
 .quit
 S zt=$order(^SOURCE(node,uprn,zh,""),-1)
 S j=$get(^SOURCE(node,uprn,zh,zt))
 S ^TMP($J,1)=j
 S result=$na(^TMP($J))
 QUIT
