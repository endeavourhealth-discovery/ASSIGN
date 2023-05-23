UPRNC ;Additional aglorithms [ 05/22/2023  5:09 PM ]
match67(tpost,tbuild,tflat,tbno,tstreet) ;
 n wno,next,st,word,build
 I tbuild'="" d  Q $G(^TUPRN($J,"MATCHED"))
 .f wno=1:1:$l(tbuild," ") d
 ..s word=$p(tbuild," ",wno)
 ..s st=$e(word,1,2),next=st
 ..for  s next=$O(^UPRNX("X.W",next)) q:($e(next,1,2)'=st)  d  q:matched
 ...i next=word q
 ...i next'?1l.l."'".".".l q
 ...i '$$levensh^UPRNU(word,next,5,2) q
 ...S build=$$tr^UPRNL(tbuild,word,next)
 ...i '$D(^UPRNX("X3",build,tflat)) q
 ...s matched=$$match67a(tpost,build,tflat,tbno,tstreet)
 i tstreet'="" s matched=$$match67a(tpost,tbuild,tflat,tbno,tstreet)
 Q $G(^TUPRN($J,"MATCHED"))
match67a(tpost,tbuild,tflat,tbno,tstreet) ;
 n wno,next,st,word,build,matched
 s matched=0
 i tstreet'="" d  Q $G(^TUPRN($J,"MATCHED"))
 .f wno=1:1:$l(tstreet," ") d
 ..s word=$p(tstreet," ",wno)
 ..s st=$e(word,1,2),next=st
 ..for  s next=$O(^UPRNX("X.W",next)) q:($e(next,1,2)'=st)  d  q:matched
 ...i next'?1l.l."'".".".l q
 ...i '$$levensh^UPRNU(word,next,5,2) q
 ...S street=$$tr^UPRNL(tstreet,word,next)
 ...i '$D(^UPRNX("X3",street,tbno)) q
 ...s post=""
 ...for  s post=$O(^UPRNX("X3",street,tbno,post)) q:post=""  d  q:matched
 ....i '$D(^UPRNX("X5",post,street,tbno,tbuild,tflat)) q
 ....i $$nearpost^UPRN(post,tpost)="" d
 ....s matched=$$setuprns^UPRN("X5",post,street,tbno,tbuild,tflat)
 q matched
match66(tpost,tbuild,tflat,tbno,tstreet) ;
 s post=""
 for  s post=$O(^UPRNX("X3",tstreet,tbno,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
 .q:post=tpost
 .s matchrec=$$nearpost^UPRN(post,tpost,2,1)
 .I matchrec'="" d
 ..I $D(^UPRNX("X5",post,tstreet,tbno,tbuild,tflat)) d
 ...S ALG=ALG_"match66"
 ...s matched=$$setuprns^UPRN("X5",post,tstreet,tbno,tbuild,tflat)
 Q $G(^TUPRN($J,"MATCHED"))
 ; 
match65(tpost,tbuild,tflat,tbno,tstreet) ;
 i tbno'="",tstreet'="",$D(^UPRNS("NUMWORD",tbno)) d
 .s tstreet=^UPRNS("NUMWORD",tbno)_" "_adstreet
 .s tdbno=""
 s post=""
 for  s post=$O(^UPRNX("X3",tbuild,tflat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
 .q:post=tpost
 .s matchrec=$$nearpost^UPRN(post,tpost,2,1)
 .I matchrec'="" d  q:$D(^TUPRN($J,"MATCHED"))
 ..s street=""
 ..for  s street=$O(^UPRNX("X5",post,street)) q:street=""  d
 ...s bno=$O(^UPRNX("X5",post,street,""))
 ...i tstreet=street d
 ....s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
 ....S ALG=ALG_"match65"
 ....s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
 ...i tstreet="",tbno="" d
 ....S $P(ALG,"-",2)="match65a"
 ....s $p(matchrec,",",2,5)="Si,Ni,Be,Fe"
 ....s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
 ...i tstreet'=street,bno="",tbno="" d
 ....f flat=tflat+1,tflat-1 d
 .....;next door?
 .....i $D(^UPRNX("X5",tpost,tstreet,"",tbuild,flat)) d
 ......s $P(ALG,"-",2)="match65b"
 ......s matchrec="Pl,Si,Ne,Be,Fe"
 ......s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
e63 Q $G(^TUPRN($J,"MATCHED"))
match64(tpost,tbuild,tflat,tbno,tstreet) ;
 s post=""
 for  s post=$O(^UPRNX("X3",tbuild,tflat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
 .q:post=tpost
 .s matchrec=$$nearpost^UPRN(post,tpost,2)
 .I matchrec'="" d  q:$D(^TUPRN($J,"MATCHED"))
 ..s street=""
 ..for  s street=$O(^UPRNX("X5",post,street)) q:street=""  d
 ...i tstreet="",tbno="" d
 ....i $D(^UPRNX("X5",post,street,tbno,tbuild,tflat)) d
 .....s $p(matchrec,",",2,5)="Si,Ne,Be,Fe"
 .....S ALG=ALG_"match64"
 .....s matched=$$setuprns^UPRN("X5",post,street,"",tbuild,tflat)
e63 Q $G(^TUPRN($J,"MATCHED"))
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
