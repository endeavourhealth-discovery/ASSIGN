UPRNACT ; ; 9/21/20 12:57pm
 ;
INT ;
 set ^%W(17.6001,131,0)="GET"
 set ^%W(17.6001,131,1)="api/activity"
 set ^%W(17.6001,131,2)="ACT^UPRNACT"
 set ^%W(17.6001,"B","GET","api/activity","ACT^UPRNACT",131)=""
 QUIT
 
ACT(result,arguments) 
 N J,U,I,REC,Z
 K ^TMP($J)
 S C=1
 S ^TMP($J,C)="[",C=$I(C)
 S U=$get(arguments("u"))
 
 S I=""
 F  S I=$O(^ACTIVITY(U,I),-1) Q:I=""  D
 .S REC=^(I)
 .S J=$$JSON(REC)
 .S ^TMP($J,C)=J
 .S C=$I(C)
 .QUIT
 
 I '$D(^ACTIVITY(U)) DO
 .S REC="?~?~"
 .S J=$$JSON(REC)
 .S ^TMP($J,2)=J
 .S C=3
 .QUIT
 
 S Z=$O(^TMP($J,""),-1)
 I Z'="" DO
 .S REC=^TMP($J,Z)
 .S REC=$E(REC,1,$L(REC)-1)
 .S ^TMP($J,Z)=REC
 .QUIT
 S ^TMP($J,C)="]"
 
 set result("mime")="application/json, text/plain, */*"
 set result=$na(^TMP($J))
 QUIT
 
JSON(REC) ;
 N JS,TXT,FILE,DAT,D,T,HD,HT
 S JS=""
 S DAT=$P(REC,"~",1)
 S D=$P(DAT,","),T=$P(DAT,",",2)
 S HD=$$HD^STDDATE(D),HT=$$HT^STDDATE(T)
 ;S HD="1",HT="2"
 S TXT=$P(REC,"~",2)
 S FILE=$P(REC,"~",3)
 S JS="{""DT"":"""_HD_":"_HT_""","
 S JS=JS_"""A"":"""_TXT_""","
 I FILE'="" S JS=JS_"""F"":"""_FILE_"""},"
 I FILE="" S JS=$E(JS,1,$L(JS)-1)_"},"
 QUIT JS
 
TEST ;
 S U="b786234a-edfd-4424-b87f-d0ea7ee8949b"
 S I=3
 S ^ACTIVITY(U,I)=$H_"~Ready to be downloaded~50000.txt"
 S I=2
 S ^ACTIVITY(U,I)=$H_"~File 50000.txt uploaded~"
 S I=1
 S ^ACTIVITY(U,I)=$H_"~Successfully signed in"
 Q
