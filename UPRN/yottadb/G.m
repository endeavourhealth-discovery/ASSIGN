G ;G       GLOBAL DISPLAY ( VERSION 2.4 -16.3.1990 [ 05/14/2018  4:48 PM ]
	;D OFF^CASE
	;	
VAR S N=6
SET W !,"Global ^" R STR  Q:STR=""  S GLOB="^"_STR
	I '$D(@GLOB) W *7,"  NOT DEFINED " G G
	I $D(@GLOB)=1!($D(@GLOB)=11) W "   ",GLOB,"=",@GLOB
	S ND=1,NEXT=""
SUB W !,"node ",ND," : " R STR I STR'="" S:NEXT'="" NEXT=NEXT_""","""_STR S:NEXT="" NEXT=STR S ND=ND+1 G SUB
	S A=GLOB_"("_""""_NEXT_""""_")"
	I A'[("""""") I $D(@A)=1!($D(@A)=11) W !,A," = ",@A
	S NEXT=$Q(@A) G:NEXT="" G
B ;
	W !,NEXT,"=",@NEXT
NEXT S NEXT=$Q(@NEXT) G:NEXT="" G
DIS W !,NEXT,"=",@NEXT
	S ND=ND+1 I '(ND#5) R T
	R K:0 G:K'="" G
	G NEXT
OUT Q
GLOB(GLOB) 	;
		S A=GLOB_"("""""""")"
		S NEXT=$Q(@A)
		I NEXT="" W !,"Undefined" q
		s ND=1
		G NEXT
	;