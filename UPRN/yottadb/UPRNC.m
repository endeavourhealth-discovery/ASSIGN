UPRNC ;Additional aglorithms [ 08/01/2023  5:44 PM ]
	;wELSH "f" "v"
	;
match79(tstreet,tbno,tbuild,tflat,tdeploc,tloc,ttown) 	;
	;All post codes
	n matched,uprn,table,key,matchrec,town
	i (tstreet="")!(tbno="") q 0
	s matched=0
	s matchrec="Pi,Se,Ne,Be,Fe"
	s $p(ALG,"-",2)="match79"
	for town="ttown","tloc","tdeploc" d  q:matched
	. i @town'="" d
	. . s uprn=""
	. . for  s uprn=$O(^UPRNX("X6",tstreet,tbno,@town,tbuild,tflat,uprn)) q:uprn=""  d  q:matched
	. . . s table=""
	. . . for  s table=$O(^UPRNX("X6",tstreet,tbno,@town,tbuild,tflat,uprn,table)) q:table=""  d  q:matched 
	. . . . s key=""
	. . . . for  s key=$O(^UPRNX("X6",tstreet,tbno,@town,tbuild,tflat,uprn,table,key)) q:key=""  d  q:matched
	. . . . . s matched=$$set^UPRN(uprn,table,key)
	Q matched
match78(tstreet,tbno,tbuild,tflat) 	;
	;All post codes
	n matched,uprn,table,key,matchrec
	i tbuild=""!(tstreet="") q 0
	s matched=0
	s matchrec="Pi,Se,Ni,Be,Fe"
	s $p(ALG,"-",2)="match78"
	s post=""
	for  s post=$O(^UPRNX("X2",tbuild,tstreet,tflat,post)) q:post=""  d  q:matched
	. s bno=""
	. for  s bno=$O(^UPRNX("X2",tbuild,tstreet,tflat,post,bno)) q:bno=""  d  q:matched
	. . s uprn=""
	. . for  s uprn=$O(^UPRNX("X2",tbuild,tstreet,tflat,post,bno,uprn)) q:uprn=""  d  q:matched
	. . . s table=""
	. . . for  s table=$O(^UPRNX("X2",tbuild,tstreet,tflat,post,bno,uprn,table)) q:table=""  d  q:matched 
	. . . . s key=""
	. . . . for  s key=$O(^UPRNX("X2",tbuild,tstreet,tflat,post,bno,uprn,table,key)) q:key=""  d  q:matched
	. . . . . s matched=$$set^UPRN(uprn,table,key)
	Q matched
	;
match77(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc,tdepth) ;
	n matched,nxstreet
	s matched=0
	i tstreet'="",$d(^UPRNS("HOUSE",tbuild)) d
	. s nxstreet=$O(^UPRNX("X3",ZONE,tstreet_" "))
	. i $e(nxstreet,1,$l(tstreet))=tstreet d
	. . i $D(^UPRNS("HOUSE",$p(nxstreet," ",$l(nxstreet," ")))) d
	. . . s matched=$$match75a(tpost,"",tbno,nxstreet,tflat,tdeploc,tloc)
	q matched
match76(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc) ;
		n matched
	i tbuild["f" d
	. s tbuild=$$tr^UPRNL(tbuild,"f","v")
	. s matched=$$match75(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc)
	q $G(^TUPRN($J,"MATCHED"))	
	;flat is number, building is street, candidate street skipped but dependent location and location match
match75(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc) ;
	I tbuild="" q ""
	i '$d(^UPRNX("X3",ZONE,tbuild)),$D(^UPRNS("HOUSE",$p(tbuild," ",$l(tbuild," ")))) d
	. s tbuild=$p(tbuild," ",0,$l(tbuild," ")-1)
	I tbuild="" q ""
	q $$match75a(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc)
	;
match75a(tpost,tstreet,tbno,tbuild,tflat,tdeploc,tloc,bmatch) ;
	n matched,table,key,rec,flat,bno,street,loc,matchrec,post,town,deploc,depth,build,uprn
	S matched=0
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tbuild,tflat,post)) q:post=""  d  q:matched
	. s matchrec=$$nearpost^UPRN(post,tpost)
	. if matchrec'="" d
	. . s uprn=""
	. . for  s uprn=$O(^UPRNX("X3",ZONE,tbuild,tflat,post,uprn)) q:uprn=""  d  q:matched
	. . . s table=""
	. . . for  s table=$O(^UPRNX("X3",ZONE,tbuild,tflat,post,uprn,table)) q:table=""  d  q:matched
	. . . . s key=""
	. . . . for  s key=$O(^UPRNX("X3",ZONE,tbuild,tflat,post,uprn,table,key)) q:key=""  do  q:matched
	. . . . . s rec=^UPRN("U",uprn,table,key)
	. . . . . s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	. . . . . s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	. . . . . s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
	. . . . . S loc=$p(rec,"~",7),town=$p(rec,"~",8)
	. . . . . i tflat=flat,tbuild=build,tbno=bno,tloc=loc,(tdeploc=deploc!(tdeploc=town)) d
	. . . . . . s matchrec="Pe,S>B,Ne,B<S,Fe"
	. . . . . . s $p(ALG,"-",2)="match75c"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . I tbno="",flat="",build="",tbuild=street,tflat=bno d  q
	. . . . . . s bmatch=$G(bmatch,"B>S")
	. . . . . . s matchrec="Pe,S<B,N<F,B>S,F>N"
	. . . . . . S $p(ALG,"-",2)="match75a"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . i loc'="",tloc'="",town'="",tdeploc'="",loc=tdeploc,town=tloc d
	. . . . . . s bmatch=$G(bmatch,"B>S")
	. . . . . . s $p(matchrec,"~",2,5)="S<b,N<F,B>S,F>N"
	. . . . . . s $p(ALG,"-",2)="match75"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	q $g(^TUPRN($J,"MATCHED"))
	;Wrong post code but exact match on street, number and therefore child flat
match74(tpost,tstreet,tbno,tbuild,tflat,tdepth) ;
	n matched,xbuild,post,matchrec,build,flat
	s matched=0
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tstreet,tbno,post)) q:post=""  d  q:matched
	. i post=tpost q
	. s $p(matchrec,",")=$$nearpost^UPRN(post,tpost)
	. i $p(matchrec,",")="" q
	. i tbuild'="",tdepth'="" d
	. . s xbuild=$p(tbuild," "),build=xbuild
	. . for  s build=$O(^UPRNX("X5",post,tstreet,tbno,build)) q:($p(build," ")'=xbuild)  d  q:matched
	. . . i $d(^UPRNX("X5",post,tstreet,tbno,build,tflat_" "_tdepth)) d
	. . . . s $p(matchrec,",",2,5)="Se,Ne,Bp,f<FB"
	. . . . S $p(ALG,"-",2)="match74a"
	. . . . s matched=$$setuprns^UPRN("X5",post,tstreet,tbno,build,tflat_" "_tdepth)
	q $g(^TUPRN($J,"MATCHED"))
	;
	;
match71(tpost,tstreet,tbno,tbuild,tflat)         ;
	i tflat'="",tbno="",tstreet'="",tbuild'="" d
	. s bno=""
	. for  s bno=$O(^UPRNX("X4",tpost,tstreet,bno)) q:bno=""  d  q:matched
	. . i $D(^UPRNX("X4",tpost,tstreet,bno,tflat_" "_tbuild)) d
	. . . s depth=$O(^UPRNX("X4",tpost,tstreet,bno,tflat_" "_tbuild,""))
	. . . s $p(ALG,"-",2)="match71"
	. . . s matchrec="Pe,Se,Ne,B>F,Fe"
	. . . s matched=$$setuprns^UPRN("X4",tpost,tstreet,bno,tflat_" "_tbuild,depth)
	Q $G(^TUPRN($J,"MATCHED"))
match72(tpost,tstreet,tbno,tbuild,tflat)         ;
	i tflat'="",tbno="",tstreet'="",tbuild="" d
	. s bno=""
	. for  s bno=$O(^UPRNX("X4",tpost,tstreet,bno)) q:bno=""  d  q:matched
	. . i $D(^UPRNX("X4",tpost,tstreet,bno,tflat)) d
	. . . s build=$O(^UPRNX("X4",tpost,tstreet,bno,tflat,""))
	. . . s $p(ALG,"-",2)="match72"
	. . . s matchrec="Pe,Se,Ni,Bi,Fe"
	. . . s matched=$$setuprns^UPRN("X4",tpost,tstreet,bno,tflat,build)
	Q $G(^TUPRN($J,"MATCHED"))
match70(tpost,tstreet,tbno,tbuild,tflat)         ;
	I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"")),tflat'="" d
	. s $p(ALG,"-",2)="match70"
	. s matchrec="Pe,Se,Ne,Be,Fc"
	. s matched=$$setuprns^UPRN("X5",tpost,tstreet,tbno,tbuild,"")
	Q $G(^TUPRN($J,"MATCHED"))
	;	
match69(tpost,tstreet,tbno,tbuild,tflat)         ;
	;Flat room not in ABP
	n xflat
	i tflat'?1n.n1l q ""
	i tbuild=""!(tstreet="")!(tbno'="") q ""
	s flat=tflat
	I $D(^UPRNX("X3",ZONE,tbuild,$e(tflat,$l(tflat))_" "_(tflat*1))) d
	. s flat=$e(tflat,$l(tflat))_" "_(tflat*1)
	e  s flat=tflat*1
	I '$D(^UPRNX("X3",ZONE,tbuild,flat)) q ""
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tbuild,flat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
	. q:post=tpost
	. s matchrec=$$nearpost^UPRN(post,tpost,1)
	. i matchrec="" q
	. S bno=""
	. for  s bno=$O(^UPRNX("X5",post,tstreet,bno)) q:bno=""  d  q:matched
	. . i '$D(^UPRNX("X5",post,tstreet,bno,tbuild,flat)) q
	. . i flat=tflat s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
	. . e  s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
	. . s $p(ALG,"-",2)="match69"
	. . s matched=$$setuprns^UPRN("X5",post,tstreet,bno,tbuild,flat)
	Q $G(^TUPRN($J,"MATCHED"))
	;	
	;	
match68(tpost,tbuild,tflat,tbno,tstreet) ;
	;Exact flat and building, sector error and street road type mismatch
	i $l(tbuild," ")<3 q ""
	i $l(tstreet," ")<2 q ""
	s troad=$p(tstreet," ",$l(tstreet," "))
	I '$D(^UPRNS("ROAD",troad)) q ""
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tbuild,tflat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
	. q:post=tpost
	. s matchrec=$$nearpost^UPRN(post,tpost,1,1)
	. I matchrec'="" d  q:$D(^TUPRN($J,"MATCHED"))
	. . s street=""
	. . for  s street=$O(^UPRNX("X5",post,street)) q:street=""  d  q:$D(^TUPRN($J,"MATCHED"))
	. . . i $d(^UPRNX("X5",post,street,tbno,tbuild,tflat)) d
	. . . . i $l(street," ")<2 q
	. . . . s roadtype=$p(street," ",$l(street," "))
	. . . . I $D(^UPRNS("ROAD",roadtype)) d
	. . . . . i $p(tstreet," ",1,$l(tstreet," ")-1)_" "_roadtype=street d
	. . . . . . s matchrec="Pl,Sl,Ne,Be,Fe"
	. . . . . . S $p(ALG,"-",2)="match68"
	. . . . . . s matched=$$setuprns^UPRN("X5",post,street,"",tbuild,tflat)
	Q $G(^TUPRN($J,"MATCHED"))
match67(tpost,tbuild,tflat,tbno,tstreet) ;
	n wno,next,st,word,build
	s matchrec="Pe"
	I tbuild'="" d  Q $G(^TUPRN($J,"MATCHED"))
	. f wno=1:1:$l(tbuild," ") d
	. . s word=$p(tbuild," ",wno) q:word=""
	. . s st=$e(word,1,2),next=st
	. . for  s next=$O(^UPRNX("X.W",next)) q:($e(next,1,2)'=st)  d  q:matched
	. . . i next=word q
	. . . i next'?1l.l."'".".".l q
	. . . i '$$levensh^UPRNU(word,next,5,2) q
	. . . S build=$$tr^UPRNL(tbuild,word,next)
	. . . i '$D(^UPRNX("X3",ZONE,build,tflat)) q
	. . . s $p(matchrec,",",4,5)="Bl,Fe"
	. . . s matched=$$match67a(tpost,build,tflat,tbno,tstreet)
	i tstreet'="" d
	. s $p(matchrec,",",4,5)="Be,Fe"
	. s matched=$$match67a(tpost,tbuild,tflat,tbno,tstreet)
	Q $G(^TUPRN($J,"MATCHED"))
match67a(tpost,tbuild,tflat,tbno,tstreet) ;
	n wno,next,st,word,build,matched
	s matched=0
	i tstreet'="" d  Q $G(^TUPRN($J,"MATCHED"))
	. f wno=1:1:$l(tstreet," ") d
	. . s word=$p(tstreet," ",wno)
	. . s st=$e(word,1,2),next=st
	. . for  s next=$O(^UPRNX("X.W",next)) q:($e(next,1,2)'=st)  d  q:matched
	. . . i next'?1l.l."'".".".l q
	. . . i '$$levensh^UPRNU(word,next,5,2) q
	. . . S street=$$tr^UPRNL(tstreet,word,next)
	. . . i '$D(^UPRNX("X3",ZONE,street,tbno)) q
	. . . s $p(matchrec,",",2,3)="Sl,Ne"
	. . . s post=""
	. . . for  s post=$O(^UPRNX("X3",ZONE,street,tbno,post)) q:post=""  d  q:matched
	. . . . i '$D(^UPRNX("X5",post,street,tbno,tbuild,tflat)) q
	. . . . i $$nearpost^UPRN(post,tpost)'="" d
	. . . . . s $p(ALG,"-",2)="match67"
	. . . . . s $p(matchrec,",",1)="Pl"
	. . . . . s matched=$$setuprns^UPRN("X5",post,street,tbno,tbuild,tflat)
	q matched
match66(tpost,tbuild,tflat,tbno,tstreet) ;
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tstreet,tbno,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
	. q:post=tpost
	. s matchrec=$$nearpost^UPRN(post,tpost,2,1)
	. I matchrec'="" d
	. . I $D(^UPRNX("X5",post,tstreet,tbno,tbuild,tflat)) d
	. . . S ALG=ALG_"match66"
	. . . s matchrec="Pl,Se,Ne,Be,Fe"
	. . . s matched=$$setuprns^UPRN("X5",post,tstreet,tbno,tbuild,tflat)
	Q $G(^TUPRN($J,"MATCHED"))
	; 
match65(tpost,tbuild,tflat,tbno,tstreet) ;
	i tbno'="",tstreet'="",$D(^UPRNS("NUMWORD",tbno)) d
	. s tstreet=^UPRNS("NUMWORD",tbno)_" "_adstreet
	. s tdbno=""
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tbuild,tflat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
	. q:post=tpost
	. s matchrec=$$nearpost^UPRN(post,tpost,2,1)
	. I matchrec'="" d  q:$D(^TUPRN($J,"MATCHED"))
	. . s street=""
	. . for  s street=$O(^UPRNX("X5",post,street)) q:street=""  d
	. . . s bno=$O(^UPRNX("X5",post,street,""))
	. . . i tstreet=street d
	. . . . s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
	. . . . S ALG=ALG_"match65"
	. . . . s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
	. . . i tstreet="",tbno="" d
	. . . . S $P(ALG,"-",2)="match65a"
	. . . . s $p(matchrec,",",2,5)="Si,Ni,Be,Fe"
	. . . . s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
	. . . i tstreet'=street,bno="",tbno="" d
	. . . . f flat=tflat+1,tflat-1 d
	. . . . . ;next door?
	. . . . . i $D(^UPRNX("X5",tpost,tstreet,"",tbuild,flat)) d
	. . . . . . s $P(ALG,"-",2)="match65b"
	. . . . . . s matchrec="Pl,Si,Ne,Be,Fe"
	. . . . . . s matched=$$setuprns^UPRN("X5",post,street,bno,tbuild,tflat)
e63 Q $G(^TUPRN($J,"MATCHED"))
match64(tpost,tbuild,tflat,tbno,tstreet) ;
	s post=""
	for  s post=$O(^UPRNX("X3",ZONE,tbuild,tflat,post)) q:post=""  d  q:$d(^TUPRN($J,"MATCHED"))
	. q:post=tpost
	. s matchrec=$$nearpost^UPRN(post,tpost,2)
	. I matchrec'="" d  q:$D(^TUPRN($J,"MATCHED"))
	. . s street=""
	. . for  s street=$O(^UPRNX("X5",post,street)) q:street=""  d
	. . . i tstreet="",tbno="" d
	. . . . i $D(^UPRNX("X5",post,street,tbno,tbuild,tflat)) d
	. . . . . s $p(matchrec,",",2,5)="Si,Ne,Be,Fe"
	. . . . . S ALG=ALG_"match64"
	. . . . . s matched=$$setuprns^UPRN("X5",post,street,"",tbuild,tflat)
	Q $G(^TUPRN($J,"MATCHED"))
match63(tpost,tstreet,tbno,tbuild,tflat,tloc,tdeploc)     ;
	;location in street, building drop
	i tbuild["home" d
	. i tbno'="",tstreet'="",tflat="" d
	. . s nstreet=$O(^UPRNX("X5",tpost,tstreet))
	. . i (nstreet_" ")[(tstreet_" ") d
	. . . i $D(^UPRNS("ROAD",$p(nstreet," ",$l(tstreet," ")+1,20))) d
	. . . . s matchrec="Pe,Se,Ne,Bd,Fe"
	. . . . s $p(ALG,"-",2)="match63e"
	. . . . s matched=$$setuprns^UPRN("X5",tpost,nstreet,tbno,"","")
	I $D(^TUPRN($J,"MATCHED")) Q 1
	I tstreet'="",tloc'="",tbno'="" D
	. I $D(^UPRNX("X5",tpost,tstreet_" "_tloc,tbno)) d
	. . I tflat="" d
	. . . i $D(^UPRNX("X5",tpost,tstreet_" "_tloc,tbno,"","")) d
	. . . . s matchrec="Pe,Se,Ne,Bd,Fe"
	. . . . s $p(ALG,"-",2)="match63d"
	. . . . S matched=$$setuprns^UPRN("X5",tpost,tstreet_" "_tloc,tbno,"","")
	I $D(^TUPRN($J,"MATCHED")) Q 1
	;Last pattern
	n matched
	s matched=0
	i tdeploc'="",tbno'="",tstreet'="" d
	. I $D(^UPRNX("X5",tpost,tdeploc,tbno,tstreet)) d
	. . s matched=0
	. . s flat=""
	. . for  s flat=$O(^UPRNX("X5",tpost,tdeploc,tbno,tstreet,flat)) q:flat=""  d  q:matched
	. . . I $$MPART^UPRNU(flat,tbuild) d
	. . . . s matchrec="Pe,Se,Ne,Be,F<B"
	. . . . S $P(ALG,"-",2)="match63"
	. . . . s matched=$$setuprns^UPRN("X5",tpost,tdeploc,tbno,tstreet,flat)
	i matched q matched
	;Building = street
	i tbuild=tstreet,tdeploc'="" d
	. I tflat="",tstreet'="",tbno'="",tdeploc'="" D
	. . I $D(^UPRNX("X5",tpost,tdeploc,"",tstreet,tbno)) d
	. . . s matchrec="Pe,Se,N>F,Be,F<N"
	. . . S $P(ALG,"-",2)="match63a"
	. . . s matched=$$setuprns^UPRN("X5",tpost,tdeploc,"",tstreet,tbno)
	;
	;Dig out street from street
	f i=2:1:$l(tstreet," ")-1 d  q:matched
	. s tstr=$p(tstreet," ",1,i)
	. I $D(^UPRNX("X.STR",ZONE,tstr)) d
	. . I $D(^UPRNX("X5",tpost,tstr,tbno)) d
	. . . i tflat=""  d
	. . . . I $D(^UPRNX("X5",tpost,tstr,tbno,"","")) d
	. . . . . s matchrec="Pe,Sp,Ne,Bd,Fe"
	. . . . . s $P(ALG,"-",2)="match63b"
	. . . . . s matched=$$setuprns^UPRN("X5",tpost,tstr,tbno,"","")
	;
	i matched q matched
	;Dig out street from building and number from flat if building is stret
	i tbno="" d
	. I $D(^UPRNX("X.STR",ZONE,tbuild)) d
	. . I '$D(^UPRNX("X.STR",ZONE,tstreet)) d
	. . . I $p(tflat," ",$l(tflat," "))?1n.n.l d
	. . . . s tstno=$p(tflat," ",$l(tflat," "))
	. . . . I $D(^UPRNX("X5",tpost,tbuild,tstno,"","")) d
	. . . . . s matchrec="Pe,S<B,N<F,B>S,Fd"
	. . . . . S $P(ALG,"-",2)="match63c"
	. . . . . s matched=$$setuprns^UPRN("X5",tpost,tbuild,tstno,"","")
	q matched
	;
match61(tpost,tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth) 
	;post code, street and number, street has 'es'
	;Or street is town and levenstein flat and building
	n matched,matchrec,count,table,key,uprn,alg,thouse
	s matched=0
	s matchrec="Pe"
	s count=0
	K ^TPROBABLE($J),^TPOSSIBLE($J)
	s thouse=$$house($p(tbuild," ",$l(tbuild," ")))
	s uprn=""
	for  s uprn=$O(^UPRNX("X1",tpost,uprn)) q:uprn=""  d  q:matched  q:(count>500)
	. s table=""
	. for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  q:matched  q:(count>500)  q:($d(^TPROBABLE($j)))
	. . s key=""
	. . for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  q:matched  q:(count>500)  q:($d(^TPROBABLE($J)))
	. . . s count=count+1
	. . . s matched=$$match61a(tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth,thouse,uprn,table,key)
	I matched q 1
	i $G(^TPROBABLE($J))=1 d
	. s uprn=$O(^TPROBABLE($J,""))
	. s table=$O(^TPROBABLE($J,uprn,""))
	. s key=$O(^TPROBABLE($j,uprn,table,""))
	. s matchrec=^(key)
	. s alg=$G(^TPROBABLE($J,uprn,table,key,"A"))_"-one-nearest"
	. s matched=$$m61set()
	Q $G(^TUPRN($J,"MATCHED"))
common(abp,candidate) ;
		n i,word,common,same
		s common="",same=1
		f i=1:1:$l(abp," ") d  q:('same)
		. s word=$p(abp," ",i)
		. i word=$p(candidate," ",i) d
		. . s $p(common," ",i)=word
		. e  s same=0
		q common
	;	
match61a(tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth,thouse,uprn,table,key)
	n matchrec,alg,org,house,probable,fhouse,tres,res,fe,be,se,ne
	n rec,flat,build,street,bno,loc,deploc,depth,town,pstreet,matched,common
	s matched=0,probable=0
	s matchrec="Pe,Se,Ne,Be,Fe"
	s rec=^UPRN("U",uprn,table,key)
	s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
	S loc=$p(rec,"~",7),town=$p(rec,"~",8),org=$p(rec,"~",10)
	s fe=(tflat=flat),be=(tbuild=build),se=(tstreet=street),ne=(tbno=bno)
	s house="",fhouse=""
	s tres=0,res=0
	i build'="" s house=$$house($p(build," ",$l(build," ")))
	i flat'="" s fhouse=$$house($p(flat," ",$l(flat," ")))
	i thouse'="" s tres=$D(^UPRNS("RESIDENTIAL",thouse))
	i house'="" s res=$D(^UPRNS("RESIDENTIAL",house))
	i flat="",build'="",build?1"flat"1" "1n.n.l d
	. s flat=$p(build," ",$l(build," "))
	. s build=""
	i fe,'be,ne,'se,street="" d  q:matched 1 q:probable 0
	. i tres=res d
	. . s common=$$common(tstreet_" "_tbuild,build)
	. . i common'="",($p(build,common_" ",2)=house&(thouse'=""))!(common=build) d  q
	. . . s matched=$$m61("Pe,S>B,Ne,B<SB,Fe","a2")
	. e  i tdepth'="",house'="",thouse'="" d
	. . i $$equiv^UPRNU($$tr^UPRNL(tdepth_" "_thouse,thouse,house),build) d
	. . . s matchrec="Pe,Sd,Ne,B<Dp,Fe",alg="a7"
	. . . d probable
	i fe,be,ne,'se,$D(^UPRNS("ROAD",$p(tstreet," ",$l(tstreet," ")))) D  i probable q 0
	. i $$equiv^UPRNU($p(tstreet," ",0,$l(tstreet," ")-1),street,5,1) d
	. . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a33"
	. . d probable
	i fe,be,ne,$$equiv^UPRNU($tr(tstreet,"-"," "),$tr(street,"-"," "),6) d  i matched q 1
	. s matched=$$m61("Pe,Sl,Ne,Be,Fe","a38")
	i fe,be,ne,tstreet["/",street'="",$$equiv^UPRNU($p(tstreet,"/"),street)!($$equiv^UPRNU($p(tstreet,"/",2),street)) d  i matched q 1
	. s matched=$$m61("Pe,Sp,Ne,Be,Fe","a35")
	i fe,'be,ne,'se,street="",$tr(tbuild," ")=$tr(build," "),tbuild[tstreet d  i matched q 1
	. s matched=$$m61("Pe,Sd,Ne,Be,Fe","a16")
	i fe,'be,ne,'se,street="",build[tstreet,house'="" d  i probable q 0
	. s common=$$common(build,tstreet)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,S>B,Ne,B<Sp,Fe",alg="a30" d probable
	i fe,ne,'se,street="",tbuild'="",build'="",$$equiv^UPRNU(tstreet_" "_tbuild,build) d  q 0
	. s matchrec="Pe,S>B,Ne,B<S,Fe",alg="a29"
	. d probable
	I fe,'be,ne,'se,$$equiv^UPRNU(build,tbuild,7),$$equiv^UPRNU(street,tstreet) d  i matched q 1
	. s matched=$$m61("Pe,Sl,Ne,Bl,Fe","f")
	i fe,'be,ne,'se,street="",$$equiv^UPRNU(tstreet,build) d  i matched q 1
	. s matched=$$m61("Pe,S>B,Ne,B<S,Fe","a40")
	i fe,'be,ne,'se,tstreet=town,street="",$$equiv^UPRNU(build,tbuild) d  q 0
	. s matchrec="Pe,S>L,Ne,Bl,Fe",alg="a42"
	. d probable
	i fe,be,ne,'se,tstreet_" "_tdepth=street d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,Be,Fe","a21")
	i fe,be,ne,tstreet'="",tstreet=depth d
	. s matched=$$m61("Pe,Se,Ne,Be,Fe","a25")
	i fe,ne,'se,street="",tstreet_" "_tbuild=build s matchrec="Pe,Sp,Ne,B<SB,Fe",alg="a3" d probable q 0
	i fe,ne,'se,street[tdeploc,tstreet=build d  q 0
	. s matchrec="Pe,S<L,Ne,B<S,Fe" s alg="y" d probable
	i fe,ne,tstreet'="",tdepth'="",street[tstreet,tdepth_" "_tbuild=build s matchrec="Pe,Sp,Ne,B<dB,Fe",alg="a8" d probable
	i fe,ne,'se,street="",tdeploc=loc,street_" "_tbuild=build s matched=$$m61("Pe,Si,Ne,B<SB,Fe","a4") i matched q 1
	i fe,ne,'se,street="",tdeploc=loc,house'="",tstreet'="" d  i probable q 0
	. s common=$$common(build,tbuild)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,Sd,Ne,Bp,Fe",alg="a11" d probable
	i fe,'be,'ne,se,bno="",$d(^UPRNS("SCOTLEVEL",build,tbno)) d  i matched q 1
	. s matched=$$m61("Pe,Se,N>B,B<N,Fe","a17")
	i 'fe,be,'ne,'se,tbuild'="",tflat=bno,flat="",street'="",tdepth=street d  i matched q 1
	. s matched=$$m61("Pe,S<D,N<F,Be,F>N","a43")
	i 'fe,be,ne,se,$$eqflat^UPRNB(tflat,flat) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,Be,Fe","a17")
	i 'fe,tflat="",'se,flat'="",tbno=flat,bno="" d  i matched q 1
	. i '$D(^UPRNX("X.STR",ZONE,tstreet)) d  q
	. . i $p(build," ",0,$l(build," ")-1)=tstreet d  q
	. . . s matched=$$m61("Pe,S>B,Ne,B<S,Fe","a5")
	i 'fe,ne,'se,tflat="",tstreet=build d  i matched q 1
	. s common=$$common(flat,tbuild)
	. i common'="",$p(flat,common_" ",2)=fhouse d
	. . s matched=$$m61("Pe,Se,Ne,Bp,Fe","a1")
	i 'fe,'be,'ne,se,tflat=bno,bno'="",tbno="",build="",tbuild'="" d probable q 0
	i 'fe,'be,ne,'se,tbuild="house",bno="",tstreet=build,fhouse'="",street="" d probable q 0
	i 'fe,'be,ne,'se,tbuild'="",build'="",tbuild=flat,tstreet'="" d  i matched q 1
	. I '$D(^UPRNX("X.STR",ZONE,tstreet)) d
	. . i $e(build,1,$l(tstreet))=tstreet d
	. . . s matched=$$m61("Pe,S>B,Ne,B<S,F<B","a6")
	i 'fe,'be,ne,'se,tstreet="",flat'="",tflat'="",tbuild=(build_" "_$p(flat," ")),tflat=$p(flat," ",$l(flat," ")) d  i matched q 1
	. s matched=$$m61("Pe,Si,Ne,B<BF,Fe","a13")
	i 'fe,'be,'ne,se,flat?1n.n,tflat?1n.n1l,tflat=bno,$G(^UPRNS("FLATNUMSUF",flat))=$e(bno,$l(bno)) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,B<F,Fe","a14")
	i 'fe,'be,'ne,se,tbuild="",tflat'="",bno="",$tr(tflat_" "_tbno,"/"," ")=flat d  i matched q 1
	. s matched=$$m61("Pe,Se,N>f,Bi,Fe","a20")
	i 'fe,be,ne,'se,tbuild="",tstreet=depth,flat="",tflat?1"croft"1" "1n.n,$p(tflat," ",$l(tflat," "))=tbno d  i matched q 1
	. s matched=$$m61("Pe,Si,Ne,Be,Fe","a15")
	i fe,be,'ne,tbuild'="",tdepth=street,tbno="" s matchrec="Pe,Se,Ni,Be,Fe",alg="a9" d probable q 0
	i fe,ne,street'="",tstreet_" "_tbuild=build,bno="" s matchrec="Pe,Si,Ne,B<BS,Fe",alg="a10" d probable q 0
	i fe,ne,tbuild'="",thouse="",tbuild[tstreet d  i probable q 0
	. s common=$$common(build,tbuild)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,Sd,Ne,Bp,Fe",alg="a12"
	. . d probable
	i fe,'be,ne,se,tbuild'="",thouse'="",house'="" d  i probable q 0
	. s common=$$common(build,tbuild)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="a28"
	. . d probable
	i 'fe,'be,'ne,se,street'="",tbuild="",bno="",tflat_" "_tbno=flat d  i matched q 1
	. s matched=$$m61("Pe,Se,N>F,Bi,F<FN","a18")
	i 'fe,'be,'ne,se,street'="",tbuild="",bno="",$tr(flat,"-","/")=flat,tbno=build d  i matched q 1
	. s matched=$$m61("Pe,Se,N>B,B<N,Fe","a19")
	i 'fe,'be,'ne,'se,tstreet_" "_tdepth=street,bno=tflat,flat="",tbuild=flat d
	. s matched=$$m61("Pe,Se,N<BF,B>F,Fe","a22")
	i 'fe,'be,'ne,'se,tstreet_" "_tdepth=street,bno="",flat="",tbno_"/"_tflat=build d  i matched q 1
	. s matched=$$m61("Pe,Se,N<F,B>F,F<B","a23")
	i 'fe,'be,'ne,'se,tflat_" "_tbno=flat,bno="" d  i matched q 1
	. i $l(tdepth," ")>1,$l(tstreet," ")>1,$e(build,0,$l(tdepth))=tdepth,$e(tstreet,0,$l(street))=street d
	. . s matched=$$m61("Pe,Sp,N>F,B<Dp,F<FN","a24")
	i 'fe,'be,ne,'se,flat=tbuild,street="",$$equiv^UPRNU(build,tstreet) d  q 0
	. s matchrec="Pe,S>B,Ne,F<B",alg="a26"
	. d probable
	i 'fe,'be,ne,'se,tflat="",tbuild'="",tbuild=flat,build'="",tdepth=build,tdeploc=loc,tloc=town d  i matched q 1
	. s matched=$$m61("Pe,S>B,Ne,B>F,F<B","a26")
	i ne,tflat="",fhouse'="",$p(flat," "_fhouse)=tbuild,tdepth=build,tstreet=loc d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,B>F,F<B","a6")
	i 'fe,'be,ne,se,tbuild_" "_tflat=flat,build'="",build=tdepth d   i matched q 1
	. s matched=$$m61("Pe,Se,B<D,F<BF","a27")
	i 'fe,'be,'ne,'se,tflat'="",tbuild'="",tflat=bno,tbuild=street,loc[tstreet d  i matched  q 1
	. s matched=$$m61("Pe,S<B,N<F,B>S,F>N","a31")
	i 'fe,'be,ne,tbuild'="",tflat="",$$equiv^UPRNU(tbuild,flat_" "_build) d  i matched q 1
	. s matched=$$m61("Pe,Sd,Ne,B>FB,F>B","a34")
	i 'fe,'be,'ne,'se,tflat="",tbuild="",bno="",street="",tbno=flat,$$equiv^UPRNU(tstreet,build) d  i matched q 1
	. s matched=$$m61("Pe,S>B,N>F,B<S,F<N","a36")
	i fe,'be,'ne,'se,tbuild'="",tbno'="",tstreet'="",street="",bno="",$$equiv^UPRNU(tbuild,build) d  q 0
	. s matchrec="Pe,Sd,Nd,Be,Fe",alg="a37"
	. d probable
	i 'fe,'be,'ne,'se,tflat=bno,$D(^UPRNS("ROAD",$p(tbuild," ",$l(tbuild," ")))) D  i probable q 0
	. i $$equiv^UPRNU($p(tbuild," ",0,$l(tbuild," ")-1),street,5,1) d
	. . s matchrec="Pe,S<Bp,N<F,B>S,F>N",alg="a41"
	. . d probable
	i 'fe,'be,'ne,se,tdepth=build,tbno_" "_tflat=flat d  q 0
	. s matchrec="Pe,Se,N>F,B<D,F<NF",alg="a44" d probable
	i street=tstreet,bno="",build=tbno,tbuild="",tflat[" " s matched=$$match61x() i matched q 1
	;	
	i street=tstreet,build=tbuild,tflat=flat d m61a i matched q 1
	i street=tstreet,build=tbuild d m61b i matched q 1
	I street'="",tbno=bno,tflat=flat d m61c i matched q 1
	I tbuild=street,tbuild'="" D m61d i matched q 1
	i tbno="",tflat?1n.n.l1" "1l.e,street=$p(tflat," ",2,10) d m61e i matched q 1
	i flat="",tflat'="",tflat=build,tbno=bno,tstreet=street s matchrec="Pe,Se,Ne,B<F,F>B",alg="z" s matched=$$m61set() q 1 ;ABP missing house name
	;	
	s pstreet=$$plural^UPRNU(street)
	i pstreet'=tstreet,street'="" d  i matched q 1
	. i tbuild="",tbno=flat  d m61f i matched q
	. i tbuild'="",tflat=flat,tbno'="",bno'="",tbno'=bno,$$equiv^UPRNU(build,tbuild) s $p(matchrec,",",2,5)="Si,Ni,Bl,Fe",alg="fab" s matched=$$m61set() i matched q
	. i build'="" d m61g i matched q 
	i tbuild'="",bno=tbno,flat=tflat,$$equiv^UPRNU(build_" "_street,tbuild_" "_tstreet),bno=tflat,tbno="" s $p(matchrec,",",2,5)="Sp,Ne,Be,Fe",alg="ffh" s matched=$$m61set()  i matched q 1
	i tflat?1n.n1" "2l.e,$p(tflat," ",1)=flat,pstreet=tstreet,$$equiv^UPRNU(build,$p(tflat," ",2,10)) s matched=$$match61fc2()  i matched q 1
	I tflat'="",$$equiv^UPRNU(build,tflat_" "_tbuild),$$equiv^UPRNU(loc,tstreet),bno="",tbno="" s $p(matchrec,",",2,5)="Se,Ne,Be,Fe",alg="ffd" s matched=$$m61set()  i matched q 1
	i tbno'="",tbno=$p(build," "),tstreet=$p(build," ",2,10),flat=tflat s $p(matchrec,",",1,5)="Pe,Sp,Np,Bp,Fe",alg="fda" s matched=$$m61set() i matched q 1
	i pstreet=tstreet d  i matched q 1
	. s matched=$$m61ffc(tbno,bno,tbuild,build,tstreet,street,tbno,bno)   i matched q
	. i bno="",flat="",tbuild="",build=(tflat_" "_tbno) s $p(matchrec,",",3,5)="Ne,Be,Fe",alg="ffe" s matched=$$m61set()  i matched q
	. i bno="",flat="",tflat="",build=(tbno_" "_tbuild) s $p(matchrec,",",1,5)="Pe,Se,Ne,Be,Fe",alg="fff" s matched=$$m61set()  i matched q
	. i build="",tbuild="" d  i matched q
	. . i $$fnsplit^UPRN(tbno,bno,tflat,flat) s $p(matchrec,",",2,5)="Se,Ne,Be,Fe",alg="ffg" s matched=$$m61set() q 
	. . I bno="",tflat="",tbno'="",$$mno1^UPRN(tbno,flat) 	s $p(matchrec,",",2,5)="Se,N>F,Be,F>N",alg="ffh" s matched=$$m61set()  q
	. . i flat="",tflat="",bno*1=(tbno*1) s $p(matchrec,",",2,3)="Se,Np" s matched=$$match61ffi() q
	. I build=""!(tbuild="") q
	. i $$MPART^UPRNU(build,tbuild) do  q
	. . i flat=tflat,tbno="",bno'="" s $p(matchrec,",",2,5)="Se,Ni,Bp,Fe",alg="ffk" s matched=$$m61set() q
	. . i flat=tflat,tbno=bno s $p(matchrec,",",2,5)="Se,Ne,Bp,Fe",alg="ffl" s matched=$$m61set() q
	. . I tbno=flat,tflat=bno s $p(matchrec,",",2,5)="Se,Ne,Bp,Fe",alg="ffm" s matched=$$m61set() q
	I $l(tstreet," ")>3,tbuild="" d m61ggb  i matched q 1
	i tflat=flat,tbuild'="",build="",street'="",$tr(tbuild," ")=$tr(street," "),bno=tbno s matchrec="Pe,Sd,Ne,B>S,Fe",alg="ggab" s matched=$$m61set() i matched q 1
	i tbno=bno,tstreet'="",$$equiv^UPRNU(depth,tstreet) d m61gga i matched q 1
	i tbno="",bno'="",tflat=flat D  i matched q 1
	. s $p(matchrec,",",3)="Ni"
	. s $p(matchrec,",",5)="Fe"
	. I $$equiv^UPRNU(street,tstreet,5,2),$$equiv^UPRNU(build,tbuild,5,3) s $p(matchrec,2,5)="Sl,Ni,Bp,Fe",alg="gg" s matched=$$m61set() q
	i flat=tflat,bno="",tbno'="",tbuild["r-o",build=$p(tbuild," r-o"),$$equiv^UPRNU(tstreet,street) s $p(matchrec,",",2,5)="Se,Nd,Be,Fe",alg="y" s matched=$$m61set() i matched q 1
	i street="",build'="",tbno=flat,tstreet=build,tbuild="",flat=""  s matchrec="Pe,Si,Ni,Be,Fe",alg="ggc" s matched=$$m61set() i matched q 1
	i street="",build'="",bno'="",tbno=flat,tstreet=build,tbuild="",tflat="" s matchrec="Pe,Si,Ni,Be,Fe",alg="ggb"  s matched=$$m61set() i matched q 1
	I street'="",tbno=bno,tflat=flat,$l(tbuild," ")>2,tbuild=build s matchrec="Pe,Si,Ne,Be,Fe",alg="ggc" s matched=$$m61set() i matched q 1
	I tflat'="",tflat=flat,tbuild'="",tbno="",$D(^UPRNS("TOWN",tstreet)),$$equiv^UPRNU(tbuild,build,8) s matchrec="Pe,Si,Ni,Bl,Fe",alg="h" s matched=$$m61set() i matched q 1
	I tflat="",flat="",bno="",tbno="",tstreet'="",street="",tbuild="",$$equiv^UPRNU(tstreet,build,8,1) s matchrec="Pe,S>B,Ne,Bf,Fe",alg="f" s matched=$$m61set() i matched q 1
	I tflat="",tbuild="",street="",bno="",flat="",build'="" d  i matched q 1
	. d flatbld^UPRNA(.flat,.build,.tbno,.street,tpost)
	. i tbno=flat,$$equiv^UPRNU(tstreet,build,8),tdeploc=loc s matchrec="Pe,Sl>B,N>B,Bf,Ff",alg="e" s matched=$$m61set() i matched q
	i tflat="",tbuild="",bno="",tbno'="" d  i matched q 1
	. I flat=tbno,$$equiv^UPRNU(build,tstreet,6,1),loc=tloc S matchrec="Pe,Sl>B,N>F,Bl,Fe",alg="d" s matched=$$m61set() q
	. I flat=tbno,tloc'="",$$equiv^UPRNU(build,tstreet_" "_tloc,6,1) S matchrec="Pe,Sl>B,N>F,Bl,Fe",alg="d" s matched=$$m61set() q
	i build'="",tbuild=build,flat=tflat,loc'="",loc=tloc,town'="",town=ttown s matchrec="Pe,Si,Be,Fe",alg="q" s matched=$$m61set() i matched q 1
	i $$equiv^UPRNU($e($tr(tstreet," "),1,8),street),bno'="",tbno=bno,build=tbuild,flat=tflat s matchrec="Pe,Sp,Ne,Be,Fe",alg="g" s matched=$$m61set() i matched q 1
	i street="",tstreet=(build_" "_loc),flat=tflat,bno=tbno,tbuild="" s matchrec="Pe,S>BL,Ne,B<S,Fe",alg="r" s matched=$$m61set() i matched q 1
	i street[" to ",tbuild="",$$equiv^UPRNU(tstreet,build),flat=tflat,tbno=bno s matchrec="Pe,Si,Ne,B<S,Fe",alg="s" s matched=$$m61set() i matched q 1
	i street="",tloc'="",loc=tloc,tflat=bno,tstreet[" ",build[" " i $D(^UPRNS("ROAD",$p(tstreet," ",$l(tstreet," ")))) D  i matched q 1
	. I $D(^UPRNS("ROAD",$p(build," ",$l(build," ")))) d
	. . i $p(tstreet," ",0,$l(tstreet," ")-1)=$p(build," ",0,$l(build," ")-1) s matchrec="Pe,S<Bp,n<F,B>S,F>N",alg="t" s matched=$$m61set() q
	i tloc'="",loc=tloc,bno="",tbno=bno,tflat'="",tflat=flat,$D(^UPRNS("HOUSE",$p(tbuild," ",$l(tbuild," ")))) d  i matched q 1
	. i $p(tbuild," ",0,$l(tbuild," ")-1)=build s matchrec="Pe,Si,Ne,Bp,Fe",alg="u" s matched=$$m61set() q
	i flat="",street=tstreet,build="",tbuild="",tflat?1n.e,bno?1n.n.l d  i matched q 1
	. i tflat*1=(bno*1),$D(^UPRNS("FLOOR",$p(tflat," ",2,10),$p(bno,bno*1,2))) s matchrec="Pe,Se,Ne,Be,Fp",alg="u" s matched=$$m61set() q
	i bno?1n.n1l,tflat?1l,tbno?1n.n,bno=(tbno_tflat),build="" d  i matched q 1
	. i $d(^UPRNS("TOWN",tstreet)),$$equiv^UPRNU(tbuild,street) s matchrec="Pe,S<Bp,Ne,B>S,F>N",alg="v" s matched=$$m61set() q
	I tbuild=flat,$D(^UPRNS("FLOOR",flat)),build="",tstreet=street,bno=tbno s matchrec="Pe,Se,Ne,B>F,F<Bp" d probable q 0
	i $P(tflat," ",2,10)=flat,$D(^UPRNS("FLOOR",flat)),bno=tbno,(tstreet=street!(tstreet=""&(street=tdeploc))),tbuild=build s matchrec="Pe,Se,Ne,B>F,F<Bp" d probable q 0
	i street=tstreet,flat'="",flat=tflat,bno'=tbno,tbuild'="",$$equiv^UPRNU(tbuild,build) s matchrec="Pe,Se,Ni,Be,Fe" d probable q 0
	I tflat=bno,flat="",build="",$$equiv^UPRNU(tbuild,street,"","",1),tstreet=town s matchrec="Pe,Se,N<F,Be,Fe",alg="x73" s matched=$$m61set() i matched q 1
	i $$fbno^UPRN(tflat,flat),tbuild=build,$$equiv^UPRNU(tstreet,street),tbno'="",bno="" s matchrec="Pe,Se,Ni,Be,Fe",alg="x73a" s matched=$$m61set() i matched q 1
	I tflat=bno,flat="",build="",$$equiv^UPRNU(tbuild,street,"","",1),tstreet=town s matchrec="Pe,S<B,N<F,B>S,F>N",alg="x73b" s matched=$$m61set() i matched q 1
	i tbuild'="",house'="",tbuild=$p(build," ",0,$L(build," ")-1),tflat=flat,tbno=bno,tstreet=loc s matchrec="Pe,S>L,Ne,Bp,Fe",alg="za" s matched=$$m61set() i matched q 1
	i tflat=flat,tbno=bno,tbuild'="",tstreet'="",$$equiv^UPRNU(tbuild,build,7),$$equiv^UPRNU(tstreet,loc,7,"",1) S matchrec="Pe,S>L,Ne,Bl,Fe",alg="zc" s matched=$$m61set() i matched q 1
	i tbno=bno,tbuild="",build?1n.n.l,$p(tflat," ",$l(tflat," "))=build,flat="",tstreet=street,(tdeploc=loc!(tloc=loc)) s matchrec="Pe,Se,Ne,BFp,Fe",alg="ze" s matched=$$m61set() i matched q 1
	i tflat=bno,tbuild=loc,tstreet="",street="" s matchrec="Pe,Se,N<F,B>L",alg="zg" s matched=$$m61set() i matched q 1
	i tbno=bno,street=tstreet,tflat'="",flat="",build'="",$$eqflat^UPRNB(tflat,build) s matchrec="Pe,Se,Ne,Be,Fe",alg="zg" s matched=$$m61set() i matched q 1
	I bno?1n.n1l,tbno?1n.n,bno*1=tbno,street=tstreet,build=tbuild,$$eqflat^UPRNB(tflat,$p(bno,bno*1,2)) s matchrec="Pe,Se,Ne,Be,Fp",alg="zh" s matched=$$m61set() i matched q 1
	i tbno=bno,tflat=flat,tbuild'="",build'="",thouse'="",tstreet_" "_$p(tbuild," ",0,$l(tbuild," ")-1)=build s matchrec="Pe,S>B,Ne,B<S,Fe",alg="zi" s matched=$$m61set() i matched q 1
	i tstreet=street,tbno="",tbuild["/",bno=$p(tbuild,"/"),$p(flat," ",$l(flat," "))=tflat s matchrec="Pe,Se,Ne,Be,Fp",alg="zj" s matched=$$m61set() i matched q 1
	i thouse'="",house'="",tdepth=build,tstreet=loc s matchrec="Pe,Se,Ne,Bp,Fe",alg="zo" s matched=$$m61set() i matched q 1
	n flatless
	s flatless=$$tr^UPRNL(tflat," flat","")
	i bno?1n.n,bno=$p(tflat," "),flat=$p(flatless," ",2,20),build=tbuild,street=tstreet s matchrec="Pe,Se,Ne,Be,Fe",alg="zl" s matched=$$m61set() i matched q 1
	i $p(tbuild," ",$l(tbuild," "))="no" s tbuild=$p(tbuild," no")
	n thouse2
	S thouse2=""
	i tbuild[" " s thouse2=$$house($P(tbuild," "))
	i thouse2'="",tstreet="",tloc_" "_thouse2=build,tbno=flat,tflat=bno s matchrec="Pe,Si,Ne,B>S<L,Fe",alg="zm" s matched=$$m61set() i matched q 1
	i tflat=flat,tdepth=build,(tstreet=loc!(tstreet=deploc)),thouse'="" s matchrec="Pe,Se,Ne,Be,Fe",alg="zn" s matched=$$m61set() i matched q 1
	;	
	i house'="",thouse'="",tres=1,res=1,tdepth'="",tdepth_" "_$p(tbuild," ",0,$l(tbuild," ")-1)=$p(build," ",0,$l(build," ")-1) D probable q 0
	;	
	Q $g(^TUPRN($J,"MATCHED"))
probable	;
	s probable=1
	I '$D(^TPROBABLE($J,uprn)) s ^TPROBABLE($J)=$G(^TPROBABLE($J))+1
	S ^TPROBABLE($J,uprn,table,key)=matchrec
	i $g(alg)'="" d
	. S ^TPROBABLE($J,uprn,table,key,"A")=alg
	q
possible	;
	s probable=1
	I '$D(^TPOSSIBLE($J,uprn)) s ^TPOSSIBLE($J)=$G(^TPOSSIBLE($J))+1
	S ^TPOSSIBLE($J,uprn,table,key)=matchrec
	i $g(alg)'="" d
	. S ^TPOSSIBLE($J,uprn,table,key,"A")=alg
	q
house(text)	;
	i $D(^UPRNS("HOUSE",text)) q text
	q ""	
	;
m61(matchrec,alg) ;
	q $$m61set()			
m61set()	;
	s $p(ALG,"-",2)="match61"_alg
	q $$set^UPRN(uprn,table,key);	
match61x()	;
	; tstreet=street, bno="",tbuild="",build=tbno,tflat[" " and tflat last word is flat
	n matched
	s matched=0	
	i flat=$p(tflat," ",$l(tflat," ")) d
	. s matchrec="Pe,Se,N>B,B<N,Fp",alg="match61x" s matched=$$m61set()
	q matched
match61fab()	;
	s $P(ALG,"-",2)="match61fab"
	s matched=$$set^UPRN(uprn,table,key)
	q matched
match61fc2()	;
	i tbno=bno s $p(matchrec,",",2,5)="Se,Ne,Be,Fe"
	i tbno'=bno s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
	s alg="fc2"
	q $$m61set()
match61ffi()	;
	s $p(matchrec,",",5)="Fe"
	s $p(matchrec,",",3)=$s(tbno?1n.n1l:"Nds",1:"Nis")
	s alg="ffi"
	q $$m61set()					
m61a ;Post code matches
	;Street,building,flat, house number= number with suffix
	;Low priority
	s matched=0
	i tbno?1n.n,bno?1n.n1l d
	. i (bno*1)=(tbno*1) d
	. . s $p(matchrec,",",2,5)="Se,Nis,Be,Fe"
	. . s $P(ALG,"-",2)="match61aa"
	. . s matched=$$set^UPRN(uprn,table,key)
	i tbno?1n.n1l,bno?1n.n d
	. i (bno*1)=(tbno*1) d
	. . s $p(matchrec,",",2,5)="Se,Nds,Be,Fe"
	. . s $P(ALG,"-",2)="match61aaa"
	. . s matched=$$set^UPRN(uprn,table,key)
	;i matched b
	q
m61b ;Post code matches
	;ABP number has range and candidate number is in it  and 
	;if candidate hs suffix the suffix in the candidate is the ABP flat 
	s matched=0
	i tbno?1n.n.l,bno["-" d
	. i tbno*1'<$p(bno,"-"),tbno*1'>($p(bno,"-",2)) d
	. . i tbno?1n.n1l i $p(tbno,tbno*1,2)=$g(flat) d
	. . . s matched=1
	. . e  i tbno?1n.n s matched=1
	I matched d
	. s $p(matchrec,",",2,5)="Se,Ne,Be,Fp"
	. s $P(ALG,"-",2)="match61aab"
	. s matched=$$set^UPRN(uprn,table,key)
	q
m61c ;post code
	;flat and house number matches (including nulls)
	; candidate street has 3 words or more and matches ABP building
	;Candiate building not matched
	;ABP street is present but not in candidate
	;E.G. a boat name in a marina
	;	
	s matched=0
	i $l(tstreet," ")>2,tstreet=build d
	. s matchrec="Pe,Si,Ne,Be,Fe"
	. s $P(ALG,"-",2)="match61a"
	. s matched=$$set^UPRN(uprn,table,key)
	q
m61d ;post code matches
	;candidate building not null and matches street
	;candidate number null and candidate flat split across ABP flat
	;and building
	;oe
	s matched=0
	i tbno="",tflat?1n.n.l1" "1l.e,build=$p(tflat," ",2,10) d  q:matched
	. I $D(^UPRNX("X5",tpost,street,"",$p(tflat," ",2,20),$p(tflat," "))) d
	. . s matchrec="Pe,Se,Ne,Be,Fe"
	. . s $P(ALG,"-",2)="match61b"
	. . s matched=$$set^UPRN(uprn,table,key)
	i bno="",build="",$$mno1^UPRN(tflat,flat) d 
	. s matchrec="Pe,Se,Nd,Bd,Fe"
	. s $P(ALG,"-",2)="match61c"
	. s matched=$$set^UPRN(uprn,table,key)
	;i matched b
	Q
m61e ;Post code matches
	;candidate number null, flat contains a number and the rest matches street
	i $D(^UPRNX("X5",tpost,street,$p(tflat," "),"","")) d  q:matched
	. s $p(matchrec,",",1,5)="Pe,Se,Ne,Bi,Fe"
	. s $P(ALG,"-",2)="match61d"
	. s matched=$$set^UPRN(uprn,table,key)
	I $D(^UPRNX("X5",tpost,street,$p(tflat," ")*1,"",$p(tflat," "))) d
	. s $p(matchrec,",",1,5)="Pe,Se,Ne,Bi,Fe"
	. s $P(ALG,"-",2)="match61e"
	. s matched=$$set^UPRN(uprn,table,key)
	q
	;			
	;
m61f ;Post code matches
	s matched=0
	;Pluralised candidate street, candidate building is null
	;street building mix ups 1
	;Building has slid into street
	n matched
	s matched=0
	i $$getfront^UPRNU(pstreet,tstreet,.front,.back) d m61ffz
	i flat=tbno,tflat="",bno="" d
	. i $$getback^UPRNU(tstreet,build_" "_street,.back) d  q
	. . i back'="",$D(^UPRNS("ROAD",back)) d
	. . . s $p(matchrec,",",2,5)="Se,Ne,Be,Fe"
	. . . s ALG=ALG_"m61ffaj"
	. . . s matched=$$set^UPRN(uprn,table,key)
	;i matched b
	q 
m61g ;Post code matches
	;Numbers match, flats are not null
	;Pluralised ABP street
	;buildings not null and ae equivakent
	;Flats are approximate match
	S matched=0
	i tbno=bno,tflat'="",flat'="" d
	. i tbuild'="" d
	. . i $$equiv^UPRNU(build,tbuild) d
	. . . i $$mflat1^UPRN(tflat,flat,.approx) d
	. . . . s $p(matchrec,",",2,5)="Si,Ne,Bl,F"_approx
	. . . . s $P(ALG,"-",2)="match61ffb"
	. . . . s matched=$$set^UPRN(uprn,table,key)
	i tflat'="",flat'="",build=tbuild,$$mflat1^UPRN(tflat,flat,.approx),$$MPART^UPRNU(tstreet,street) d
	. s $p(matchrec,",",2,5)="Sp,Ni,Be,Fe"
	. s $P(ALG,"-",2)="match61ffba"
	. s matched=$$set^UPRN(uprn,table,key)
	q
m61ffz ;
	i bno'="",tbno'="",bno'=tbno q
	s xbuild=$s(tbuild="":front,1:tbuild_" "_front)
	i xbuild=build d
	. s $p(matchrec,",",2)="Se"
	. s $p(matchrec,",",4)="Be"
	. i tbno="",bno'="" s $p(matchrec,",",3)="Ni"
	. i bno="",tbno'="" s $p(matchrec,",",3)="Nd"
	. i bno=tbno s $p(matchrec,",",3)="Ne"
	. i tflat'="",flat="" s $p(matchrec,",",5)="Fd"
	. i flat'="",tflat="" s $p(matchrec,",",5)="Fi"
	. i flat=tflat s $p(matchrec,",",5)="Fe"
	. s ALG=$P(ALG,"-")_"-m61ffa"
	. s matched=$$set^UPRN(uprn,table,key)
	i $D(^TUPRN($J,"MATCHED")) Q
	;	
	;street equivalent, building equivalent to street
	I $$equiv^UPRNU(pstreet,tstreet,8) d
	. I bno=tbno,flat="",tflat="" d
	. . i tbuild="" do
	. . . i build'="",$$equiv^UPRNU(build,tstreet,8) d  q
	. . . . s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
	. . . . s ALG=ALG_"m61ffaa"
	. . . . s matched=$$set^UPRN(uprn,table,key)
	. . . i build="" d  Q
	. . . . s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
	. . . . s ALG=ALG_"m61ffab"
	. . . . s matched=$$set^UPRN(uprn,table,key)
	;	
	I $D(^TUPRN($J,"MATCHED")) Q
	n troad
	s troad=$$stripr^UPRNU(tstreet)
	I $$equiv^UPRNU(pstreet,troad,7) d
	. I bno=tbno,flat="",tflat="" d
	. . i tbuild="" do
	. . . i build'="",$$equiv^UPRNU(build,tstreet,8) d  q
	. . . . s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
	. . . . s ALG=ALG_"m61ffac"
	. . . . s matched=$$set^UPRN(uprn,table,key)
	. . . i build="" d  Q
	. . . . s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
	. . . . s ALG=ALG_"m61ffad"
	. . . . s matched=$$set^UPRN(uprn,table,key)
	i $d(^TUPRN($J,"MATCHED")) Q
	;	
	;building is equivalent to street
	;Doesnt have the right street
	;Flat matches number?
	i build'="",$$equiv^UPRNU(build,tstreet) d  q
	. i bno="",tbno=flat d  q
	. . i tbuild="",flat="",tflat="" d  q:matched
	. . . s $p(matchrec,",",2,5)="Si,Ni,Bl,Fe"
	. . . s ALG=ALG_"m61ffae"
	. . . s matched=$$set^UPRN(uprn,table,key)
	. . i flat'=tbno q
	. . s $p(matchrec,",",2)="Si"
	. . s $p(matchrec,",",3)="Ne"
	. . s $p(matchrec,",",4)="Be"
	. . s $p(matchrec,",",5)="Fe"
	. . s ALG=ALG_"m61ffaf"
	. . s matched=$$set^UPRN(uprn,table,key)
	. i bno'="",tbno'="" d  Q:matched
	. . i flat'=tbno q
	. . s $p(matchrec,",",2)="Si"
	. . s $p(matchrec,",",3)="Ni"
	. . s $p(matchrec,",",4)="Be"
	. . s $p(matchrec,",",5)="Fe"
	. . s ALG=ALG_"m61ffag"
	. . s matched=$$set^UPRN(uprn,table,key)
	. I flat=tflat,flat'="" d
	. . s $p(matchrec,",",2)="Si"
	. . i bno="",tbno'="" s $p(matchrec,",",3)="Nd"
	. . i tbno="",bno'="" s $p(matchrec,",",3)="Ni"
	. . I bno=tbno s $p(matchrec,",",3)="Ne"
	. . s $p(matchrec,",",4,5)="Bl,Fe"
	. . S ALG=ALG_"m61ffah"
	. . s matched=$$set^UPRN(uprn,table,key)
	;	
	;first part of streets match, building has second part
	I $P(pstreet," ")=$p(tstreet," ") d
	. s back=$p(tstreet," ",2,10)
	. I back'="",build'="",build[back d
	. . i bno=tbno,flat=tflat d
	. . . s $p(matchrec,",",2)="Sp"
	. . . s $p(matchrec,",",3)="Ne"
	. . . s $p(matchrec,",",4)="Bp"
	. . . s $p(matchrec,",",5)="Fe"
	. . . s ALG=ALG_"m61ffai"
	. . . s matched=$$set^UPRN(uprn,table,key)
	;	
	q
	;	
m61ffc(tflat,flat,tbuild,build,tstreet,street,tbno,bno) ;
	n matchrec,matched
	i tflat'=""!(tbuild'="") q 0
	I street'=tstreet q 0
	I tbno?1n.n1l,tbno*1=(bno*1),flat=$e(tbno,$l(tbno)) d  q matched
	. s matchrec="Pe,Se,Ne,Bi,Fe"
	. s ALG=ALG_"m61ffat"
	. s matched=$$set^UPRN(uprn,table,key)
	q 0
	Q
m61gga ;equivalent dependent with street, suffix drop on flat
	i $$mflat1^UPRN(tflat,.flat,.approx) d
	. s matchrec="Pe,Sl,Ne,,F"_approx
	. s $p(matchrec,",",4)=$s(tbuild=build:"Be",tbuild'=""&(build=""):"Bd",1:"Bi")
	. s ALG=ALG_"m61gga"
	. s matched=$$set^UPRN(uprn,table,key)
	q
	;	
	;	
m61ggb ;street contains building and street number is flat
	i flat'=tbno,bno'=tbno,tflat'=flat q
	i $$getback^UPRNU(tstreet,build_" "_street,.back) do
	. s matchrec="Pe,Sp,Ne,Bp,Fe"
	. s ALG=ALG_"m61ggb"
	. s matched=$$set^UPRN(uprn,table,key)
	q		