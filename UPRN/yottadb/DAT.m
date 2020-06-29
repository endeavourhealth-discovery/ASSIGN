DAT ;Date Time Uitilities [ 03/15/2012  1:41 PM ] ; 11/14/19 9:18am
 ;
PD(DAT) ;Slashed date and time format
 N I,Q
 S DAT=$TR(DAT,".","/")
 F I=1:1:3 I $P(DAT,"/",I)?1N S $P(DAT,"/",I)=0_$P(DAT,"/",I)
 Q DAT
DATE(STR)          ;validates a date input
 I $$AD^LIB(STR)="" D ER^LIB(10) Q 0
 I $$AD^LIB(STR)]TDAY D ER^LIB(35) Q 0
 Q 1
FT(TIME) ;Gets date and time in CCYYMMDDHHMM format
 N DATE
 S DATE=$$FH($$DH($P(TIME,",")))
 S TIME=$$L0($$TH($P(TIME,",",2)))
 S DATE=DATE_$TR(TIME,":","")
 Q DATE
TF(DATE,TIME) ;Returns date and time from CCYYMMDDHHMM format
 ;DATE is full calling variable
 S TIME=$E(DATE,9,10)_":"_$E(DATE,11,12)
 S DATE=$$NH($E(DATE,1,8))
 Q DATE
FH(DAT) ;Returns date in CCYYMMDD format
 I DAT="" Q ""
 S DAT=$TR(DAT," ",".")
 S DAT=$TR(DAT,"/",".")
 N CC,YY,MM,DD
 S CC=19
 S YY=$P(DAT,".",3) I YY?4N S CC=$E(YY,1,2),YY=$E(YY,3,4)
 S MM=$P(DAT,".",2) I MM?1N S MM=0_MM
 S DD=$P(DAT,".") I DD?1N S DD=0_DD
 S DAT=CC_YY_MM_DD
 Q DAT
NH(DAT) ;Returns date from CCYYMMDD format
 N CC,YY,MM,DD
 S YY=$E(DAT,1,4) I $E(YY,1,2)=19 S YY=$E(YY,3,4)
 S MM=$E(DAT,5,6)
 S DD=$E(DAT,7,8)
 S DAT=DD_"."_MM_"."_YY
 Q DAT
 
DM(D1,D2)          ;Date difference in months
 ;D1 and D2 are in normal date format
 S D1=$TR(D1," ",".")
 S D2=$TR(D2," ",".")
 S DIF=$P(D2,".",2)+(12*$P(D2,".",3))-($P(D1,".",2)+(12*$P(D1,".",3)))
 I $P(D1,".")>$P(D2,".") S DIF=DIF-1
 Q DIF
HT(ZX) ;Time to $H format
 ;Returns ZX as nul if error
 N ZY
 S ZY=ZX
 I ZX?1N1":".E S ZX=0_ZX
 I ZX?2N1":"1N S ZX=$E(ZX,1,3)_0_$E(ZX,4)
 ;invalid format
 I ZX'?2N1":"2N S ZX="" Q ZX
 ;Strips off leading 0
 I $P(ZX,":",1)>24 S ZX="" Q ZX
 I $P(ZX,":",2)>60 S ZX="" Q ZX
 S ZX=$P(ZX,":",1)*3600+($P(ZX,":",2)*60)
 S ZX=$TR($J(ZX,5)," ",0)
 Q ZX
 ;
PM(ZX) ;redisplays time as a.m or p.m from HH:MM format
 I ZX>12 S ZX=ZX-12_":"_$P(ZX,":",2)_" pm" Q ZX
 I $E(ZX,1)=0 S ZX=$E(ZX,2,5)
 S ZX=ZX_" am" Q ZX
 
TM(ZX,ZY,ZZ) ;Calculates a time from a variable equivalent to $H part 2
 ;ZX is a variable of $H type
 ;if ZX is not defined it is derived from $H
 I '$D(ZX) S ZX=$P($H,",",2)
 S ZY=ZX\60
 S ZZ=$S(ZY<720:" am",1:" pm")
 S ZX=($S(ZY\60>12:ZY\60-12,1:ZY\60))_":"_($S(ZY#60>9:ZY#60,1:"0"_(ZY#60)))_ZZ
 Q ZX
TH(ZX,AM) ;Calculates a 24 hr format time
 ;AM is a flag to indicate morning/afertoon format
 N ZY,ZZ
 ;ZX is a variable of $H type
 S ZY=ZX\60
 
 S ZX=($S(ZY\60?1N:0_(ZY\60),1:(ZY\60)))_":"_($S(ZY#60>9:ZY#60,1:"0"_(ZY#60)))
 I $D(AM) S ZY=ZY\60 S:ZY>12 ZY=ZY-12 S $P(ZX,":",1)=ZY
 Q ZX
DY(ZX) ;Gets day of week from $H format day
 S ZX=$P("Thursday Friday Saturday Sunday Monday Tuesday Wednesday"," ",ZX#7+1)
 Q ZX
HD(ZX,ZD,ZM,ZY) ;date to $H format valid format only
 N %DN
 I ZX?4N S ZX="1.1."_ZX
 S ZX=$TR(ZX,". ,-","////")
 I ZX?1N.N1"/"1N.N S ZX="1/"_ZX
 I ZX'?.N1"/".N1"/".N S ZX="" Q ZX
 S ZD=$P(ZX,"/",1),ZM=$P(ZX,"/",2),ZY=$P(ZX,"/",3)
 S %5=ZX 
 I ZM>12!(ZD>31) S ZX="" Q ZX
 S:ZY<100 ZY=19_ZY
 S %DN=+ZM_"/"_+ZD_"/"_$S($E(ZY,1,2)="19":$E(ZY,3,4),1:ZY),%4=ZY-1\4-(ZY-1\100)+(ZY-1\400)-446,%DN=366*%4+(ZY-1841-%4*365)+ZD
 F %4=31,$S(ZY#4:28,ZY#100:29,ZY#400:28,1:29),31,30,31,30,31,31,30,31,30,31 S ZM=ZM-1 Q:ZM=0  S %DN=%DN+%4
 I $L(%DN)<5 S %DN=$E("0000",1,5-$L(%DN))_%DN
 I ZD'>%4*ZD>0 S ZX=%DN Q ZX
 S ZX="" Q ZX
 ;
DH(ZX,ZY) ;Date from $H format
 q:ZX="11111" "NK"   ; RMI 4583
 N %D,%I,%LY,%M,%R,%Y,%NP,p
20 S ZX=ZX>21914+ZX
 S %LY=ZX\1461,%R=ZX#1461,%Y=%LY*4+1841+(%R\365),%D=%R#365,%M=1
 I %R=1460,%LY'=14 S %D=365,%Y=%Y-1
 F %I=31,(%R>1154)&(%LY'=14)+28,31,30,31,30,31,31,30,31,30 Q:%I'<%D  S %M=%M+1,%D=%D-%I
 I %D=0 S %Y=%Y-1,%M=12,%D=31
 S p=$P(ZX,".",2)
 I $D(ZY) S ZX=%M_"/"_%D_"/"_%Y Q ZX
 I p=3 do  Q ZX
 . I %Y?2N S %Y=19_%Y
 . S ZX=%Y
 i p=2 S ZX=%M_"."_%Y Q ZX
 S ZX=%D_"."_%M_"."_%Y Q ZX
 Q ZX
 ;
L0(TIME) ;fills any time with leading zeroes
 ;TIME is in 24 hr format H:M
 I TIME?2N1":"2N Q TIME
 I $P(TIME,":",1)?1N S TIME=0_TIME
 I $P(TIME,":",2)?1N S $E(TIME,4,5)=0_$E(TIME,4)
 Q TIME
DF(D1,D2)          ;difference between 2 dates
 ;D1 and D2 are dates in normal format
 ;expressed as earlier date D1 later D2
 N DIF
 S D1=$$HD(D1)
 S D2=$$HD(D2)
 S DIF=D2-D1
 Q DIF
 ;##Packaged on 62619,35792 for (13579) uci/patch=29/3215
