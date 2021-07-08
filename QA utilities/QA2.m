QA2 ; ; 5/2/21 9:23am
 S Q="",ADR=""
 F  S Q=$O(^CANDS(Q)) Q:Q=""  DO
 .F  S ADR=$O(^CANDS(Q,ADR)) Q:ADR=""  DO
 ..S T(Q)=$GET(T(Q))+1
 ZWR T
 QUIT
 
SPEED ;
 S ADR=""
 F  S ADR=$O(^CIDX(ADR)) Q:ADR=""  DO
 .S S=$P($H,",",2)
 .K ^TPARAMS($J)
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .S J=^temp($j,1)
 .;K B
 .;D DECODE^VPRJSON($NAME(J),$NAME(B),$NAME(E))
 .S UPRN=$GET(B("UPRN"))
 .S E=$P($H,",",2)
 .W !,ADR
 .W !,UPRN
 .S D=E-S
 .I D>1 W !,D,">>>> ",UPRN," * ",ADR R *Y
 .;
 .QUIT
 QUIT
