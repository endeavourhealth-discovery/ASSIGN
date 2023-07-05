XLFUTL
	;
DEC(N,B) ;Cnv N from B to 10
 Q:B=10 N N I,Y S Y=0
 F I=1:1:$L(N) S Y=Y*B+($F("0123456789ABCDEF",$E(N,I))-2)
 Q Y
 
CNV(N,B) ;Cnv N from 10 to B
 Q:B=10 N N I,Y S Y=""
 F I=1:1 S Y=$E("0123456789ABCDEF",N#B+1)_Y,N=N\B Q:N<1
 Q Y