NEL ; ; 1/13/21 3:05pm
 ;
 S ^%W(17.6001,"B","GET","api2/getinfo","INT1^NEL",888)=""
 S ^%W(17.6001,888,"AUTH")=2
 S ^%W(17.6001,888,0)="GET"
 S ^%W(17.6001,888,1)="api2/getinfo"
 S ^%W(17.6001,888,2)="INT1^NEL"
 
 S ^%W(17.6001,"B","GET","api2/getuprn","INT2^NEL",889)=""
 S ^%W(17.6001,889,"AUTH")=2
 S ^%W(17.6001,889,0)="GET"
 S ^%W(17.6001,889,1)="api2/getuprn"
 S ^%W(17.6001,889,2)="INT2^NEL"
 QUIT
 
INT1(result,arguments) ;
 ;
 D GETMUPRN^UPRNHOOK2(.result,.arguments)
 ;zwr result
 ;
 QUIT
 ;
INT2(result,arguments) 
 S ^ZHERE=1
 M ^A=arguments
 D GETMUPRNI^UPRNHOOK2(.result,.arguments)
 S ^ZHERE(2)=1
 ;
 QUIT
