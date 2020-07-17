XLFUTL
	;
DEC(N,B) ;Cnv N from B to 10
 Q:B=10 N N I,Y S Y=0
 F I=1:1:$L(N) S Y=Y*B+($F("0123456789ABCDEF",$E(N,I))-2)
 Q Y