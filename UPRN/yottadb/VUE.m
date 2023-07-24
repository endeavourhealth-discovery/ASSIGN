VUE ; ; 7/21/23 1:23pm
 ;
 QUIT
 
INT ;
 s ^%W(17.6001,"B","POST","api2/fileupload2","UPLOAD^VUE",1001)=""
 s ^%W(17.6001,1001,0)="POST"
 s ^%W(17.6001,1001,1)="api2/fileupload2"
 s ^%W(17.6001,1001,2)="UPLOAD^VUE"
 s ^%W(17.6001,1001,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","api2/activity","ACT^VUE",1002)=""
 S ^%W(17.6001,1002,0)="GET"
 S ^%W(17.6001,1002,1)="api2/activity"
 S ^%W(17.6001,1002,2)="ACT^VUE"
 S ^%W(17.6001,1002,"AUTH")=2
 
 s ^%W(17.6001,"B","GET","api2/filedownload2","DOWNLOAD^VUE",1003)=""
 S ^%W(17.6001,1003,0)="GET"
 S ^%W(17.6001,1003,1)="api2/filedownload2"
 S ^%W(17.6001,1003,2)="DOWNLOAD^VUE"
 S ^%W(17.6001,1003,"AUTH")=2
 
ZREG ; register
 set ^%W(17.6001,"B","POST","api2/register","REG^VUE",567774)=""
 set ^%W(17.6001,567774,"AUTH")=2
 
 ; get register
 set ^%W(17.6001,"B","GET","api2/getreg","GETREG^VUE",567779)=""
 set ^%W(17.6001,567779,"AUTH")=2
 QUIT
 
REG(arguments,body,result) 
 S ZRET=$$REG^UPRNUI2(.arguments,.body,.result)
 QUIT ZRET
 
UPLOAD(arguments,body,result) 
 S ZRET=$$UPLOAD^UPRNUI2(.arguments,.body,.result)
 QUIT ZRET
 
GETREG(result,arguments) 
 D GETREG^UPRNUI2(.result,.arguments)
 QUIT
 
ACT(result,arguments) 
 D ACT^UPRNACT(.result,.arguments)
 QUIT
 
DOWNLOAD(result,arguments) 
 D DOWNLOAD^UPRNUI2(.result,.arguments)
 QUIT
