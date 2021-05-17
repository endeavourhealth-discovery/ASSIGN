UPRNC ;Additional aglorithms [ 05/12/2021  10:36 AM ]
match63(tpost,tstreet,tbno,tbuild,tflat,tloc,tdeploc)     ;
 ;location in street, building drop
 i tbuild["home" d
 .i tbno'="",tstreet'="",tflat="" d
 ..s nstreet=$O(^UPRNX("X5",tpost,tstreet))
 ..i (nstreet_" ")[(tstreet_" ") d
 ...i $D(^UPRNS("ROAD",$p(nstreet," ",$l(tstreet," ")+1,20))) d
 ....s matchrec="Pe,Se,Ne,Bd,Fe"
 ....s $p(ALG,"-",2)="match63e"
 ....s matched=$$setuprns^UPRN("X5",tpost,nstreet,tbno,"","")
 I $D(^TUPRN($J,"MATCHED")) Q 1
 I tstreet'="",tloc'="",tbno'="" D
 .I $D(^UPRNX("X5",tpost,tstreet_" "_tloc,tbno)) d
 ..I tflat="" d
 ...i $D(^UPRNX("X5",tpost,tstreet_" "_tloc,tbno,"","")) d
 ....s matchrec="Pe,Se,Ne,Bd,Fe"
 ....s $p(ALG,"-",2)="match63d"
 ....S matched=$$setuprns^UPRN("X5",tpost,tstreet_" "_tloc,tbno,"","")
 I $D(^TUPRN($J,"MATCHED")) Q 1
 ;Last pattern
 n matched
 s matched=0
 i tdeploc'="",tbno'="",tstreet'="" d
 .I $D(^UPRNX("X5",tpost,tdeploc,tbno,tstreet)) d
 ..s matched=0
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tdeploc,tbno,tstreet,flat)) q:flat=""  d  q:matched
 ...I $$MPART^UPRNU(flat,tbuild) d
 ....s matchrec="Pe,Se,Ne,Be,F<B"
 ....S $P(ALG,"-",2)="match63"
 ....s matched=$$setuprns^UPRN("X5",tpost,tdeploc,tbno,tstreet,flat)
 i matched q matched
 ;Building = street
 i tbuild=tstreet,tdeploc'="" d
 .I tflat="",tstreet'="",tbno'="",tdeploc'="" D
 ..I $D(^UPRNX("X5",tpost,tdeploc,"",tstreet,tbno)) d
 ...s matchrec="Pe,Se,N>F,Be,F<N"
 ...S $P(ALG,"-",2)="match63a"
 ...s matched=$$setuprns^UPRN("X5",tpost,tdeploc,"",tstreet,tbno)
 ;
 ;Dig out street from street
 f i=2:1:$l(tstreet," ")-1 d  q:matched
 .s tstr=$p(tstreet," ",1,i)
 .I $D(^UPRNX("X.STR",tstr)) d
 ..I $D(^UPRNX("X5",tpost,tstr,tbno)) d
 ...i tflat=""  d
 ....I $D(^UPRNX("X5",tpost,tstr,tbno,"","")) d
 .....s matchrec="Pe,Sp,Ne,Bd,Fe"
 .....s $P(ALG,"-",2)="match63b"
 .....s matched=$$setuprns^UPRN("X5",tpost,tstr,tbno,"","")
 ;
 i matched q matched
 ;Dig out street from building and number from flat if building is stret
 i tbno="" d
 .I $D(^UPRNX("X.STR",tbuild)) d
 ..I '$D(^UPRNX("X.STR",tstreet)) d
 ...I $p(tflat," ",$l(tflat," "))?1n.n.l d
 ....s tstno=$p(tflat," ",$l(tflat," "))
 ....I $D(^UPRNX("X5",tpost,tbuild,tstno,"","")) d
 .....s matchrec="Pe,S<B,N<F,B>S,Fd"
 .....S $P(ALG,"-",2)="match63c"
 .....s matched=$$setuprns^UPRN("X5",tpost,tbuild,tstno,"","")
 q matched
