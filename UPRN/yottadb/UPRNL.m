UPRNL ;Library Extrinsic Functions and parameter passed subrtns [ 05/22/2023  1:00 PM ]
uc(zx) ;Upper Case Conversion
 S zx=$TR(zx,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 Q zx
 ;
lc(zx) ;Lower Case Conversion
 S zx=$TR(zx,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz") Q zx
 ;
lt(zx) ;Leading and trailing spaces
 F  Q:$E(zx)'=" "  S zx=$E(zx,2,255)
 F  Q:$E(zx,$L(zx))'=" "  S zx=$E(zx,1,$L(zx)-1)
 Q zx
 ;
tr(zx,zy,zz)       ;translate a string
 ;zx is the variable
 ;zy is the string to translate
 ;zzis the string to tranlsate to
 N zw
 S zw=0
 FOR  S zw=$F(zx,zy,zw) Q:zw=0  S zw=zw-$L(zy)-1 S zx=$E(zx,0,zw)_zz_$E(zx,zw+$L(zy)+1,200),zw=zw+$L(zz)+1
 Q zx
in(ZX) ;Initial Capitals
 N ZY
 ;S ZX=$$LT(ZX)
 S ZX=$TR(ZX,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 F ZY=1:1:$L(ZX) I $A(ZX,ZY)>96&($A(ZX,ZY)<123) DO
 . I $E(ZX,ZY-1)="'" Q
 . S $E(ZX,ZY)=$C($A(ZX,ZY)-32) F  S ZY=ZY+1 I $A(ZX,ZY)<97!($A(ZX,ZY)>122) S ZY=ZY-1 Q
 Q ZX
 ;
