UPRNC ;Additional aglorithms [ 08/01/2023  5:44 PM ]
	;wELSH "f" "v"
	;
match83(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost) 	;
		;scottish combined flat numbers in candidate
	n matches
	s matches=""	
	i tflat?1n.n1"/"1n.n,tbno="" d
	. S ALG="5400-match83a"
	. s matches=$$match62^UPRN(tpost,tstreet,$p(tflat,"/",2),tbuild,$p(tflat,"/")*1,tloc,tdeploc)
	I matches q matches
	i tflat?1n.n1"-"1n.n1"f"1n.n,tbno="" d  i matches q matches
	. i tstreet="",tbuild'="" d
	. . s tstreet=tbuild,tbuild=""
	. S ALG="5400-match83b"
	. s matches=$$match62^UPRN(tpost,tstreet,$p(tflat,"-",1),tbuild,$p(tflat,"-",2),tloc,tdeploc)
	i tflat?1n.n1"-"1"f"1n.n,tbno="" d
	. n tbuildtran
	. s tbuildtran=$$translate(tbuild,1)
	. i tbuildtran'=tbuild d
	. . s matches=$$match62^UPRN(tpost,tbuildtran,$p(tflat,"-",1),tstreet,$p($tr(tflat,"f",""),"-",2),tloc,tdeploc)
	i matches q matches
	i tflat?1n.n1"-"1n.n."f".n,tbno="" d
	. i tstreet="",tbuild'="" d
	. . s tstreet=tbuild,tbuild="" 
	. S ALG="5400-match83c"
	. s matches=$$match83a(tstreet,$p(tflat,"-",1),tbuild,$p(tflat,"-",2),tdepth,tloc,ttown)
	q matches
match83a(tstreet,tbno,tbuild,tflat,tdepth,tloc,ttown) 	;
	n matched,uprn,table,key,adpart,flat,build,bno,street,depth,rec
	S matched=""
	for adpart=ttown,tloc d  q:matched
	. s uprn=""
	. for  s uprn=$O(^UPRNX("X8",tstreet,tbno,adpart,uprn)) q:uprn=""  d  q:matched
	. . s (table,key)=""
	. . for  s table=$O(^UPRNX("X8",tstreet,tbno,adpart,uprn,table)) q:table=""  d  q:matched
	. . . for  s key=$O(^UPRNX("X8",tstreet,tbno,adpart,uprn,table,key)) q:key=""  d  q:matched
	. . . . s rec=^UPRN("U",uprn,table,key)
	. . . . s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	. . . . s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	. . . . s street=$p(rec,"~",5)
	. . . . i flat=tflat,tbno=bno,build=tbuild,depth=tdepth do
	. . . . . s matchrec="Pi,Se,Ne,Be,Fe"
	. . . . . s $p(ALG,"-",2)="match83a"
	. . . . . s matched=$$set^UPRN(uprn,table,key)
	q matched
	;
match81(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost) 	;
	n matched,uprn,table,key,adpart,table,key,post,near,street,bno,build,org,depth,rec,flat
	s post="",matched=0
	for  s post=$O(^UPRNX("X3",ZONE,tstreet,tbno,post)) q:post=""  d  Q:matched
	. s near=$$justarea^UPRN(post,tpost)
	. i near="" q
	. s (uprn,table,key)=""
	. for  s uprn=$O(^UPRNX("X3",ZONE,tstreet,tbno,post,uprn)) q:uprn=""  d  q:matched
	. . for  s table=$o(^UPRNX("X3",ZONE,tstreet,tbno,post,uprn,table)) q:table=""  d  q:matched
	. . . for  s key=$o(^UPRNX("X3",ZONE,tstreet,tbno,post,uprn,table,key)) q:key=""  d  q:matched
	. . . . s rec=^UPRN("U",uprn,table,key)
	. . . . s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	. . . . s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	. . . . s street=$p(rec,"~",5),org=$p(rec,"~",10)
	. . . . i org'="",$$carehome(org)=$$carehome(tbuild) d
	. . . . . S $P(ALG,"-",2)="match81"
	. . . . . s matchrec="Pp,Se,Ne,Be,Fe"
	. . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . i flat="",build=tflat,tflat'="",tbuild="" d
	. . . . . s matchrec="Pp,Se,Ne,Be,Fe"
	. . . . . s $p(ALG,"-",2)="match81a"
	. . . . . s matched=$$set^UPRN(uprn,table,key)
	q matched
match80(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost) 	;
	n matched,uprn,table,key,adpart,table,key,sub,strbuild,v1
	n flat,build,bno,street,rec,table,key
	s matched=0
	for adpart=ttown,tloc d  q:matched
	. s sub=tbno
	. I tbno'="" s uprn=$O(^UPRNX("X8",tstreet,tbno,adpart,""))
	. e  s uprn=$O(^UPRNX("X8",tstreet,tbuild,adpart,"")),sub=tbuild
	. i uprn'="" d
	. . i $O(^UPRNX("X8",tstreet,sub,adpart,uprn))'="" q
	. . s (table,key)=""
	. . for  s table=$O(^UPRNX("X8",tstreet,sub,adpart,uprn,table)) q:table=""  d  q:matched
	. . . for  s key=$O(^UPRNX("X8",tstreet,sub,adpart,uprn,table,key)) q:key=""  d  q:matched
	. . . . s matched=$$match80a(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost,uprn,table,key)
	. i matched q
	. s uprn=$O(^UPRNX("X8",tbuild,tflat,adpart,""))
	. i uprn'="" d
	. . i $O(^UPRNX("X8",tbuild,tflat,adpart,uprn))'="" q
	. . s (table,key)=""
	. . for  s table=$O(^UPRNX("X8",tbuild,tflat,adpart,uprn,table)) q:table=""  d  q:matched
	. . . for  s key=$O(^UPRNX("X8",tbuild,tflat,adpart,uprn,table,key)) q:key=""  d  q:matched
	. . . . s matched=$$match80a(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost,uprn,table,key)
	. i matched q
	. i tpost="" f strbuild="tbuild","tstreet" d  q:matched
	. . i @strbuild="" q
	. . i strbuild="tbuild" s v1=tflat
	. . e  s v1=adbno
	. . s uprn=$o(^UPRNX("X8",@strbuild,v1,adpart,""))
	. . i uprn'="" d
	. . . S (table,key)=""
	. . . i $O(^UPRNX("X8",@strbuild,v1,adpart,uprn))'="" q
	. . . for  s table=$O(^UPRNX("X8",@strbuild,v1,adpart,uprn,table)) q:table=""  d  q:matched
	. . . . for  s key=$O(^UPRNX("X8",@strbuild,v1,adpart,uprn,table,key)) q:key=""  d  q:matched
	. . . . . s rec=^UPRN("U",uprn,table,key)
	. . . . . s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	. . . . . s bno=$p(rec,"~",3)
	. . . . . s street=$p(rec,"~",5)
	. . . . . i tflat=flat,tbuild=build,tbno=bno,tstreet=street d
	. . . . . . s matched=$$m61("Pi,Se,Ne,Be,Fe","a133")
	q matched
	;
	;
	;			
match80a(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown,tpost,uprn,table,key)	;	
	n matched,rec,bno,flat,street,build,depth,org
	s matched=0
	s rec=^UPRN("U",uprn,table,key)
	s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	s street=$p(rec,"~",5),org=$p(rec,"~",10)
	s $p(ALG,"-",2)="match80"
	if (street=tstreet&(bno=tbno)) d
	. i flat'=tflat!(build'=tbuild) q
	. s matchrec="Pi,Se,Ne,Be,Fe"
	. s matched=$$set^UPRN(uprn,table,key)
	if (build=tstreet&(flat=tbno)) d
	. i tflat'=""!(tbuild'="") q
	. s matchrec="Pi,S<B,N>F,Be,Fe"
	. s matched=$$set^UPRN(uprn,table,key)
	i depth=tstreet&(bno=tbno) d
	. i flat'=tflat!(build'=tbuild) q
	. s matchrec="Pi,Se,Ne,Be,Fe"
	. s matched=$$set^UPRN(uprn,table,key)
	i street=tbuild,bno=tflat d
	. i tbno'=""!(tstreet'="") q
	. s matchrec="Pi,S<B,N<F,B<S,F>N"
	. s matched=$$set^UPRN(uprn,table,key)
	q matched
	;
carehome(term)	;
	n i
	f i=$l(term," "):-1:2 d
	. i $D(^UPRNS("CARE HOME",$p(term," ",i,$l(term," ")))) d  q
	. . s term=$p(term," ",0,i-1)
	q term
	;		
match79(tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc,ttown) 	;
	;All post codes
	n matched,uprn,table,key,matchrec,town
	s matched=0
	I tbuild'="",tbno="" d
	. s thouse=$$house(tbuild)
	. f town="ttown","tloc" d  q:matched
	. . i @town'="" d
	. . . n xbuild
	. . . s xbuild=$tr(tbuild," ")
	. . . s (uprn,table,key)=""
	. . . for  s uprn=$O(^UPRNX("X7",xbuild,tflat,@town,uprn)) q:uprn=""  d  q:matched
	. . . . for  s table=$O(^UPRNX("X7",xbuild,tflat,@town,uprn,table)) q:table=""  d  q:matched
	. . . . . for  s key=$O(^UPRNX("X7",xbuild,tflat,@town,uprn,table,key)) q:key=""  d  q:matched
	. . . . . . i $o(^UPRNX("X7",xbuild,tflat,@town,uprn))="" d
	. . . . . . . s matched=$$match61a(tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth,thouse,uprn,table,key)
	. I matched q
	. d options q
	I $G(^TUPRN($J,"MATCHED")) q 1
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
	. . . . . i $O(^UPRNX("X6",tstreet,tbno,@town,tbuild,tflat,uprn))="" d
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
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
	. . . . . i $$equiv^UPRNU(tbuild,build),tflat=flat,tbno=bno,(tstreet=town!(tstreet=loc)) d  q
	. . . . . . s $p(matchrec,",",2,5)="S>L,Ne,Be,Fe"
	. . . . . . s $p(ALG,"-",2)="match75d"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . i tflat=flat,tbuild=build,tbno=bno,tloc=loc,(tdeploc=deploc!(tdeploc=town)) d
	. . . . . . s $p(matchrec,",",2,5)="S>B,Ne,B<S,Fe"
	. . . . . . s $p(ALG,"-",2)="match75c"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . I tbno="",flat="",build="",tbuild=street,tflat=bno d  q
	. . . . . . s bmatch=$G(bmatch,"B>S")
	. . . . . . s matchrec="Pe,S<B,N<F,B>S,F>N,Si"
	. . . . . . S $p(ALG,"-",2)="match75a"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . i loc'="",tloc'="",town'="",tdeploc'="",loc=tdeploc,town=tloc d
	. . . . . . s bmatch=$G(bmatch,"B>S")
	. . . . . . s $p(matchrec,"~",2,5)="S<b,N<F,B>S,F>N"
	. . . . . . s $p(ALG,"-",2)="match75"
	. . . . . . s matched=$$set^UPRN(uprn,table,key)
	. . . . . i tbno=bno d
	. . . . . . s $p(matchrec,",",2,5)="Sdi,Ne,Be,Fe",alg="a170"
	. . . . . . d possible
	d options
	q $g(^TUPRN($J,"MATCHED"))
	;Wrong post code but exact match on street, number and therefore child flat
match74(tpost,tstreet,tbno,tbuild,tflat,tdepth,tdeploc,tloc) ;
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
	. i tbuild="" d
	. . s nstr=$o(^UPRNX("X5",post,tloc_" "))
	. . i nstr[" to " d
	. . . i $D(^UPRNX("X5",post,nstr,"",tstreet,tbno)) d
	. . . . S $P(MATCHREC,",",2,5)="S<L,N>F,B<S,F<N"
	. . . . S $P(ALG,"=",2)="match74b"
	. . . . s matched=$$setuprns^UPRN("X5",post,nstr,"",tstreet,tbno)
	. i tbuild'="",tflat?1n.n,$d(^UPRNX("X5",post,tstreet,tbno,tbuild,"")) d
	. . s $p(matchrec,",",2,5)="Se,Ne,Be,Fc",alg="match74c"
	. . s (uprn,table,key)=""
	. . for  s uprn=$O(^UPRNX("X5",post,tstreet,tbno,tbuild,"",uprn)) q:uprn=""  d
	. . . for  s table=$O(^UPRNX("X5",post,tstreet,tbno,tbuild,"",uprn,table)) q:table=""  d
	. . . . for  s key=$O(^UPRNX("X5",post,tstreet,tbno,tbuild,"",uprn,table,key)) q:key=""  d
	. . . . . d possible
	i matched q 1
	d options
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
	n wno,next,st,word,build,length,matched
	s matchrec="Pe",matched=0
	I tbuild'="" d  i matched q 1
	. f wno=1:1:$l(tbuild," ") d
	. . s word=$p(tbuild," ",wno) q:word=""
	. . s length=$s($l(word)>5:4,1:2)
	. . s st=$e(word,1,length),next=st
	. . for  s next=$O(^UPRNX("X.W",ZONE,next)) q:($e(next,1,length)'=st)  q:next=""  d  q:matched
	. . . i next=word q
	. . . i next'?1l.l."'".".".l q
	. . . i '$$levensh^UPRNU(word,next,5,2) q
	. . . S build=$$tr^UPRNL(tbuild,word,next)
	. . . i '$D(^UPRNX("X3",ZONE,build,tflat)) q
	. . . s post=""
	. . . for  s post=$O(^UPRNX("X3",ZONE,build,tflat,post)) q:post=""  d  q:matched
	. . . . i '$D(^UPRNX("X5",post,tstreet,tbno,build,tflat)) q
	. . . . i $$nearpost^UPRN(post,tpost)'="" d
	. . . . . s $p(ALG,"-",2)="match67"
	. . . . . s matchrec="Pl,Se,Ne,Bl,Fe"
	. . . . . s matched=$$setuprns^UPRN("X5",post,tstreet,tbno,build,tflat)
	E  i tstreet'="" d
	. f wno=1:1:$l(tstreet," ") d
	. . s word=$p(tstreet," ",wno)
	. . s length=$s($l(word)>5:4,1:2)
	. . s st=$e(word,1,length),next=st
	. . for  s next=$O(^UPRNX("X.W",ZONE,next)) q:($e(next,1,length)'=st)  q:next=""  d  q:matched
	. . . i next'?1l.l."'".".".l q
	. . . i '$$levensh^UPRNU(word,next,5,2) q
	. . . S street=$$tr^UPRNL(tstreet,word,next)
	. . . i '$D(^UPRNX("X3",ZONE,street,tbno)) q
	. . . s post=""
	. . . for  s post=$O(^UPRNX("X3",ZONE,street,tbno,post)) q:post=""  d  q:matched
	. . . . i '$D(^UPRNX("X5",post,street,tbno,tbuild,tflat)) q
	. . . . i $$nearpost^UPRN(post,tpost)'="" d
	. . . . . s $p(ALG,"-",2)="match67"
	. . . . . s matchrec="Pl,Se,Ne,Bl,Fe"
	. . . . . s matched=$$setuprns^UPRN("X5",post,street,tbno,tbuild,tflat)
	Q $G(^TUPRN($J,"MATCHED"))
	;
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
	. . I $D(^UPRNX("X5",post,tstreet,tbno,tbuild,$e(tflat,1)_"/"_$e(tflat,2,10))) d
	. . . S ALG=ALG_"match66a"
	. . . s matchrec="Pl,Se,Ne,Be,Fl"
	. . . s matched=$$setuprns^UPRN("X5",post,tstreet,tbno,tbuild,$e(tflat,1)_"/"_$e(tflat,2,10))
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
	i tbno="" d  i matched q matched
	. I $D(^UPRNX("X.STR",ZONE,tbuild)) d
	. . I '$D(^UPRNX("X.STR",ZONE,tstreet)) d
	. . . I $p(tflat," ",$l(tflat," "))?1n.n.l d
	. . . . s tstno=$p(tflat," ",$l(tflat," "))
	. . . . I $D(^UPRNX("X5",tpost,tbuild,tstno,"","")) d
	. . . . . s matchrec="Pe,S<B,N<F,B>S,Fd"
	. . . . . S $P(ALG,"-",2)="match63c"
	. . . . . s matched=$$setuprns^UPRN("X5",tpost,tbuild,tstno,"","")
	;
	q matched
	;
translate(term,option) 	;
		n i,q,from,to
		f i=1:1:$l(term," ") d
		. s from=$p(term," ",i)
		. i $d(^UPRNS("TRANSLATE",from)) d
		. . s to=""
		. . f q=1:1:option s to=$o(^UPRNS("TRANSLATE",from,to)) q:to=""
		. . i to="" q
		. . s $p(term," ",i)=to
		q term
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
	for  s uprn=$O(^UPRNX("X1",tpost,uprn)) q:uprn=""  d  q:matched  q:(count>2000)
	. s table=""
	. for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  q:matched  q:(count>2000)
	. . s key=""
	. . for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  q:matched  q:(count>2000)
	. . . s count=count+1
	. . . s matched=$$match61a(tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth,thouse,uprn,table,key)
	I matched q 1
	d options
	q $G(^TUPRN($J,"MATCHED"))
options	;Processes probables or possibles
	i $G(^TPROBABLE($J))=1 d
	. s uprn=$O(^TPROBABLE($J,""))
	. s table=$O(^TPROBABLE($J,uprn,""))
	. s key=$O(^TPROBABLE($j,uprn,table,""))
	. s matchrec=^(key)
	. s alg=$G(^TPROBABLE($J,uprn,table,key,"A"))_"-one-probable"
	. s matched=$$m61set()
	e  i '$D(^TPROBABLE($J)),$G(^TPOSSIBLE($J))=1 d
	. s uprn=$O(^TPOSSIBLE($J,""))
	. s table=$O(^TPOSSIBLE($J,uprn,""))
	. s key=$O(^TPOSSIBLE($j,uprn,table,""))
	. s matchrec=^(key)
	. s alg=$G(^TPOSSIBLE($J,uprn,table,key,"A"))_"-one-possible"
	. s matched=$$m61set()
	q
	;	
common(abp,candidate) ;
		n i,word,common,same
		s common="",same=1
		f i=1:1:$l(abp," ") d  q:('same)
		. s word=$p(abp," ",i)
		. i word=$p(candidate," ",i) d
		. . s $p(common," ",i)=word
		. e  s same=0
		q common
prefix(abp,candidate) ;
		n i,common,same
		s common="",same=1
		f i=1:1:$l(abp) d  q:('same)
		. i $e(abp,i)=$e(candidate,i) d
		. . s common=common_$e(abp,i)
		. e  s same=0
		q common
nohouse(abp) ;
		n nohouse,i,word,done
		s nohouse="",done=0
		f i=1:1:$l(abp," ") d  q:done
		. s word=$p(abp," ",i)
		. i $d(^UPRNS("HOUSE",word)) s done=1 q
		. s nohouse=nohouse_$s(nohouse="":word,1:" "_word)
		i nohouse="" q abp
		q nohouse
	;
	;	 
fb   ;Flat and building match
	i tbuild?4l.l,tstreet="",tloc=street,depth="",tdepth="",tdeploc="",deploc="",tbno="",bno'="" d  i matched!probable q
	. s matchrec="Pe,Se,Ni,Be,Fe",alg="a118"
	. d possible
	q
fbn ;Flat building and number match
	i $D(^UPRNS("ROAD",$p(tstreet," ",$l(tstreet," ")))) D  i matched!probable q
	. i $$equiv^UPRNU($p(tstreet," ",0,$l(tstreet," ")-1),street,5,1) d
	. . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a33"
	. . d probable
	i tstreet'="" d  i matched!probable q
	. i $D(^UPRNS("ROAD",$p(tstreet," ",2))),tstreet?4l.e,$D(^UPRNS("ROAD",$p(street," ",2))),$e(street,1,$l($p(tstreet," ")))=$p(tstreet," ") d
	. . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a141"
	. . d probable
	. i street="" d
	. . i tbuild'="" d
	. . . i $tr(tbuild," ")=$tr(build," "),tbuild[tstreet d
	. . . . s matched=$$m61("Pe,Sd,Ne,Be,Fe","a16")
	. . . e  i tdepth'="",house'="",thouse'="" d
	. . . . i $$equiv^UPRNU($$tr^UPRNL(tdepth_" "_thouse,thouse,house),build) d
	. . . . . s matchrec="Pe,Sd,Ne,B<Dp,Fe",alg="a7"
	. . . . . d probable
	. . . i tstreet'="" d
	. . . . i '$D(^UPRNX("X.STR",ZONE,tstreet)) d
	. . . . . s matchrec="Pe,Sdi,Ne,Be,Fe",alg="a91"
	. . . . . d possible
	. . i tbuild=""  d
	. . . i $$equiv^UPRNU(tstreet,build) d
	. . . . s matched=$$m61("Pe,S>B,Ne,B<S,Fe","a42")
	. i tstreet["/",street'="",$$equiv^UPRNU($p(tstreet,"/"),street)!($$equiv^UPRNU($p(tstreet,"/",2),street)) d
	. . s matched=$$m61("Pe,Sp,Ne,Be,Fe","a35")
	. i tstreet=depth d  i matched q
	. . s matched=$$m61("Pe,Se,Ne,Be,Fe","a25")
	. i tstreet_" "_tdepth=street d  i matched q
	. . s matched=$$m61("Pe,Se,Ne,Be,Fe","a21")
	. i $$MPART^UPRNU(tstreet,street) d
	. . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a82"
	. . d probable
	. i $l(street," ")>1,tstreet[street d
	. . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a83"
	. . d probable
	. i $$equiv^UPRNU($tr(tstreet,"-"," "),$tr(street,"-"," "),6) d  i matched!probable q
	. . s matched=$$m61("Pe,Sl,Ne,Be,Fe","a38")
	i tstreet="" d  i matched!probable q
	. i tbuild'="" d
	. . s matched=$$m61("Pe,Si,Ne,Bl,Fe","a144")
	;
	q
fbs ; flat building and street
	i tbuild'="",tbno="" d  i matched!probable q
	. s matchrec="Pe,Se,Ni,Be,Fe",alg="a515"
	. d probable
	q
fn  ;Flat and number
	i tbuild'="" d fnb1 q
	i tbuild="" d fnb0
	q
fnb0 ;Flat and number match, null building
	i build'="" do
	. i tflat'="",tbno'=""  d
	. . i $$equiv^UPRNU(tdepth,street) d  q
	. . . s matched=$$m61("Pe,S<D,Ne,Bi,Fe","a80")
	. i tflat="",bno="",build'?1n.e d
	. . i $$equiv^UPRNU(tstreet,build_" "_street) d
	. . . s matched=$$m61("Pe,Sp,Ne,B<Sp,Fe","a191")
	i build[tstreet,thouse="",house'="" d
	. s common=$$common(build,tstreet)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,S>B,Ne,B<Sp,Fe",alg="a30" d probable
	i $$equiv^UPRNU(tstreet,build),flat=tflat  d
	. s matched=$$m61("Pe,Si,Ne,B<S,Fe","a148")
	i street'="",tdeploc'="",street[tdeploc,tstreet=build d
	. s matchrec="Pe,S<L,Ne,B<S,Fe" s alg="a159" d probable
	i tflat'="" d
	. i $$nohouse(build)=tstreet,street="" d
	. . s matchrec="Pe,S>B,Ne,B<Sp,Fe",alg="54"
	. . d possible q
	i tflat="" d
	. i build'="",$$equiv^UPRNU(tstreet,build,5,2) d
	. . s matchrec="Pe,Si,Ne,B<S,Fe",alg="a84"
	. . d possible
	i tbno'="",tstreet'="" d  i matched!probable q
	. i $$equiv^UPRNU(depth,tstreet) d
	. . i tloc[street d
	. . . s matched=$$m61("Pe,S<L,Ne,Bd,Fe","a154")
	q
fnb1  ;Flat and number match, not null building
	i bno="",tflat'="",tstreet'="",tbuild'="",$e(build,1,$l(tstreet))=tstreet,build[tbuild d  q
	. s matchrec="Pe,S>B,Ne,B<SBp,Fe",alg="50"
	. d possible
	i thouse'="",house'="",res,tres d  i matched!probable q
	. n from,to
	. s from=$p(build,tstreet_" "_tloc_" ",2) q:from=""
	. s to=tbuild
	. I $D(^UPRNS("TRANSLATE",from,to)) d
	. . s matchrec="Pe,Si,Ne,B<BS,Fe",alg="51"
	. . d probable
	i street="" d  i matched!probable q
	. i tdeploc=loc,street_" "_tbuild=build d  q
	. . s matched=$$m61("Pe,Si,Ne,B<SB,Fe","a4") 
	. i tdeploc=loc,house'="",tstreet'="" d
	. . s common=$$common(build,tbuild)
	. . i common'="",$p(build,common_" ",2)=house d
	. . . s matchrec="Pe,Sd,Ne,Bp,Fe",alg="a11"
	. . . d probable
	. i tbuild[tstreet,$$nohouse(tbuild)=$$nohouse(build) d
	. . S matchrec="Pe,Sd,Ne,Bp,Fe",alg="56"
	. . d probable
	. i bno'="" d
	. . i tstreet'="" d
	. . . i tstreet=loc d
	. . . . s matchrec="Pe,S>L,Ne,Bd,Fe",alg="a85"
	. . . . d possible
	. i thouse="",house'="" d
	. . i $p(build," "_house)=tbuild d
	. . . i tstreet'="" d
	. . . . i $$equiv^UPRNU(tstreet,loc,6,2) d
	. . . . . s matchrec="Pe,S>L,Ne,Bl,Fe",alg="a180"
	. . . . . d probable
	. i tstreet_" "_tbuild=build d
	. . s matchrec="Pe,Sp,Ne,B<SB,Fe",alg="a3"
	. . d probable
	. i $$equiv^UPRNU(tbuild,build) d
	. . s matched=$$m61("Pe,Sd,Ne,Bl,Fe","a144")
	. i tstreet=town!(tstreet=deploc&(tdeploc=loc)) d
	. . i $$equiv^UPRNU(build,tbuild,6) d
	. . . s matched=$$m61("Pe,S>T,Ne,Be,Fe","a89")
	. . i $$equiv^UPRNU(tstreet_" "_tbuild,build) d
	. . . s matched=$$m61("Pe,S>B,Ne,B<SB,Fe","a2")
	. i $$equiv^UPRNU(tstreet,build) do
	. . i $$equiv^UPRNU(tbuild,flat) d  q
	. . . s matched=$$m61("Pe,S>B,Ne,B<S,Fe","a40")
	. . i tflat?3l.e,$$equiv^UPRNU(tflat,flat) d
	. . . s matchrec="Pe,S>B,Ne,B<S,Fe",alg="a173"
	. . . d probable
	. i $$equiv^UPRNU(tstreet_" "_tbuild,build) d 
	. . s matchrec="Pe,S>B,Ne,B<S,Fe",alg="a29"
	. . d probable
	i tstreet'="" d
	. i tdepth'="",street[tstreet,tdepth_" "_tbuild=build d  i matched!probable q
	. . s matchrec="Pe,Sp,Ne,B<dB,Fe",alg="a8"
	. . d probable
	. i $$equiv^UPRNU(tbuild,build) d
	. . i $D(^UPRNS("ROAD",$p(tstreet," ",$l(tstreet," ")))),$D(^UPRNS("ROAD",$p(street," ",$l(street," ")))) d
	. . . i $$equiv^UPRNU($p(tstreet," ",1,$l(tstreet," ")-1),$p(street," ",1,$l(street," ")-1)) d  q
	. . . . s matched=$$m61("Pe,Sp,Ne,Bl,Fe","a182")
	. . i $$equiv^UPRNU(tstreet,street,6) d
	. . . s matched=$$m61("Pe,Sl,Ne,Bl,Fe","a184")
	. i $$equiv^UPRNU(tbuild_" "_tstreet,build),tloc=loc d
	. . s matched=$$m61("Pe,S>B,Ne,B<SB,Fe","a159")
	. I bno="",$e(build,1,$l(tstreet))=tstreet,build[tbuild d
	. . s matchrec="Pe,S>B,Ne,B<SBp,Fe",alg="50"
	. . d possible
	. i ttown'="",$D(^UPRNS("ROAD",$p(street,ttown_" ",2))),$$equiv^UPRNU(tbuild,build) D  q
	. . S matched=$$m61("Pe,Sp,Ne,Be,Fe","a139")
	. i street'="",tbuild?1n.n1" "1l.e d
	. . i $$equiv^UPRNU($p(tbuild," ",2,10),build) d
	. . . i $$equiv^UPRNU($e(tstreet,1,$l(street)),street) d
	. . . . s matchrec="Pe,Sp,Ne,Bp,Fe",alg="129"
	. . . . d possible
	i tstreet="" do
	. i street'="" do 
	. . i $$equiv^UPRNU(tbuild,build) d
	. . . s matchrec="Pe,Si,Ne,Bl,Fe",alg="a154"
	. . . d probable
	. . i $p(tbuild," ",1)=$p(build," ",1),$D(^UPRNS("HOUSE",$p(tbuild," ",2,10))),$d(^UPRNS("HOUSE",$p(build," ",2,10))) d
	. . . s matchrec="Pe,Si,Ne,Bp,Fe",alg="a162"
	. . . d possible
	i tflat="" d
	. i tbuild=thouse,tres=res d
	. . i $$equiv^UPRNU($$nohouse(build),tstreet,5) d
	. . . s matchrec="Pe,S>B,Ne,B<Sl,Fe",alg="61"
	. . . d possible
	i thouse=tbuild do
	. i street="",$$nohouse^UPRNC(build)=(tstreet_" "_tloc) d
	. . S matchrec="Pe,S>B,Ne,B<SL,Fe",alg="a66"
	. . d possible
	. i tstreet=build d
	. . s matchrec="Pe,Si,Ne,B<S,Fe",alg="a68"
	. . d probable
	q
fns ;Flat number and street
	i tbuild'="" d fnsb1  i matched!probable q
	i tflat="",tbno="",tbuild=thouse,tstreet="",$$equiv^UPRNU(build,tloc,10,1) d  i matched!probable q
	. s matchrec="Pe,Se,Ne,B<Ll,Fe",alg="52"
	. d probable
	;
	q
fnsb1  ; Match on flat number and street, not null building
	i $$equiv^UPRNU($p(build," "_house),tbuild,5) D  i matched!probable q
	. s matchrec="Pe,Se,Ne,Bp,Fe",alg="59"
	. d possible
	i thouse'="",house="" d
	. i $$equiv^UPRNU($p(tbuild," "_thouse),build) d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="a142"
	. . d probable
	i house'="",thouse="" d
	. i $$equiv^UPRNU($p(build," "_house),tbuild) d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="59"
	. . d possible
	i house'="",thouse'="" d
	. i $$equiv^UPRNU($p(tbuild," "_thouse),$p(build," "_house)) d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="59"
	. . d possible
	. s common=$$common(build,tbuild)
	. i common'="",$D(^UPRNS("PHRASE",$p(build,common_" ",2),$P(tbuild,common_" ",2))) d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="a196"
	. . d probable
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,Se,Ne,Bp,Fe",alg="a28"
	. . d possible
	. i tloc'="",tflat="",tbno="",street="",tstreet="",tbuild=thouse,res,tres d
	. . s common=$$common(build,tloc)
	. . i common'="" i $p(build,common_" ",2)=house d
	. . . s matchrec="Pe,Se,Ne,B<Lp,Fe",alg="50"
	. . . d possible
	i house="",thouse="" d
	. i $$equiv^UPRNU(tbuild,build,5,2) d
	. . s matchrec="Pe,Se,Ne,Bl,Fe",alg="a143"
	. . d probable
	i build'="" d  i matched!probable q
	. n mincount
	. s mincount=$s($l(tbuild," ")>$l(build," "):$l(tbuild," ")-1,1:$l(build," ")-1)
	. i $p(tbuild," ",1,mincount)=build d  q
	. . s matchrec="Se,Ne,Bp,Fe",alg="a93"
	. . d probable
	. i thouse'="",house'="",$$equiv^UPRNU($p(tbuild," "_thouse),$p(build," "_house)) d
	. . s matchrec="Se,Ne,Bp,Fe",alg="a132"
	. . d possible
	. i thouse="",$$MPART^UPRNU(tbuild,build,mincount) d
	. . s matchrec="Se,Ne,Bp,Fe"
	. . i tflat?1l.l1" "1l.e s alg="a140" d probable q
	. . d possible
	i $$equiv^UPRNU($p(build," "_house),tbuild,8,3) D  i matched!probable q
	. s matchrec="Pe,Se,Ne,Bp,Fe",alg="59"
	. d possible
	q
fs   ;Flat street match
	i tbuild="" d fsb0 q
	d fsb1
	q
fsb0  ; flat street match, null building
	i tbno'="" d fstb0n1 q	
	q
fsb1 ; flat street match, not null building
	i tbno="" d fsb1n0 q
	q
fsb1n0  ;Flat street match, not null building, null number
	i $$equiv^UPRNU(tbuild,build,7) d
	. s matchrec="Pe,Se,Ni,Bl,Fe",alg="a145"
	. d probable
	q
fstb0n1	; flat street match, null building, not null number
	i bno="" do  i matched!probable q
	. i $d(^UPRNS("SCOTLEVEL",build,tbno)) d  q
	. . s matched=$$m61("Pe,Se,N>B,B<N,Fe","a17")
	. i flat="" d
	. . i $$flateq^UPRNU(tbno,build) d
	. . . s matched=$$m61("Pe,Se,N>B,B<N,Fe","A170")   
	q
bns ; building, number and street match
	i $$eqflat^UPRNB(tflat,flat) d  i matched!probable q
	. s matched=$$m61("Pe,Se,Ne,Be,Fe","a17")
	i $$flateq^UPRNU(tflat,flat) d  i matched!probable q
	. s matchred="Pe,Se,Ne,Be,Fp",alg="a206"
	. d possible
	I $G(^UPRNS("SCOTLEVEL",flat))=tflat d  i matched q
	. s matched=$$m61("Pe,De,Ne,Be,Fe","a121")
	i tflat'="",flat'="",bno'="" d
	. i $tr(tflat,"/","f")=flat d
	. . s matchrec="Pe,Se,Ne,Be,Fp",alg="a205"
	. . d possible
	i tflat'="",flat="" d
	. I $D(^UPRNX("X5",tpost,tstreet,tbno,tbuild)) d
	. . I $o(^UPRNX("X5",tpost,tstreet,tbno,tbuild,""))="" d
	. . . s xuprn=$O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"",""))
	. . . i xuprn'=uprn q
	. . . i $O(^UPRNX("X5",tpost,tstreet,tbno,tbuild,"",xuprn))="" d
	. . . . I $G(^UPRN("CLASSIFICATION",^UPRN("CLASS",uprn),"residential"))="Y" d
	. . . . . s matchrec="Pe,Se,Ne,Be,Fc",alg="c1"
	. . . . . d possible
	;	
	q
bs   ; building and street
	i tflat?1n.n1"/"1n.n d  i matched!probable q
	. i $p(tflat,"/",2)=bno,$$flateq^UPRNU($p(tflat,"/"),flat) d
	. . s alg="a112"
	. . s matchrec="Pe,Se,N<F,Be,Fe"
	. . d probable
	i tflat?1n.n1"-"1n.n.l1n.n d  i matched!probable q
	. i $p(tflat,"-")=bno,$p(tflat,"-",2)=flat d
	. . s matched=$$m61("Pe,Se,N<F,Be,Fe","a114")
	i tbno?1n.n1l,$l(flat," ")>2,$$eqflatnum^UPRNB(tflat,flat,tbno,bno) d  q
	. s matched=$$m61("Pe,Se,Nl,Be,F<FN","a49")
	i tflat?1n.n1"f"1n.n d
	. i $p(tflat,"f")=bno,$p(tflat,"f",2)=flat d
	. . s matchrec="Pe,Se,N<F,Be,Fp",alg="a204"
	. . d possible
	i tbno?1n.n1"-"1n.n do
	. i tflat="",$p(tbno,"-",2)=bno,$$flateq^UPRNU($p(tbno,"-"),flat) d
	. . s matchrec="Pe,Se,N<Fp,Be,Fp",alg="a208"
	. . d probable
	. i $p(tbno,"-")=bno,$p(tbno,"-",2)=flat d
	. . s matchrec="Pe,Se,Np,Be,F<Np",alg="a206"
	. . d possible
	i tflat="",bno="",tbno?1n.n,flat?1n.n1"-"1n.n d
	. i tbno'<$p(flat,"-")&(tbno'>$p(flat,"-",2)) d
	. . s matchrec="Pe,Se,N>F,Be,F<Np",alg="a210"
	. . d possible
	i tflat="",bno
	;	
	q
b    ;Building
	i tbuild'="" do
	. i tflat=bno,flat="",street'="",tdepth=street d  i matched q 1
	. . s matched=$$m61("Pe,S<D,N<F,Be,F>N","a43")
	i $D(^UPRNS("ROAD",$p(tstreet," ",$l(tstreet," ")))) D  i matched!probable q
	. i $p(tstreet," ",0,$l(tstreet," ")-1)=$p(street," ",0,$l(street," ")-1) d
	. . i tflat["-",bno=$p(tflat,"-"),$$flateq^UPRNU($p(tflat,"-",2),flat) d
	. . . s matchrec="Pe,Sp,Ne,Be,Fe",alg="a109"
	. . . d probable
	i build'="",bno=(tflat_"-"_tbno),tstreet'="",$e(street,1,$l(tstreet))=tstreet d  i matched q 1
	. s matched=$$m61("Pe,Sp,N<NF,Be,F>N","a60")
	i tbuild="" d
	. i tbno["-",$p(tbno,"-")=bno,$p(tbno,"-",2)=flat d
	. . i $$equiv^UPRNU(tstreet,street) d
	. . . s matched=$$m61("Pe,Sl,Np,Be,F<Np","a189")
	q
ns  ;Number street
	I tflat'="" d  i matched!probable q
	. i $$equiv^UPRNU(build,tflat_" "_tbuild) d
	. . s matched=$$m61("Pe,Se,Ne,B<FB,F>B","a153")
	. i flat="",bno="",tbuild="",tflat?1n.n1"/"1l d
	. . i build?1n.n1"/"1n.n d
	. . . i $p(build,"/")=(tflat*1),$G(^UPRNS("SCOTLEVEL","/"_$p(build,"/",2)))=$p(tflat,"/",2) d
	. . . . s matchrec="Pe,Se,Ne,B<F,Fl",alg="a192"
	. . . . d possible
	. i flat'="",street="",tstreet="" do
	. . i $$equiv^UPRNU(tflat,flat_" "_build) dO
	. . . s matched=$$m61("Pe,Se,Ne,B<F,Fe","a181")
	. i flat="",bno="",$$flateq^UPRNU(tflat,build) do
	. . s matchrec="Pe,Se,Ne,Bd,Fe",alg="a182" 
	. . d possible
	i tflat="",tbuild'="",$$equiv^UPRNU(tbuild,build) d
	. I $O(^UPRNX("X5",tpost,tstreet,tbno,build,""))=flat d
	. . I $O(^UPRNX("X5",tpost,tstreet,tbno,build,flat))="" d
	. . . s matchrec="Pe,Se,Ne,Bl,Fi",alg="199"
	. . . d probable
	q
f   ;Flat
	i tbno'="",tbno=$p(build," "),tstreet=$p(build," ",2,10),flat=tflat do  i matched!probable q
	. s $p(matchrec,",",1,5)="Pe,Sp,Np,Bp,Fe",alg="a156"
	. d probable
	i tflat="",tbuild="",flat="",tbno'="",bno="" d
	. i $$flateq^UPRNU(tbno,build) d	 
	. . i $$equiv^UPRNU(tstreet,street) d
	. . . s matched=$$m61("Pe,Sl,N>B,B<N,Fe","a188")
	q
n   ;Number
	i tbuild'="" d  i matched!probable q
	. i build'="" d
	. . i tstreet'="" d
	. . . i tflat="" d
	. . . . i $$equiv^UPRNU(tstreet,build) d
	. . . . . i $$equiv^UPRNU(tbuild,flat,7,1) d
	. . . . . . s matchrec="Pe,Si,Ne,B<S,F<B",alg="a163"
	. . . . . . d probable
	. . . . . i $$equiv^UPRNU(tbuild,flat,7,2) d
	. . . . . . s matchrec="Pe,Si,Ne,B<S,F<B",alg="a165"
	. . . . . . d possible
	. . . . i $$equiv^UPRNU(tbuild,flat,7,2) d
	. . . . . i house'="",$$equiv^UPRNU(tstreet,$p(build," "_house)) d
	. . . . . . s matchrec="Pe,Si,Ne,B<S,F<B",alg="a164"
	. . . . . . d probable
	. . i tstreet="" d
	. . . i tflat="",thouse'="",flat[thouse,build'="",$$equiv^UPRNU($p(tbuild," ",1,$l(tbuild," ")-1),build) d
	. . . . s matchrec="Pe,Si,Ne,Bp,Fp",alg="a131"
	. . . . d probable
	. . i tflat'="",bno'="",$p(tflat," ")=flat,$p(tflat," ",2,10)?1n.n d
	. . . i $$equiv^UPRNU(tbuild,build) d
	. . . . i tstreet'="",street'="" d
	. . . . . i $$equiv^UPRNU(tstreet,$e(street_" "_town,1,$l(tstreet))) d
	. . . . . . s matchrec="Pe,Sp,Ne,Bl,Fp",alg="a203"
	. . . . . . d possible
	. i tflat'="",tflat=$p(flat," ",1) d
	. . i $$equiv^UPRNU(tstreet_tloc,build) d
	. . . i $d(^UPRNS("HOUSE",$p(flat," ",$l(flat," ")))) d
	. . . . i $$equiv^UPRNU(tbuild,$p(flat," ",2,$l(flat," ")-1)) d
	. . . . . s matched=$$m61("Pe,S>B,Ne,B<SL,F>B","a183")
	. i tflat'="",tbuild=street,$$tr^UPRNL(tflat,"-f","/")=build,flat="",bno="" d
	. . s matchrec="Pe,S<B,Ne,B<Fp,F>B",alg="a206"
	. . d possible
	;	
	i thouse=tbuild,tstreet=build,street="",flat?1l.l.e,$D(^UPRNS("HOUSE",$p(flat," ",$l(flat," ")))) d  i matched!probable q
	. s matchrec="Pe,S>B,Ne,B<S,Fp",alg="53"
	. d possible
	i bno="",street="",tflat="",$$equiv^UPRNU(tstreet_" "_tbuild,build) d  i matched!probable q
	. s matchrec="Pe,S>B,Ne,B<SB,Fi",alg="58"
	. d possible
	i tflat="",flat=tbuild d  i matched!probable q
	. i build'="",tdepth=build,tdeploc=loc,tloc=town d  q
	. . s matched=$$m61("Pe,S>B,Ne,B>F,F<B","a26")
	. i street="" d  Q
	. . i $$equiv^UPRNU(build,tstreet) d  q
	. . . s matched=$$m61("Pe,S>B,Ne,B>F,F<B","a147")
	. . i $$equiv^UPRNU(build,tstreet) d  q
	. . . s matchrec="Pe,S>B,Ne,F<B",alg="a26"
	. . . d probable
	. i build'="",$$equiv^UPRNU(tstreet,build) d
	. . s matchrec="Pe,Si,Ne,B<S,F<B",alg="a146"
	. . d probable
	i tstreet=flat,tloc'="",$$nohouse^UPRNC(build)=tloc d  i matched!probable q
	. s matchrec="Pe,S>F,Ne,B<Lp,F<S",alg="a65"
	. d possible
	i tflat="",tbuild'="",tloc'="",tbuild=flat,build=tloc,town=ttown,depth="",tdepth="",street="" d  i matched!probable q
	. s matchrec="Pe,Sd,Ne,B<L,F<B",alg="a120"
	. d possible
	q
s   ;Street only
	i build?1n.n1"/"1n.n,tbno_tflat=build d  i matched q
	. s matched=$$m61("Pe,Se,N>B,B<FN,F>B","a125")
	i tbno_" "_tbuild=build,tflat'="",tflat=bno d
	. s matchrec="Pe,Se,N<F,B<BN,F>N",alg="a46"
	. d probable
	i tflat=bno,bno'="",tbno="",build="",tbuild'="" d
	. s matchrec="Pe,Se,N<F,Bi,F>N",alg="a200" 
	. d probable
	;	
	q
x   ;No match
	i tflat="" d xf0 q
	i tflat'="" d xf1 q
	;	
	;	
	q
xf0 ; No match, null flat
	i tbuild="" do
	. i bno="",street="",tbno=flat,$$equiv^UPRNU(tstreet,build) d  i matched q
	. . s matched=$$m61("Pe,S>B,N>F,B<S,F<N","a36")
	. i tflat="",tbno=flat,tstreet'="",build'="" do
	. . i street="",$e(build,1,$l(tstreet))=tstreet,tloc=loc d  i matched!probable q
	. . . s matchrec="Pe,S>B,N>F,B<Sp,F<N",alg="a49"
	. . . d possible
	. . i street'="",loc'="",$$equiv^UPRNU(tstreet,build_" "_street_" "_loc) d
	. . . s matched=$$m61("Pe,S<SB,N>f,B<Sp,F<N","a202")
	i tbno=flat,bno="" do
	. i street="" do
	. . i build'="" d  i probable q
	. . . n shouse
	. . . s shouse=$$house($P(tstreet," ",$l(tstreet," ")))
	. . . i shouse'="",shouse=house,$$nohouse(build)=$$nohouse(tstreet) d
	. . . . s matchrec="Pe,S>B,N>F,B<Sp,F<N",alg="57"
	. . . . d probable
	. i street'="" d
	. . i $$equiv^UPRNU(tstreet,build) d
	. . . i tbuild'="",build[tbuild d
	. . . . s matchrec="Pe,Si,N<F,B<Si,F<N",alg="a186"
	. . . . d possible
	i bno'="",street'="",$$equiv^UPRNU(tbuild,bno_" "_flat_" "_street) d  i matched!probable q
	. s matched=$$m61("Pe,S<B,N<B,B>FSN,F<B","a158")
	i tbuild="",bno="",street'="",tstreet'="",tloc=loc!(tloc=town),tbno=flat,$$equiv^UPRNU(tstreet,build) d  i matched q
	. s matched=$$m61("Pe,Si,N>F,B<S,F<N","a70")
	i tbuild'="" d
	. i flat?1l.l1" "1n.n,$p(flat," ",2)=tbno d
	. . i $p(tbuild," ")=$p(flat," ") d
	. . . i $D(^UPRNS("HOUSE",$P(tbuild," ",2,10))) d
	. . . . i $$equiv^UPRNU(tstreet,build) d
	. . . . . s matched=$$m61("Pe,S>B,N>F,B<S,F<BN","a190") 
	q
xf1  ; No match,not null flat
	i tflat=bno d  i matched!probable q
	. i flat="" do
	. . i tbuild'="" do
	. . . i tstreet'="",build="",tbno="",street[" ",$p(tbuild," ")=$p(street," "),$$MPART^UPRNU(tbuild_" "_tstreet,street,$l(street," ")-1) do  i matched q
	. . . . s matched=$$m61("Pe,S<Bf,N<F,B>S,F>N","a115")	
	. . . i build="",$$equiv^UPRNU(tbuild,street) d
	. . . . s matchrec="Pe,S<Bd,N<F,B>S,F>N",alg="171"
	. . . . d probable
	. . i tbno="",build="",$$MPART^UPRNU(tbuild,street),(tstreet=deploc!(tstreet=loc)) d 
	. . . s matched=$$m61("Pe,S<B,N>F,B>S,F>N","a81")
	I (tbno_" "_tstreet)=build d  i matched!probable q
	. i $D(^UPRNS("SCOTFLOORSIDE",flat,tflat)) d
	. . s matchrec="Pe,Si,N>B,B<SN,Fe",alg="a149"
	. . d probable
	;
	;	
	i tflat?1n.n.l1" "1n.n.l,$p(tflat," ")=flat,$p(tflat," ",2)=bno,$$equiv^UPRNU(tbuild,street),build="" d  i matched!probable q
	. s matched=$$m61("Pe,S<B,N<F,B>S,Fe","a73")
	i tbuild'="",tflat=bno,tbuild=street,loc[tstreet d  i matched  q
	. s matched=$$m61("Pe,S<B,N<F,B>S,F>N","a31")
	i tflat_" "_tbno=flat,bno="" d  i matched!probable q
	. i $l(tdepth," ")>1,$l(tstreet," ")>1,$e(build,0,$l(tdepth))=tdepth,$e(tstreet,0,$l(street))=street d
	. . s matched=$$m61("Pe,Sp,N>F,B<Dp,F<FN","a24")
	i tflat=bno,INBRACKET'="",build="",flat="",$P(tbuild," "_INBRACKET)=street d  i matched!probable q
	. s matched=$$m61("Pe,S<B,N<F,B>S,Fe","a72")
	i flat="",build="",tflat=bno,tbno="",tstreet="",$e(street,1,$l(tbuild))=tbuild d  I matched!probable q
	. s matchrec="Pe,S<Bp,N<F,B>S,F>N",alg="a51"
	. d possible
	i tflat=bno,$D(^UPRNS("ROAD",$p(tbuild," ",$l(tbuild," ")))) D  i matched!probable q
	. i $$equiv^UPRNU($p(tbuild," ",0,$l(tbuild," ")-1),street,5,1) d
	. . s matchrec="Pe,S<Bp,N<F,B>S,F>N",alg="a41"
	. . d probable
	i tstreet_" "_tdepth=street,bno="",flat="",tbno_"/"_tflat=build d   i matched!probable q
	. s matched=$$m61("Pe,Se,N<F,B>F,F<B","a23")
	i tstreet_" "_tdepth=street,bno=tflat,flat="",tbuild=flat d
	. s matched=$$m61("Pe,Se,N<BF,B>F,Fe","a22")
	;	
	i build="" do
	. i flat="",tflat?1n.n1" "1l.e,bno=$p(tflat," "),street=$p(tflat," ",2,10) d
	. . s matchrec="Pe,S<F,N<F,Bd,F>NS",alg="a136"
	. . d possible
	i build'="" d
	. i build=(tbno_" "_tstreet),tbuild="",(tloc=town!(ttown=town)) d
	. . i $$flateq^UPRNU(tflat,flat) d
	. . . s matchrec="Pe,Si,N>S,B>S,Fe"
	. . . s matched=$$m61(matchrec,"a113")
	q
	;		
match61a(tstreet,tbno,tbuild,tflat,tloc,tdeploc,ttown,tdepth,thouse,uprn,table,key)
	n matchrec,alg,org,house,probable,fhouse,tres,res,fe,be,se,ne
	n rec,flat,build,street,bno,loc,deploc,depth,town,pstreet,matched,common,inbracket
	s matched=0,probable=0
	s matchrec="Pe,Se,Ne,Be,Fe"
	s rec=^UPRN("U",uprn,table,key)
	s flat=$p(rec,"~",1),build=$p(rec,"~",2)
	s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
	s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
	S loc=$p(rec,"~",7),town=$p(rec,"~",8),org=$p(rec,"~",10)
	s fe=(tflat=flat),be=(tbuild=build),se=$tr(tstreet,"-"," ")=$tr(street,"-"," "),ne=(tbno=bno)
	s house="",fhouse=""
	s tres=0,res=0
	i build'="" s house=$$house($p(build," ",$l(build," ")))
	i flat'="" s fhouse=$$house($p(flat," ",$l(flat,"S ")))
	i thouse'="" s tres=$D(^UPRNS("RESIDENTIAL",thouse))
	i house'="" s res=$D(^UPRNS("RESIDENTIAL",house))
	i flat="",build'="",build?1"flat"1" "1n.n.l d
	. s flat=$p(build," ",$l(build," "))
	. s build=""
	i fe,be,'ne,'se d fb q:matched 1 q:probable 0
	i fe,be,ne,'se d fbn q:matched 1 q:probable 0
	i fe,be,'ne,se d fbs q:matched 1 q:probable 0	
	i fe,'be,ne,'se d fn q:matched 1 q:probable 0
	i fe,'be,ne,se d fns q:probable 0 q:matched 1	
	i fe,'be,'ne,se d fs q:matched 1 q:probable 0
	i 'fe,be,ne,se d bns q:matched 1 q:probable 0
	i 'fe,'be,ne,se d ns q:matched 1  q:probable 0
	i fe,'be,'ne,'se d f q:matched 1 q:probable 0
	i 'fe,'be,ne,'se d n q:matched 1 q:probable 0
	i 'fe,'be,'ne,'se d x q:matched 1  q:probable 0
	i 'fe,be,'ne,'se d b q:matched 1 q:probable 0	
	i 'fe,'be,'ne,se d s q:matched 1 q:probable 0
	i 'fe,be,'ne,se d bs q:matched 1 q:probable 0
	i 'fe,tflat="",'se,flat'="",tbno=flat,bno="" d  i matched q 1
	. i '$D(^UPRNX("X.STR",ZONE,tstreet)) d  q
	. . i $p(build," ",0,$l(build," ")-1)=tstreet d  q
	. . . s matched=$$m61("Pe,S>B,Ne,B<S,Fe","a5")
	i 'fe,ne,'se,tflat="",tstreet=build d  i matched q 1
	. s common=$$common(flat,tbuild)
	. i common'="",$p(flat,common_" ",2)=fhouse d
	. . s matched=$$m61("Pe,Se,Ne,Bp,Fe","a1")
	;	
	;
	i 'fe,'be,'ne,se,flat?1n.n,tflat?1n.n1l,tflat=bno,$G(^UPRNS("FLATNUMSUF",flat))=$e(bno,$l(bno)) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,B<F,Fe","a14")
	i 'fe,'be,'ne,se,tbuild="",tflat'="",bno="",$tr(tflat_" "_tbno,"/"," ")=flat d  i matched q 1
	. s matched=$$m61("Pe,Se,N>f,Bi,Fe","a20")
	i 'fe,be,ne,'se,tbuild="",tstreet=depth,flat="",tflat?1"croft"1" "1n.n,$p(tflat," ",$l(tflat," "))=tbno d  i matched q 1
	. s matched=$$m61("Pe,Si,Ne,Be,Fe","a15")
	i fe,be,'ne,tbuild'="",tdepth=street,tbno="" s matchrec="Pe,Se,Ni,Be,Fe",alg="a9" d probable q 0
	i fe,ne,street'="",tstreet_" "_tbuild=build,bno="" s matchrec="Pe,Si,Ne,B<BS,Fe",alg="a10" d probable q 0
	i fe,ne,tbuild'="",thouse="",tbuild[tstreet,tbuild'=street d  i probable q 0
	. s common=$$common(build,tbuild)
	. i common'="",$p(build,common_" ",2)=house d
	. . s matchrec="Pe,Sd,Ne,Bp,Fe",alg="a12"
	. . d probable
	;	
	;	
	i 'fe,'be,'ne,se,street'="",tbuild="",bno="",tflat_" "_tbno=flat d  i matched q 1
	. s matched=$$m61("Pe,Se,N>F,Bi,F<FN","a18")
	i 'fe,'be,'ne,se,street'="",tbuild="",bno="",$tr(flat,"-","/")=flat,tbno=build d  i matched q 1
	. s matched=$$m61("Pe,Se,N>B,B<N,Fe","a19")
	;	
	;	
	;
	i ne,tflat="",fhouse'="",$p(flat," "_fhouse)=tbuild,tdepth=build,tstreet=loc d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,B>F,F<B","a6")
	i 'fe,'be,ne,se,tbuild_" "_tflat=flat,build'="",build=tdepth d   i matched q 1
	. s matched=$$m61("Pe,Se,B<D,F<BF","a27")
	;	
	i 'fe,'be,ne,tbuild'="",tflat="",$$equiv^UPRNU(tbuild,flat_" "_build) d  i matched q 1
	. s matched=$$m61("Pe,Sd,Ne,B>FB,F>B","a34")
	;	
	i fe,'be,'ne,'se,tbuild'="",tbno'="",tstreet'="",street="",bno="",$$equiv^UPRNU(tbuild,build) d  q 0
	. s matchrec="Pe,Sd,Nd,Be,Fe",alg="a37"
	. d probable
	;	
	i 'fe,'be,'ne,se,tdepth=build,tbno_" "_tflat=flat d  q 0
	. s matchrec="Pe,Se,N>F,B<D,F<NF",alg="a44" d probable
	i 'fe,'be,'ne,se,$tr(tflat,"-","/")=flat,tbno'="",$p(build," ",$l(build," "))=tbno d  q 0
	. s matchrec="Pe,Se,N<B,B<Np,Fe",alg="a45"
	. d probable
	;	
	i fe,be,'ne,se,tbno?1n.n1"s",$TR(tbno,"Ss",55)=bno d  q 0
	. s matchrec="Pe,Se,Nl,Be,Fe",alg="48"
	. d probable
	;	
	;	
	i 'fe,'be,ne,se,tbuild'="",flat=tbuild,street="",build=tloc d  q 0
	. s matchrec="Pe,Se,Ne,B<L,F<B",alg="55"
	. d probable
	;
	;
	;
	;	
	i 'fe,'be,ne,se,build=tloc,tbuild'="",thouse=tbuild,$D(^UPRNS("HOUSE",$$tr^UPRNL(flat,"the ",""))) D  q 0
	. s matchrec="Pe,Se,Ne,B<L,Fp",alg="63"
	. d probable
	i 'fe,'be,ne,se,tloc_" "_tbuild=flat d  q 0
	. s matchrec="Pe,Se,Ne,Bi<F<LB",alg="a64"
	. d possible
	;	
	i 'fe,'be,ne,se,$$MPART^UPRNU(tbuild,flat),build=tloc,street="" d  q 0
	. S matchrec="Pe,Se,Ne,B<L,F<Bp",alg="a67"
	. d possible
	;
	i 'fe,'be,ne,se,tflat?1l.l,flat="",tbuild="",bno="",street="",tloc=loc!(tloc=town),$$equiv^UPRNU(tflat,build,5,3) d  q 0
	. s matchrec="Pe,Se,Ne,B<Fl,F>B",alg="a69"
	. d possible
	i 'fe,'be,'ne,se,tflat?1l.l,tbno'="",tbno=flat,tbuild="",bno="",street="",tloc=loc!(tloc=town),$$equiv^UPRNU(tflat,build,5,3) do  i matched q 1
	. s matched=$$m61("Pe,Se,N<F,B<F,F<N","a90")
	;	
	i 'fe,'be,ne,se,$tr(tflat,"-. ")=$tr(flat,"-. "),$$MPART^UPRNU(tbuild,build) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,Bp,Fp","a74")
	i fe,'be,'ne,'se,street'="",tstreet'="",tflat'="",tbuild'="",$$equiv^UPRNU(tbuild,build) d  q 0
	. s matchrec="Pe,Sid,Ni,Bl,Fe",alg="a75"
	. d possible
	;	
	i 'fe,'be,ne,se,$tr(tflat,"-. ")=$tr(flat,"-. "),$tr(tflat,"-. ")*1>100  d  q 0
	. s matchrec="Pe,Se,Ne,Bi,Fe",alg="a78"
	. d possible
	;	
	;	
	i 'fe,'be,'ne,se,$$parse(tflat,tbuild,tbno,flat,bno) d  q 0
	. s matchrec="Pe,Se,N<Bp,B>N,F<NFp",alg="a86"
	. d possible
	i 'fe,'be,'ne,se,tbno'="",tbuild'="",tbuild_" "_tbno=build,tflat=bno d  i matched q 1
	. s matched=$$m61("Pe,Se,N<F,B<BN,F>N","a92")
	;	
	i 'fe,be,'ne,se,tflat="",flat'="",tbno'="",bno="",tbno=flat,tbuild=build d  q 0
	. s matchrec="Pe,Se,N>F,Be,F<N",alg="a95"
	. d probable
	i ne,'se,'fe,'be,tdepth=street,depth="",tbuild="",flat="",$d(^UPRNS("TOWN",tstreet)) d  i matched q 0
	. i tflat?1l.l,$$equiv^UPRNU(tflat,build) d
	. . s matched=$$m61("Pe,Se,Ne,Bl,Fe","a116")
	;	
	i fe,ne,'be,'se,street="",town'="",tloc=town,depth=tdepth,build'="",$$equiv^UPRNU(build,tbuild) d
	. s matchrec="Pe,Si,Ne,Bl,Fe",alg="a119"
	. d probable
	;	
	i 'fe,'ne,se,'be,flat="",bno="" d  i matched q 1
	. i build?1n.n1"/"1n.n d
	. . i $p(build,"/")=tbno,$$flateq^UPRNU(tflat,$p(build,"/",2)) d
	. . . s matched=$$m61("Pe,Se,Ne,be,Fe","a125")
	i 'fe,'be,se,ne,flat="",tbuild="",$$flateq^UPRNU(tflat,build) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,B<Fl,F>B","a126")
	i 'fe,be,'ne,se,tflat?1n.n1"/"1n.n d  i matched q 1
	. i $p(tflat,"/")=bno,$p(tflat,"/",2)=flat d
	. . s matchrec="Pe,Se,N<F,Be,Fe",alg="a127" d probable
	i 'fe,'be,'se,ne,tflat?1n.n1"/"1n.n,flat="",build=tflat,street=tbuild d
	. s matchrec="Pe,S<B,Ne,B<F,Fe",alg="a128" d probable
	i 'fe,'be,ne,se,tbuild'="",tflat'="",build'="",flat'="",$$equiv^UPRNU(tbuild_" "_tflat,build_" "_flat) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,Bl,Fl","a129")
	i 'fe,'se,ne,'be,tflat'="",flat="",tflat=build,tstreet="",tbuild'="",$$equiv^UPRNU(tbuild,street) d  i matched q 1
	. s matched=$$m61("Pe,S<B,Ne,B>S,F>B","a130")
	i 'fe,be,ne,'se,bno'="",$$flateq^UPRNU(tflat,flat),$$equiv^UPRNU(tstreet,street,8,2) d
	. s matchrec="Pe,Sp,Ne,Be,Fe",alg="a135"
	. d probable
	;	
	i street=tstreet,bno="",build=tbno,tbuild="",tflat[" " s matched=$$match61x() i matched q 1
	;	
	I tbuild=street,tbuild'="" D m61d i matched q 1
	i flat="",tflat'="",tflat=build,tbno=bno,tstreet=street s matchrec="Pe,Se,Ne,B<F,F>B",alg="z" s matched=$$m61set() q 1 ;ABP missing house name
	i 'fe,se,'ne,'be,build?1n.n1l,tbno?1n.n,bno="",tbno*1=(build*1),$G(^UPRNS("SCOTLEVEL",tflat))=$p(build,build*1,2) d  I matched Q 1
	. s matched=$$m61("Pe,Se,N>B,B<FN,F>B","a122")
	;	
	i 'fe,be,se,ne,flat'="",tflat'="",$$flateq^UPRNU(tflat,flat) d  i matched q 1
	. s matched=$$m61("Pe,Se,Ne,Be,Fe","a123")
	;		
	q 0
	;	
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
parse(tflat,tbuild,tbno,flat,bno) ;
	n same
	s same=0
	i $p(flat," ")=tbno d
	. i $D(^UPRNS("SCOTFLOORSIDE",tflat,$p(flat," ",2,4))) d
	. . i $p(tbuild," ")=bno d
	. . . s same=1
	q same
house(text)	;
	i $D(^UPRNS("HOUSE",text)) q text
	q ""	
	;
m61(matchrec,alg) ;
	q $$m61set()			
m61set()	;
	s $p(ALG,"-",2)="match61"_alg
	q $$set^UPRN(uprn,table,key,1);	
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
	;
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