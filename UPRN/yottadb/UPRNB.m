UPRNB ;Best fit algorithms for UPRN match [ 05/18/2023  10:00 AM ]
 ;
bestfit(tpost,tstreet,tbno,tbuild,tflat,tloc)        ;
 ;Best fit algorithms on matched post code and street
 n (ALG,tpost,tstreet,tbno,tbuild,tflat,qpost,tloc)
 K ^TBEST($J),^TORDER($J),^TFLAT($j)
 ;
 s tstreet=$$plural^UPRNU(tstreet)
 s tbuild=$$plural^UPRNU(tbuild)
 i tpost=""!('$d(^UPRNX("X1",tpost))) d  q
 .d bestfitn
 .d farpost
 .d choose
 s matched=0
 ;debug global
 ;K ^DLS,^DLS1
 ;M ^DLS=^UPRNX("X5",tpost,tstreet,tbno)
 ;M ^DLS1=^UPRNX("X5",tpost,tstreet)
 d bestfitv
 i $g(^TUPRN($J,"MATCHED")) Q
 d bestfitb
 i $g(^TUPRN($J,"MATCHED")) Q
210120 d bestfitc
210120 d bestfitd
 d bestfito
 i $g(^TUPRN($J,"MATCHED")) Q
 d bestfitf
 i $g(^TUPRN($J,"MATCHED")) Q
 d bestfit1
 I $G(^TUPRN($J,"MATCHED")) Q
 d bestfitr
 I $G(^TUPRN($J,"MATCHED")) Q
 d bestfit2
 ;
CH ;Care home flag set?
 i $D(^TCQC($J)) d bestch
 I $G(^TUPRN($J,"MATCHED")) Q
 d bestfitn
 d bestfitx
 d farpost
 d bestfit4
 d choose
 I '$D(^TBEST($J)) d bestfit3
 q
 
choose i $d(^TBEST($J)) d
 .s matched=0
 .f fit=1:1 q:'$D(^UPRNS("BESTFIT",fit))  d  q:matched
 ..s matchrec=^UPRNS("BESTFIT",fit)
 ..I '$D(^TBEST($J,matchrec)) q
 ..s matched=$$best(matchrec,tpost,tstreet,tbno,tbuild,tflat)
 .f matchrec="Pe,Se,N>B,Bf,F>Be" d  q:matched
 ..s matched=$$best(matchrec,tpost,tstreet,tbno,tbuild,tflat)
 .i matched q
 q
bestfit4 ;Sibling number with a suffix
 ;ABP suffix number i.e. sibling match
 s sibling=0
 i tbno?1n.n,tbuild="",tflat="" d
 .f char=97:1:99 d  q:sibling
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno_$c(char),"","")) d
 ...s matchrec="Pe,Se,Ns,Be,Fe"
 ...S ^TBEST($j,matchrec,tbno_$c(char),"","")=""
 ...s sibling=0
 q
bestfitx ;Long shot with flat suffix in building
 I $D(^UPRNS("VERTICALS",tflat)) d
 .s qual=^(tflat)
 .s fflat=0
 .i qual="low" f char=97:1:102 d  q:fflat
 ..i $D(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char))) d
 ...I $D(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char),"")) d
 ....s matchrec="Pe,Se,N>B,Bf,F>Bd"
 ....s ^TBEST($J,matchrec,"",tbno_$c(char),"")=""
 ....s fflat=1
 ...s flat=""
 ...for  s flat=$O(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char),flat)) q:flat=""  d  q:fflat
 ....i flat?1n.n d
 .....s matchrec="Pe,Se,N>B,Bf,F>Be"
 .....S ^TBEST($J,matchrec,"",tbno_$c(char),flat)=""
 .....s fflat=1
 .s fflat=0
 .i qual'="low" f char=102:-1:97 d  q:fflat
 ..i $D(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char))) d
 ...I $D(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char),"")) d
 ....s matchrec="Pe,Se,N>B,Bf,F>Bd"
 ....s ^TBEST($J,matchrec,"",tbno_$c(char),"")=""
 ....s fflat=1
 ...s flat=""
 ...for  s flat=$O(^UPRNX("X5",tpost,tstreet,"",tbno_$c(char),flat),-1) q:flat=""  d  q:fflat
 ....i flat?1n.n d
 .....s matchrec="Pe,Se,N>B,Bf,F>Be"
 .....S ^TBEST($J,matchrec,"",tbno_$c(char),flat)=""
 .....s fflat=1
 q
best(matchrec,tpost,tstreet,tbno,tbuild,tflat)     ;
 s post=$G(^TBEST($j,matchrec))
 i post'="" s tpost=post
 q $$whichno(matchrec,tpost,tstreet,tbno,tbuild,tflat)
 q
 ;
mcount(build,tbuild)         ;
 n (build,tbuild)
 s count=0
 i build=tbuild q 100
 s var1="build",var2="tbuild"
 S @var1=$$plural^UPRNU(@var1)
 S @var2=$$plural^UPRNU(@var2)
 i $l(tbuild," ")>$l(build," ") d
 .s var1="tbuild",var2="build"
 f i=1:1:$l(@var1," ") d
 .s word=$p(@var1," ",i)
 .i (" "_@var2_" ")[(" "_word_" ") d
 ..s count=count+1
 .e  d
 ..i $l(word)<3 q
 ..i (" "_@var2_" ")[(" "_$e(word,1,3)) d
 ...s count=count+.5
 q count
exvert(flat)       ;Removes extraneous verticals
 s flat=$$tr^UPRNL(flat," flat","")
 q flat
eqfb(tbuild,tflat,build,flat)          ;
 ;Apparently equivalent flats and buildings
 n (tbuild,tflat,build,flat)
 s test=tflat_" "_tbuild
 s test1=flat_" "_build
 s matched=0,quit=0
 s tlen=$l(test)
 S t1len=$l(test1)
 s i2=t1len
 f i1=tlen:-1:1 d  q:quit
 .i $e(test,i1,tlen)=$e(test1,i2,t1len) d  q
 ..s i2=i2-1
 .s quit=1
 i i1=tlen q 0
 s tbld=$e(test,i1+1,tlen)
 s bld=$e(test1,i2+1,t1len)
 s tfl=$e(test,1,i1)
 s fl=$e(test1,1,i2)
 s tfl=$$correct^UPRNU(tfl)
 s fl=$$correct^UPRNU(fl)
 i $$eqflat(tfl,fl) s matched=1
 q matched
 
 q
 
eqflat(tflat,flat) ;Are they equivalent flats?
 n (tflat,flat)
 f var="tflat","flat" d
 .s @var=$$tr^UPRNL(@var,"&","and")
 .i $p(@var," ",$l(@var," "))["floor" s @var=$p(@var," ",0,$l(@var," ")-1)
 i tflat=flat q 1
 i tflat["flat",$p(tflat,"flat",1)?1l.l.e,$p(tflat,"flat ",2)=flat q 1
 i tflat?1"g"1n.n,$e(tflat,2,20)=flat q 1
 d swap^UPRNU(.tflat,.flat)
 d drop^UPRNU(.tflat,.flat)
 i tflat=flat q 1
 s count=0,wcount=$l(tflat," ")
 f i=1:1:$l(tflat," ") d
 .i (" "_flat_" ")[(" "_$p(tflat," ",i)_" ") s count=count+1
 i count=wcount q 1
 ;The block problem
 s equiv=0
 f var="tflat","flat" d  q:equiv
 .s var1=$s(var="tflat":"flat",1:"tflat")
 .i @var["block" d
 ..s wpos=$$fword(@var,"block")
 ..i wpos>0 i $p(@var," ",wpos+1)?1.l d
 ...i $p(@var," ",$l(@var," "))=@var1 s equiv=1
 q equiv
fword(text,word)   ;Finds a word piece
 n (text,word)
 s pos=0
 f i=1:1:$l(text," ") d
 .i $p(text," ",i)=word s pos=i
 q pos
 
isres(uprn)        ;
 n (uprn)
 s class=$G(^UPRN("CLASS",uprn))
 i class="" q 1
 i '$D(^UPRN("CLASSIFICATION",class)) q 1
 s res=$G(^UPRN("CLASSIFICATION",class,"residential"))
 i res="Y" q 1
 q 0
 
farpost ;No post code match
 n matched,post,town,loc
 s matched=0
 s tdist=$$district^UPRNU(tpost)
 i $D(^UPRNX("X3",tstreet,tbno)) d
 .i tflat'=""!(tbuild'="") d
 .s post=""
 .for  s post=$O(^UPRNX("X3",tstreet,tbno,post)) q:post=""  d  q:matched
 ..q:post=tpost
 ..i $$district^UPRNU(post)'=tdist q
 ..i $D(^UPRNX("X5",post,tstreet,tbno,tbuild,tflat)) d  q
 ...s matchrec="Pi,Se,Ne,Be,Fe"
 ...s ^TBEST($J,matchrec,tbno,tbuild,tflat)=""
 ...s ^TBEST($J,matchrec)=post
 ..i tbuild'="",tflat'="" d  q
 ...i $D(^UPRNX("X5",post,tstreet,tbno,"",tflat)) d
 ....s matchrec="Pi,Se,Ne,Bd,Fe"
 ....s ^TBEST($J,matchrec,tbno,"",tflat)=""
 ....s ^TBEST($J,matchrec)=post
 ..i tpost="",tbno'="",tstreet'="",tflat'="" d
 ...s flat=""
 ...for  s flat=$O(^UPRNX("X5",post,tstreet,tbno,tbuild,flat)) q:flat=""  d
 ....i $$eqflat(tflat,flat) d
 .....s matchrec="Pi,Se,Ne,Be,Fe"
 .....S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 .....s ^TBEST($J,matchrec)=post
 I $D(^TBEST($J)) q
 i tflat'="",tbuild'="" d
 .I $D(^UPRNX("X3",tstreet)) d
 ..s bno=""
 ..for  s bno=$O(^UPRNX("X3",tstreet,bno)) q:bno=""  d
 ...s post=""
 ...for  s post=$O(^UPRNX("X3",tstreet,bno,post)) q:post=""  d
 ....i post=tpost q
 ....s build=""
 ....for  s build=$O(^UPRNX("X5",post,tstreet,bno,build)) q:build=""  d
 .....i $D(^UPRNX("X5",post,tstreet,bno,build,tflat)) d
 ......i $$equiv^UPRNU(build,tbuild) d
 .......I $E(post,1,2)=$e(tpost,1,2) d
 ........i $$levensh^UPRNU(post,tpost,5,1) d
 .........s matchrec="Pl,Se,Ni,Bl,Fe"
 .........S ^TBEST($J,matchrec)=post
 .........S ^TBEST($J,matchrec,bno,build,tflat)=""
 q
 
bestfit1        ;
 ;Prefers a building flat match with abp number
 ;Candidate number must be null
 i tbno'="" q
 ;Flat and building must be not null
 i tflat=""!(tbuild="") q
 s build=$$dropf^UPRNU(tbuild)
 ;Must match on building and flat
 I '$D(^UPRNX("X3",tbuild,tflat,tpost)),'$d(^UPRNX("X3",build,tflat,tpost)) q
 ;ABP might have number
 s bno=""
 for  s bno=$O(^UPRNX("X5",tpost,tstreet,bno)) q:bno=""  d  q:matched
 .I $D(^UPRNX("X5",tpost,tstreet,bno,tbuild,tflat)) d
 ..s matchrec="Pe,Se,Ni,Be,Fe"
 ..S ^TBEST($J,matchrec,bno,tbuild,tflat)=""
 .I $D(^UPRNX("X5",tpost,tstreet,bno,build,tflat)) d
 ..s matchrec="Pe,Se,Ni,Be,Fe"
 ..S ^TBEST($J,matchrec,bno,build,tflat)=""
 
 ;ABP might have another street entirely
 s street=""
 for  s street=$O(^UPRNX("X5",tpost,street)) q:street=""  d
 .I $D(^UPRNX("X5",tpost,street,tbno,tbuild,tflat)) d
 ..s approx="i"
 ..i $$equiv^UPRNU(street,tstreet) s approx="e"
 ..i $$MPART^UPRNU(street,tstreet,1) s approx="p"
 ..s matchrec="Pe,S"_approx_",Ne,Be,Fe"
 ..S ^TBEST($J,matchrec,tbno,tbuild,tflat)=""
 ..S ^TBEST($J,matchrec,tbno)=street
 q
 
bestfit3 ;Swaps building and flat for street and number
 ;Drops street
 n (ALG,tpost,tstreet,tbuild,tbno,tflat)
        
 ;ABP has no street no number but thinks building and flat is street
 i tbno="",tstreet'="",tbuild'="",tflat'="" d
 .I $D(^UPRNX("X5",tpost,tbuild,tflat,"","")) d
 ..s matchrec="Pe,S<B,N<F,B>S,F>N"
 ..S ^TBEST($j,matchrec,tflat,"","")=""
 ..s tstreet=tbuild,tbno=tflat,tbuild="",tflat=""
 
 I $D(^TBEST($J)) d choose
 q
bestfit2 ;
 ;Flat might be ABP number suffix
 ;i.e. flat is known as number
 i tflat?1n.n1l d
 .I $D(^UPRNX("X5",tpost,tstreet,tflat,tbuild,"")) d
 ..s matchrec="Pe,Se,Nd,Be,F>N"
 ..s ^TBEST($J,matchrec,tflat,tbuild,"")=""
 q
 
        
sflat(text) ;Extra flat types e.g. studio
 n word
 I $D(^UPRNS("FLATEXTRA",$p(text," "))) q $P(text," ",2,20)
 q text
bestfitr        ;
 ;Checks for flat number with a range
 ;candidate may be number or range
 n (ALG,tpost,tstreet,tbno,tbuild,tflat)
 s matched=0
 i tbno?1n.n D
 .s rbno=tbno-3_"-"
 .for  s rbno=$o(^UPRNX("X5",tpost,tstreet,rbno)) q:rbno=""  q:($p(rbno,"-")>tbno)  d  q:matched
 ..i rbno'["-" q
 ..s lbno=$p(rbno,"-",2)
 ..i tbno'<(rbno*1),lbno'>tbno d
 ...I $D(^UPRNX("X5",tpost,tstreet,rbno,tbuild,tflat)) d
 ....s matchrec="Pe,Se,Ne,Be,Fp"
 ....s ^TBEST($J,matchrec,rbno,tbuild,tflat)=""
 q
 
 
bestfito ;
 ;Block number flat number alternative
 ;First Drops building
 ;Then goes for fuzzy building
 i tbno="" d
 .i $p(tflat," ",2)?1n.n d
 ..i $p(tflat," ",3)?1l d
 ...s suffix=$p(tflat," ",3)
 ...s number=$p(tflat," ",2)
 ...I $D(^UPRNX("X5",tpost,tstreet,number_suffix,"","")) d
 ....s matchrec="Pe,Se,Nf,Bd,Fp>N"
 ....s ^TBEST($J,matchrec,number_suffix,"","")=""
 ....S matched=1
 i matched q
 I tbno?1n.n1l d
 .s suffix=$p(tbno,tbno*1,2)
 .S fnum=$a(suffix)-96
 .i '$D(^UPRNX("X5",tpost,tstreet,tbno)) d
 ..f var="suffix","fnum" d  q:matched
 ...I $d(^UPRNX("X5",tpost,tstreet,tbno*1,tbuild,@var)) d
 ....s matchrec="Pe,Se,Nf,Be,Fp>N"
 ....S ^TBEST($J,matchrec,tbno*1,tbuild,@var)=""
 ....s matched=1
 ..I $d(^UPRNX("X5",tpost,tstreet,tbno*1,tbuild,tbno)) d
 ...s matchrec="Pe,Se,Np,Be,F=N"
 ...S ^TBEST($J,matchrec,tbno*1,tbuild,tbno)=""
 ...s matched=1
 .i matched q
 .i tflat="" d
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno*1,tbuild,flat)) q:flat=""  d
 ...i flat=suffix d  q
 ....s matchrec="Pe,Se,N>Ff,Be,Ff"
 ....S ^TBEST($J,matchrec,tbno*1,tbuild,flat)=""
 ...i $d(^UPRNS("FLOOR",flat,suffix)) d
 ....s matchrec="Pe,Se,N>Ff,Be,Ff"
 ....S ^TBEST($J,matchrec,tbno*1,tbuild,flat)=""
 i matched q
 
 ;Best of the fuzzy building matches
 ;Unit stratford / unite building
 ;If build the same find nearest flat
 ;If building partial flat must match
 n build,flat
 s matchrec="Pe,Se"
 i tflat'="",tbuild'="" d
 .s build=""
 .for  s build=$O(^UPRNX("X5",tpost,tstreet,tbno,build)) q:build=""  d  q:matched
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,build,flat)) q:flat=""  d
 ...i $$eqfb(tbuild,tflat,build,flat) d
 ....s matchrec="Pe,Se,Ne,Bf,Ff"
 ....S ^TBEST($J,matchrec,tbno,build,flat)=""
 s build=""
 for  s build=$O(^UPRNX("X5",tpost,tstreet,tbno,build)) q:build=""  d  q:matched
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,build,tflat)) d
 ..i ($$equiv^UPRNU(build,tbuild)) d  q
 ...s matchrec="Pe,Se,Ne,Be,Fe"
 ...S ^TBEST($J,matchrec,tbno,build,tflat)=""
 ..I $$MPART^UPRNU(build,tbuild,1) D  q
 ...s matchrec="Pe,Se,Ne,Bp,Fe"
 ...s ^TBEST($j,matchrec,tbno,build,tflat)=""
 .i tflat=""  d
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,build,flat)) q:flat=""  d
 ...i (flat_build=tbuild) d
 ....s matchrec="Pe,Se,Ne,B>F,Fe"
 ....s ^TBEST($J,matchrec,tbno,build,flat)=""
 ...i tbuild=build,flat?1l.l.e,flat["house" d
 ....s matchrec="Pe,Se,Ne,Bp,Fe"
 ....s ^TBEST($J,matchrec,tbno,build,flat)=""
 ...i $$equiv^UPRNU(tbuild,flat_" "_build) d
 ....s matchrec="Pe,Se,Ne,B>F,Fe"
 ....s ^TBEST($J,matchrec,tbno,build,flat)=""
 .i tflat'="" d
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,build,flat)) q:flat=""  d
 ...d fuzzy(tbno,tbuild,tflat,build,flat)
 q
 
bestfitf ;Judge between a flat building match and a number street match
 s matched=0
 i tbuild'="",tflat'="" d
 .I $D(^UPRNX("X5",tpost,tstreet,"",tbuild,tflat)) d
 ..s matchrec="Pe,Se,Nd,Be,Fe"
 ..s ^TBEST($J,matchrec,"",tbuild,tflat)=""
 I tbuild="",tflat="",tbno'="" d
 .s parent=0
 .s flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,"",flat)) q:flat=""  d  q:(tflat="")
 ..i $d(^UPRNS("VERTICALS",flat)) d
 ...s matchrec="Pe,Se,Ne,Be,Fp"
 ...S ^TBEST($J,matchrec,tbno,"",flat)=""
 s bno=tbno
m1 i tbno'="" I '$$mno^UPRN(tpost,tstreet,tbno,.bno) Q
 i tbno=bno d
 .s nummatch="Ne"
 e  d
 .s nummatch=$s(tbno="":"Ni",bno="":"Nd",1:"Ni")
 i tbuild'="" d
 .s flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,bno,tbuild,flat)) q:flat=""  d
 ..i $$eqflat(tflat,flat) d
 ...s matchrec="Pe,Se,"_nummatch_",Be,Fe"
 ...S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 ..I flat["former-",$p(flat,"-",2)=tflat d
 ...s matchrec="Pe,Se,"_nummatch_",Be,Fp"
 ...S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 ;Drop building match flat
 i tbuild'="" d
 .s flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,"",flat)) q:flat=""  d
 ..i $$eqflat(tflat,flat) d
 ...s matchrec="Pe,Se,"_nummatch_",Bd,Fe"
 ...s ^TBEST($J,matchrec,tbno,"",flat)=""
 .s build=""
 .for  s build=$O(^UPRNX("X5",tpost,tstreet,bno,build)) q:build=""  d
 ..I tflat'="",$D(^UPRNX("X5",tpost,tstreet,bno,build,tflat)) d  q
 ...i $$equiv^UPRNU(build,tbuild) d
 ....s matchrec="Pe,Se,"_nummatch_",Be,Fe"
 ....s ^TBEST($j,matchrec,bno,build,tflat)=""
 I tbuild="" d
 .s build=""
 .for  s build=$O(^UPRNX("X5",tpost,tstreet,bno,build)) q:build=""  d
 ..i tflat="" d
 ...I $D(^UPRNX("X5",tpost,tstreet,tbno,build,"")) d
 ....s matchrec="Pe,Se,"_nummatch_",Bi,Fe"
 ....S ^TBEST($J,matchrec,tbno,build,tflat)=""
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,bno,build,flat)) q:flat=""  d  q:(tflat="")
 ...s abpflat=flat
 ...I $$mflat1(tflat,.abpflat,.approx) d  q
 ....s matchrec="Pe,Se,"_nummatch_",Bi,F"_approx
 ....s ^TBEST($j,matchrec,bno,build,flat)=""
 ...i tflat="" d
 ....s matchrec="Pe,Se,"_nummatch_",Bi,Fa"
 ....s ^TBEST($j,matchrec,bno,build,flat)=""
 I tbuild="",tflat'="" d
 .S flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d
 ..i $$eqflat(tflat,flat) d
 ...s matchrec="Pe,Se,Ne,Be,Fe"
 ...S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 
 q
 
bestfit4(tpost,tstreet,tbno,tbuild,tflat)        ;
 q
fuzzy(tbno,tbuild,tflat,build,flat)         ;
 ;fuzzy match on buildings and flat
 N test,count
 s test=flat_" "_build
 i $p(flat," ")=$p(tflat," ") d
 .S count=$$mcount(tflat_" "_tbuild,flat_" "_build)
 .i count>2 d
 ..s matchrec="Pe,Se,Ne,Bp,Fp"
 ..S ^TBEST($J,matchrec,tbno,build,flat)=""
 ..S ^TORDER($J,matchrec,tbno,count,build,flat)=""
 q
whichno(matchrec,tpost,tstreet,tbno,tbuild,tflat)  ;
 ;Which is best number
 k ^TORDER($J)
 n bno,flat,count
 n matched
 s matched=0
 I $D(^TBEST($J,matchrec,"")) d
 .s mcount=$$mcount(tbno,"")
 .S ^TORDER($j,matchrec,"N",mcount,"")=""
 s bno=""
 for  s bno=$O(^TBEST($j,matchrec,bno)) q:bno=""  d
 .s mcount=$$mcount(tbno,bno)
 .S ^TORDER($J,matchrec,"N",mcount,bno)=""
 s count=""
 for  s count=$O(^TORDER($J,matchrec,"N",count),-1) q:count=""  d  q:matched
 .s bno=""
 .for  s bno=$O(^TORDER($J,matchrec,"N",count,bno)) q:bno=""  d  q:matched
 ..s matched=$$whichb(matchrec,tpost,tstreet,bno,tbuild,tflat)
 .I $D(^TORDER($J,matchrec,"N",count,"")) d
 ..s matched=$$whichb(matchrec,tpost,tstreet,"",tbuild,tflat)
 q matched
 
whichb(matchrec,tpost,tstreet,tbno,tbuild,tflat)        ;
 ;Closest match from a set of matched buildings
 n build,count,mcount,matched
 i $G(^TBEST($J,matchrec,tbno))'="" d
 .s tstreet=^TBEST($J,matchrec,tbno)
 s matched=0
 i $d(^TBEST($J,matchrec,tbno,"")) d
 .s mcount=$$mcount(tbuild,"")
 .S ^TORDER($J,matchrec,"B",mcount,"")=""
 s build="",best="",count=0,mcount=0
 for  s build=$O(^TBEST($J,matchrec,tbno,build)) q:build=""  d
 .s mcount=$$mcount(build,tbuild)
 .d ahead(matchrec,tbno,tbuild,tflat,build)
 .S ^TORDER($j,matchrec,"B",mcount,build)=""
 s count=""
 for  s count=$O(^TORDER($j,matchrec,"B",count),-1) q:count=""  d  q:matched
 .s build=""
 .for  s build=$O(^TORDER($J,matchrec,"B",count,build)) q:build=""  d  q:matched
 ..s matched=$$whichf(matchrec,tpost,tstreet,tbno,build,tflat)
 .I $D(^TORDER($J,matchrec,"B",count,"")) d
 ..s matched=$$whichf(matchrec,tpost,tstreet,tbno,"",tflat)
 q matched
ahead(matchrec,tbno,tbuild,tflat,build)          ;
 ;Look ahead for an advanced match on the flat
 n flat,count
 s flat=""
 for  s flat=$O(^TBEST($j,matchrec,tbno,build,flat)) q:flat=""  d
 .s count=$$mcount(flat_" "_build,tflat_" "_tbuild)
 .S ^TBEST($J,matchrec,tbno,build,flat)=count
 q
 
whichf(matchrec,tpost,tstreet,tbno,tbuild,tflat) 
 ;best flat? 
 n flat,matched,count
 s matched=0
 i $D(^TBEST($j,matchrec,tbno,tbuild,"")) d
 .S mcount=$$mcount(tflat,"")
 .S ^TORDER($J,matchrec,"F",mcount,"")=""
 s flat=""
 for  s flat=$O(^TBEST($j,matchrec,tbno,tbuild,flat)) q:flat=""  d  q:matched
 .s mcount=$$mcount(tflat,flat)+$g(^TBEST($j,matchrec,tbno,tbuild,flat))
 .S ^TORDER($J,matchrec,"F",mcount,flat)=""
 s count=""
 for  s count=$O(^TORDER($j,matchrec,"F",count),-1) q:count=""  d  q:matched
 .for  s flat=$O(^TORDER($J,matchrec,"F",count,flat)) q:flat=""  d
 ..s matched=$$set(matchrec,tpost,tstreet,tbno,tbuild,flat)
 .i $D(^TORDER($J,matchrec,"F",count,"")) d
 ..s matched=$$set(matchrec,tpost,tstreet,tbno,tbuild,"")
 q matched
bestch ;Fits with a care home
 n build,matched
 s build="",matched=0
 for  s build=$O(^UPRNX("X5",tpost,tstreet,tbno,build)) q:build=""  d
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,build,tflat)) d
 ..s uprn=""
 ..for  s uprn=$O(^UPRNX("X5",tpost,tstreet,tbno,build,tflat,uprn)) q:uprn=""  d  Q:matched
 ...I $G(^UPRN("CLASS",uprn))="RI01" d
 ....s matchrec="Pe,Se,Ne,Bi,Fe"
 ....s matched=$$setuprns(matchrec,"X5",tpost,tstreet,tbno,build,tflat) d
 q
        
 
bestfitn          ;Fits with no building
 ;but may be an exact match on building and close post code
 ;but also there may be no number and 
 I tbuild'="",tflat="",tbno'="" d
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,"","")) d
 ..s matchrec="Pe,Se,Ne,Bd,Fe"
 ..S ^TBEST($J,matchrec,tbno,"","")=""
 .S post=""
 .for  s post=$O(^UPRNX("X3",tbuild,tflat,post)) q:post=""  d
 ..q:post=tpost
 ..s np=$$nearpost^UPRN(post,tpost,1)
 ..i np="Pl" d
 ...I $D(^UPRNX("X3",post,tstreet,tbno,tbuild,tflat)) d
 ....s matchrec=nearp_",Se,Ne,Be,Fe"
 ....s ^TBEST($j,matchrec,tbno,tbuild,tflat)=""
 ....s ^TBEST($j,matchrec)=post
 q
 
210120 ;
bestfitc ;Sibling flat with candidate flat suffix
210120 i tflat?1n.n1l d
210120 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,tflat*1)) d
210120 ..s matchrec="Pe,Se,Ne,Be,Fs"
210120 ..S ^TBEST($J,matchrec,tbno,tbuild,tflat*1)=""
210120 q
 
210120 ;
bestfitd ;
210120 I tflat'="",tstreet'="",tbuild="",tbno="" d
210220 .s bno=""
210120 .for  s bno=$O(^UPRNX("X5",tpost,tstreet,bno)) q:bno=""  d
210120 ..i $D(^UPRNX("X5",tpost,tstreet,bno,tbuild,tflat)) d
210120 ...s matchrec="Pe,Se,Ni,Be,Fe"
210120 ...S ^TBEST($j,matchrec,bno,tbuild,tflat)=""
210120 q
 
bestfitb        ;
 ;Could match on building or flat
 ;or some combination
 ;candidate must have a flat and a number
 i tflat="" q
 i tbno="" q
 ;Must also match on post,street and number
 I '$D(^UPRNX("X5",tpost,tstreet,tbno)) q
 s rflat=$$reform(tflat)
 i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,rflat)) d
 .s matchrec="Pe,Se,Ne,Be,Fp"
 .S ^TBEST($J,matchrec,tbno,tbuild,rflat)=""
 .S matched=1
 i matched q
 i rflat?1n.n1" "1l.e d
 .i $D(^UPRNS("VERTICALS",$p(rflat," ",2,10))) d
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,rflat*1)) d
 ...s matchrec="Pe,Se,Ne,Be,Fp"
 ...S ^TBEST($j,matchrec,tbno,tbuild,rflat*1)=""
 
 ;Special GO/G0 problem
 s tflat=$$tr^UPRNL(tflat,"go","g0")
 I tbuild'="" d
 .i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,$tr(tflat,"o","0"))) d  q
 ..s matchrec="Pe,Se,Ne,Bd,Fl"
 ..s ^TBEST($j,matchrec,tbno,tbuild,$tr(tflat,"o","0"))=""
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,"",tflat))  d
 ..s matchrec="Pe,Se,Ne,Bd,Fe"
 ..s ^TBEST($J,matchrec,tbno,"",tflat)=""
 ..s matched=1
 .s part=tbuild
 .for  s part=$O(^UPRNX("X5",tpost,tstreet,tbno,part)) q:part=""  q:($e(part,1,$l(tbuild))'=tbuild)  d  q:matched
 ..i $D(^UPRNX("X5",tpost,tstreet,tbno,part,tflat)) d  q
 ...S matchrec="Pe,Se,Ne,Bp,Fe"
 ...S ^TBEST($j,matchrec,tbno,part,tflat)=""
 ...S matched=1
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,part,flat)) q:flat=""  d  q:matched
 ...i $$eqflat(tflat,flat) d
 ....S matchrec="Pe,Se,Ne,Bp,Fp"
 ....s ^TBEST($J,matchrec,tbno,part,flat)=""
 ....s matched=1
 i matched q
 
 ;Try with ignoring ABP building
 i tbuild="" d
 .s build=""
 .for  s build=$O(^UPRNX("X5",tpost,tstreet,tbno,build)) q:build=""  d  q:matched
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,build,tflat)) d  q
 ...s matchrec="Pe,Se,Ne,Bi,Fe"
 ...s ^TBEST($j,matchrec,tbno,build,tflat)=""
 ...s matched=1
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,build,flat)) q:flat=""  d  q:matched
 ...i $$vertok^UPRNU(tflat,flat) d
 ....s matchrec="Pe,Se,Ne,Bi,Fp"
 ....S ^TBEST($J,matchrec,tbno,build,flat)=""
 ....s matched=1
 i matched q
 s tstflat=""
 i tflat["g0" d
 .s tstflat=$$tr^UPRNL(tflat,"g0","")
 .i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,tstflat)) d
 ..s matchrec="Pe,Se,Ne,Be,Fe"
 ..S ^TBEST($J,matchrec,tbno,tbuild,tstflat)=""
 s build=tbuild
 i tflat?1n.n.l1" "1.n.l d
 .s tstflat=$tr(tflat," ","-")
 i tflat?1n.n.l,tbuild?1l1n1" ".e d
 .s tstflat=tflat_$p(tbuild," ")
 .s build=$p(tbuild," ",2,10)
 i tstflat="" d  q
 .I tbuild'="" d
 .i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"")) d
 ..s matchrec="Pe,Se,Ne,Be,Fc"
 ..S ^TBEST($J,matchrec,tbno,tbuild,tstflat)=""
 i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,tstflat)) d
 .s matchrec="Pe,Se,Ne,Bd,Fl"
 .S ^TBEST($J,matchrec,tbno,tbuild,tstflat)=""
 q
reform(flat)       ;Reforms flat
 i $p(flat," ",$l(flat," "))?1l d
 q ($p(flat," ",$l(flat," "))_" "_$p(flat," ",1,$l(flat," ")-1))
 
vert1(tpost,tstreet,tbno,tbuild,tflat) ;
 ;Looks for the vertical after a flat letter
 n (ALG,tpost,tstreet,tbno,tbuild,tflat)
 for pair="a first floor","b second floor","c third floor" d  q:matched
 .I tflat'=pair q
 .s vertical=$p(pair," ",2,10)
 .s altvert=vertical_" "_$p(pair," ")
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,vertical)) d
 ..s flat=vertical
 ..d setv2
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,altvert)) d
 ..s flat=altvert
 ..d setv2
 .i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,$p(tflat," ",1))) d
 ..s flat=$P(tflat," ",1)
 ..d setv2
 I $D(^TUPRN($J,"MATCHED")) Q
 d vert2(tpost,tstreet,tbno,tbuild,tflat)
 I $D(^TUPRN($J,"MATCHED")) Q
 q
vert2(tpost,tstreet,tbno,tbuild,tflat) ;
 ;Looks for a vertical before the flat letter
 for pair="first floor a","second floor b","third floor c" d  Q:matched
 .I tflat'=pair q
 .s vertical=$p(pair," ",1,2)
 .s flat=$p(pair," ",3)
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) d
 ..d setv2
 q
bestv2        ;
 ;Contains verticals but not exactly a vertical
 ;Vertical fit not exact
 i tflat?1l.n1" ".e d
 .s fsuff=$p(tflat," ")
 .s vertical=$p(tflat," ",2,20)
 .I $D(^UPRNS("VERTICALS",vertical)) d
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,vertical_" "_fsuff)) d  Q
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,vertical_" "_fsuff,""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fev"
 ...e  d
 ....S matchrec="Pe,Se,Ne,Be,Fe"
 ...S ^TBEST($J,matchrec,tbno,tbuild,vertical_" "_fsuff)=""
 ...s matched=1
 ..i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,vertical)) d  Q
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,vertical,""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fpv"
 ...e  d
 ....S matchrec="Pe,Se,Ne,Be,Fp"
 ...S ^TBEST($J,matchrec,tbno,tbuild,vertical)=""
 ..I $D(^UPRNX("X5",tpost,tstreet,"",tbno_fsuff,"")) d  Q
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,"",tbno_fsuff,"",""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fpv"
 ...e  d
 ....s matchrec="Pe,Se,Ne,Be,Fp"
 ...s ^TBEST($j,matchrec,"",tbno_fsuff,"")=""
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fsuff)) d  q
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fsuff,""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fpv"
 ...e  d
 ....S matchrec="Pe,Se,Ne,Be,Fp"
 ...S ^TBEST($j,matchrec,tbno,tbuild,fsuff)=""
 i tflat?1n.n.l1" ".e d
 .s fsuff=$p(tflat," ")
 .s vertical=$p(tflat," ",2,20)
 .I $D(^UPRNS("VERTICALS",vertical)) d
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fsuff)) d
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fsuff,""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fpv"
 ...e  d
 ....S matchrec="Pe,Se,Ne,Be,Fp"
 ...S ^TBEST($j,matchrec,tbno,tbuild,fsuff)=""
 I $G(^TUPRN($J,"MATCHED")) Q
 i tflat?1n.n.l1" "1l.e d
 .s fnum=$p(tflat," ")
 .s vertical=$p(tflat," ",2,20)
 .I $D(^UPRNS("VERTICALS",vertical)) d
 ..s qual=^(vertical)
 ..I fnum<10 d
 ...f suffix=$c(96+fnum),$c(96+fnum-1) d  q:matched
 ....I $D(^UPRNX("X5",tpost,tstreet,tbno_suffix,tbuild)) d
 .....s flat=""
 .....for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno_suffix,tbuild,flat)) q:flat=""  d  q:matched
 ......I $D(^UPRNS("VERTICALS",flat)) d
 .......i flat=vertical d
 ........s matchrec="Pe,Se,Nf,Be,Fp>N"
 ........S ^TBEST($J,matchrec,tbno_suffix,tbuild,flat)=""
 ........S matched=1
 ..I matched q
 ..n subvert
 ..s subvert=""
 ..for  s subvert=$O(^UPRNS("VERTICALS",vertical,subvert)) q:subvert=""  d  q:matched
 ...I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,subvert)) d
 ....S matchrec="Pe,Se,Ne,Be,Fp1"
 ....S ^TBEST($j,matchrec,tbno,tbuild,subvert)=""
 ..s flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d
 ...i $d(^UPRNS("VERTICALS",flat)) d
 ....s matchrec="Pe,Se,Ne,Be,Fp2"
 ....S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 i tflat?1l.l1" "1l.e d
 .s fpart=$p(tflat," ")
 .s vertical=$p(tflat," ",2,20)
 .I $D(^UPRNS("VERTICALS",vertical)) d
 ..s flat=""
 ..for  s flat=$o(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d
 ...s fflat=$$flat^UPRNU($$correct^UPRNU(flat))
 ...i $$eqflat(fpart,fflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fe"
 ....s ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ;Vertical + number?
 S suff=$p(tflat," ",$l(tflat," "))
 i suff?1n.n!(suff?1l) d
 .I $D(^UPRNS("VERTICALS",$p(tflat," ",1,$l(tflat," ")-1))) d
 ..i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,suff)) d
 ...s matchrec="Pe,Se,Ne,Be,Fe"
 ...S ^TBEST($J,matchrec,tbno,tbuild,suff)=""
 q
bestfitv ;Tests vertical flat fitting with candidate number 
 ;Must have a number and a flat
 ;assumes a building match
 i tbno="" q
 i tflat="" q
 ;might have short and long flat names
 S flatex=$$sflat(tflat)
 i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flatex)) d  q
 .s flat=flatex
 .s matchrec="Pe,Se,Ne,Fe"
 .s matched=$$set(matchrec,tpost,tstreet,tbno,tbuild,flatex)
 
levels ;Candidate is vertical
 ;Test ABP vertical
 I $D(^UPRNS("VERTICALS",tflat)) d
 .i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild)) d
 ..I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"")) d
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"",""))
 ...I $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fev"
 ....s ^TBEST($J,matchrec,tbno,tbuild,"")=""
 ....s matched=1
 ..S flat=""
 ..for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d  q:matched
 ...s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat,""))
 ...i $$islevel^UPRNU(auprn,tflat) d
 ....s matchrec="Pe,Se,Ne,Be,Fev"
 ....S ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ....s matched=1
 .i matched q
 .f char=97:1:102 d
 ..i $D(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild)) d  q:matched
 ...I $D(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,"")) d
 ....s auprn=$O(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,"",""))
 ....I $$islevel^UPRNU(auprn,tflat) d
 .....s matchrec="Pe,Se,Ne,Be,Fev"
 .....s ^TBEST($J,matchrec,tbno_$c(char),tbuild,"")=""
 .....s matched=1
 i matched q
 
suf1 ;matches to flat suffix when no alternative flats
 i tflat?1l d
 .I $D(^UPRNX("X5",tpost,tstreet,tbno_tflat,tbuild,"")) d
 ..I $O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,""))=""  d
 ...s matchrec="Pe,Se,Nf,Be,F>N"
 ...S ^TBEST($J,matchrec,tbno_tflat,tbuild,"")=""
 ...s matched=1
 I matched q
 
sufnum1 i tflat?1n d
 .s tstflat=$G(^UPRNS("FLATNUMSUF",tflat))
 .i tstflat="" q
 .i $D(^UPRNX("X5",tpost,tstreet,tbno_tstflat,tbuild,tflat)) d  Q
 ..s matchrec="Pe,Se,Np,Be,F>N"
 ..S ^TBEST($J,matchrec,tbno_tstflat,tbuild,tflat)=""
 ..s matched=1
 .I $D(^UPRNX("X5",tpost,tstreet,tbno_tstflat,tbuild,"")) d
 ..s matchrec="Pe,Se,Nf,Be,F>N"
 ..S ^TBEST($J,matchrec,tbno_tstflat,tbuild,"")=""
 ..s matched=1
 i matched q
 ;Flat is not vertical try another vertical
 i '$D(^UPRNS("VERTICALS",tflat)) D bestv2 q
 
 s qual=^UPRNS("VERTICALS",tflat)
 i $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild)) d
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"")) d
 ..s matchrec="Pe,Se,Ne,Be,Fc"
 ..S ^TBEST($j,matchrec,tbno,tbuild,"")=""
 .S flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d  q:matched
 ..s fflat=$$correct^UPRNU(flat)
 ..s fflat=$$exvert(fflat)
 ..I $$eqflat(tflat,fflat) d  q
 ...s matchrec="Pe,Se,Ne,Be,Fp"
 ...s ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ...s matched=1
 ..i $$eqflat(tflat,flat) d  q
 ...s matchrec="Pe,Se,Ne,Be,Fp"
 ...s ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ...s matched=1
 ..i $D(^UPRNS("VERTICALS",fflat)) d
 ...i ^(fflat)=qual d
 ....I $D(^UPRNS("VERTICALSX",fflat,tflat)) d
 .....s matchrec="Pe,Se,Ne,Be,Fvv"
 .....s ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 .....s matched=1
 ....e  d
 .....s matchrec="Pe,Se,Ne,Be,Fv"
 .....s ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 .....s matched=1
 ..i $D(^UPRNS("FLOOR",tflat)) d
 ...s fnum=""
 ...for  s fnum=$O(^UPRNS("FLOOR",tflat,fnum)) q:fnum=""  d  q:matched
 ....I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fnum)) d
 .....s matchrec="Pe,Se,Ne,Be,Fo"
 .....s ^TBEST($J,matchrec,tbno,tbuild,fnum)=""
 ....I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,fnum-1)) d
 .....s matchrec="Pe,Se,Ne,Be,Fs"
 .....s ^TBEST($J,matchrec,tbno,tbuild,fnum-1)=""
 ....i $a(fnum)>96 d
 .....I $D(^UPRNX("X5",tpost,tstreet,tbno_fnum,tbuild,"")) d
 .....s matchrec="Pe,Se,Nf,Be,Fp>N"
 .....S ^TBEST($J,matchrec,tbno_fnum,tbuild,"")=""
 I $G(^TUPRN($J,"MATCHED")) Q
 
 ;Using the vertical qualifier
 ;Tests for suffix in street number
 ;from low to high
 s matched=0
vchar i qual="low" f char=97:1:102 d  q:matched
 .I $D(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,"")) d
 ..s matchrec="Pe,Se,Nf,Be,Fp>N"
 ..s ^TBEST($j,matchrec,tbno_$c(char),tbuild,"")=""
 ..S matched=1
 .s flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,flat)) q:flat=""  d  q:matched
 ..i $p(flat," ")=$p(tflat," ") d
 ...s matchrec="Pe,Se,Nf,Be,Fp>N"
 ...s ^TBEST($j,matchrec,tbno_$c(char),tbuild,flat)=""
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,$c(char))) d
 ..s matchrec="Pe,Se,Ne,Be,Fp"
 ..S ^TBEST($J,matchrec,tbno,tbuild,$c(char))=""
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,char-96)) d
 ..s matchrec="Pe,Se,Ne,Be,Fp"
 ..S ^TBEST($J,matchrec,tbno,tbuild,char-96)=""
 
 ;Other way round from high to low
vchar1 i qual'="low" f char=102:-1:97 d  q:matched
 .I $D(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,"")) d
 ..s matchrec="Pe,Se,Nf,Be,Fp>N"
 ..s ^TBEST($j,matchrec,tbno_$c(char),tbuild,"")=""
 .s flat=""
 .for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno_$c(char),tbuild,flat)) q:flat=""  d  q:matched
 ..i $p(flat," ")=$p(tflat," ") d
 ...s matchrec="Pe,Se,Nf,Be,Fp>N"
 ...s ^TBEST($j,matchrec,tbno_$c(char),tbuild,flat)=""
 ...s matched=1
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,$c(char))) d
 ..s matchrec="Pe,Se,Ne,Be,Fp"
 ..s ^TBEST($J,matchrec,tbno,tbuild,$c(char))=""
 ..s matched=1
 .I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,char-96)) d
 ..s matchrec="Pe,Se,Ne,Be,Fp"
 ..s ^TBEST($J,matchrec,tbno,tbuild,char-96)=""
 ..s matched=1
 i matched q
 d getflats("Pe,Se,Ne,Be,Fp",qual,tpost,tstreet,tbno,tbuild,tflat)
 q
getflats(matchrec,qual,tpost,tstreet,tbno,tbuild,tflat) 
 ;Collects a list of candidate flats
 ;for a building
 n flat
 s flat=""
 for  s flat=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d
 .I $D(^UPRNS("VERTICALS",flat)) d
 ..s abpqual=^UPRNS("VERTICALS",flat)
 ..I qual="high" f type="top","upper" d
 ...i $e(flat,1,$l(type))=type d
 ....S ^TBEST($J,matchrec,tbno,tbuild,flat)=""
 ..I qual="low" f type="basemen","groun","firs","secon" d  Q:ffound
 ...s ffound=0
 ...i $e(flat,1,$l(type))=type d
 ....s ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ....s ffound=1
 ..f type="firs","secon","third" d  Q:ffound
 ...s ffound=0
 ...i $e(flat,1,$l(type))=type d
 ....s ^TBEST($j,matchrec,tbno,tbuild,flat)=""
 ....s ffound=1
 q
set(matchrec,post,street,bno,build,flat)         ;Attempts a residential set
 q $$setuprns(matchrec,"X5",post,street,bno,build,flat)
 
setuprns(matchrec,index,n1,n2,n3,n4,n5) 
 n uprn,table,key
 S matched=0
 s (uprn,table,key)=""
 for  s uprn=$O(^UPRNX(index,n1,n2,n3,n4,n5,uprn)) q:uprn=""  d
 .S $P(ALG,"-",2)="bestfit"
 .for  s table=$O(^UPRNX(index,n1,n2,n3,n4,n5,uprn,table)) q:table=""  d
 ..for  s key=$O(^UPRNX(index,n1,n2,n3,n4,n5,uprn,table,key)) q:key=""  d
 ...S matched=$$set^UPRN(uprn,table,key)
 q matched
 
mflat1(tflat,flat,approx) ;Matches two flats
 n matched,tflatno,i,wcount
 s matched=0
 i tflat=flat s approx="e" q 1
 s wcount=$l(tflat," ")
 s count=0
 f i=1:1:wcount d
 .s word=$p(tflat," ",i)
 .i (" "_flat_" ")[(" "_word_" ") s count=count+1
 i count=wcount s approx="e" q 1
 
 ;5-6
 i flat["-" d
 .i tflat=$p(flat,"-")!(tflat=$p(flat,"-",2)) d
 ..s matched=1
 ..s approx="e"
 .I tflat?1n.n.e d
 ..I tflat*1=$p(flat,"-",2)!(tflat*1=$p(flat,"-",1)) d  Q
 ...s matched=1
 ...s approx="p"
 i matched q 1
 
 i tflat["-" d
 .i flat=$p(tflat,"-")!(flat=$p(tflat,"-",2)) d
 ..s matched=1
 ..s approx="p"
 
 i matched q 1
 
 ;workshop 6
 i $p(tflat," ",$l(tflat," "))?1n.n.l d
 .set tflatno=$p(tflat," ",$l(tflat," "))
 .if tflatno=flat d
 ..s approx="p"
 ..s matched=1
 i matched q 1
 
 ;flat 6 f
 s tflat=$tr(tflat," "),flat=$tr(flat," ")
 
 ;3c to 4
 i tflat?1n.n.1l,flat?1n.n,(flat*1=(tflat*1)) d
 .s matched=1
 .s approx="s"
 i tflat?1n.n,(flat*1)=tflat*1 d
 .s matched=1
 .s approx="s"
 
        
 
 q matched
