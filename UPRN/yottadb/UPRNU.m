UPRNU ;Library functionset for UPRN matching [ 2023]
	;
csv(rec)  ;Converts a csv record to tab seperated
	s new="",quote=0
	for i=1:1:$l(rec) d
	. s char=$e(rec,i)
	. i char="," d  Q
	. . if 'quote d
	. . . s new=new_$c(9)
	. . e  d
	. . . s new=new_char
	. if char="""" d  Q
	. . if quote s quote=0
	. . else  s quote=1
	. s new=new_char
	q new
	;	
area(post)         ;
	n area,done
	s area="",done=0
	f i=1:1:$l(post) d  q:done
	. i $e(post,i)?1n s done=1 q
	. s area=area_$e(post,i)
	q area
district(post)       ;returns post code district
	n (post)
	s outward=$e(post,1,$l(post)-3)
	s area="",done=0
	f i=1:1:$l(outward) d  q:done
	. i $e(outward,i)?1n s done=1 q
	. s area=area_$e(outward,i)
	s district=area_$p(outward,area,2,10)
	q district
	;	
	;	
	;	
	;	
islevel(uprn,vertical)       ;
	n (uprn,vertical)
	s level=$G(^UPRN("L",uprn)) i level="" q 0
	i $p(vertical," floor")=level q 1
	i vertical=(level_"s") q 1
	i $$tr^UPRNL(vertical,"floor ","")=level q 1
	i $$tr^UPRNL(vertical,"floors ","")=level q 1
	q 0
vertok(tflat,flat) ;Vertical match
	n (tflat,flat)
	s tflat=$$tr^UPRNL(tflat," flat","")
	s flat=$$tr^UPRNL(flat," flat","")
	i tflat=flat q 1
	i $D(^UPRNS("VERTICALSX",flat,tflat)) q 1
	s matched=0
	i tflat?1n.n1" "1l.e d
	. s fnum=$p(tflat," ")
	. s vertical=$p(tflat," ",2,10)
	. i $d(^UPRNS("FLOOR",vertical)) d
	. . i flat=fnum s matched=1
evok q matched
	;	
ISSTRNO(adstreet) 
	if adstreet?1n.n1" "1l1" "
	if adstreet?1n.n1" "1l1" ".l.e q 3
	if adstreet?1n.n1" "1l.e q 2
	if adstreet?1n.n1l1" "1l.e q 2
	if adstreet?1n.n1"-"1n.n1" ".l.e q 2
	if adstreet?1n.n.l1"-"1n.n.l1" ".l.e q 2
	if adstreet?1n.n1" "1n.n1" ".e q 3
	q 0
bsuff(bno,tflat,combine)   ;
	n (bno,tflat,combine)
	k combine
	i $D(^UPRNS("FLOOR",tflat)) d
	. s suff=""
	. for  s suff=$O(^UPRNS("FLOOR",tflat,suff)) q:suff=""  d
	. . I suff'?1l q
	. . s combine(bno_suff)=""
	q
	;	
Mflat(flat,adflat,levensh)   ;
	n leftover,matched
	set matched=0
	if $p(flat," ",1,$l(adflat," "))=adflat d
	. set leftover=$p(flat,adflat_" ",2)
	. if levensh>1,((leftover?1n)!(leftover?1l)) d
	. . S SUBFLATI=1
	. . set matched=1
	if $p(adflat," ",1,$l(flat," "))=flat d
	. set leftover=$p(adflat,flat_" ",2)
	. if levensh>1,((leftover?1n)!(leftover?1l)) d
	. . S SUBFLATD=1
	. . set matched=1
	S flat=$$flat(flat)
	set adflat=$$flat(adflat)
	if flat=adflat q 1
	I adflat?1n.n,flat?1n.n i (adflat*1)=(flat*1) q 1
	if levensh>1 d
	. if flat*1=($P(adflat," ")*1) d
	. . set SUFFIGNORE=1
	. . set matched=1
	. if adflat*1=($p(flat," ")*1) d
	. . S SUFFDROP=1
	. . set matched=1
	q matched
getno(paos,paosf,paoe,paoef) ;
	;REturnset street number or range
	n numb
	set numb=""
	if paos'="" d
	. set numb=paos_paosf
	. if paoe'="" d
	. . set numb=numb_"-"_paoe_paoef
	q numb
getflat(saos,saosf,saoe,saoef,saot)    ;
	;Returnset flat number or range
	n flat
	set flat=""
	if saot'="" do  q flat
	. set flat=saot
	. if saos'="" d
	. . set flat=flat_" "_(saos_saosf)
	. . if saoe'="" d
	. . . set flat=flat_"-"_(saoe_saoef)
	if saos'="" do  q flat
	. set flat=(saos_saosf)
	. if saoe'="" d
	. . set flat=flat_"-"_saoe_saoef
	q flat
	;
	;	
GETPOST(uprn)       ;
	;
	n mkey,mrec
	set mkey=$O(^UPRN("DPA",uprn,""))
	if mkey="" q ""
	set mrec=^UPRN("DPA",uprn,mkey)
	q $p(mrec,"~",9)
	;
ADDPA(uprn,key,address)    ;
	;
	s rec=^UPRN("DPA",uprn,key)
	s flat=$p(rec,"~",1)
	s build=$p(rec,"~",2)
	s number=$p(rec,"~",3)
	s depth=$p(rec,"~",4)
	s street=$p(rec,"~",5)
	s deploc=$p(rec,"~",6)
	s loc=$p(rec,"~",7)
	s town=$p(rec,"~",8)
	s post=$p(rec,"~",9)
	s org=$p(rec,"~",10)
	d GETDPA(flat,build,number,depth,street,deploc,loc,town,post,org,.address)
	q
GETDPA(flat,build,number,depth,street,deploc,loc,town,post,org,apaddres) 
	;Returnset DPA details
	set apaddress("flat")=flat
	set apaddress("building")=build
	set apaddress("number")=number
	set apaddress("depth")=depth
	set apaddress("street")=street
	set apaddress("deploc")=deploc
	set apaddress("locality")=loc
	set apaddress("town")=town
	set apaddress("postcode")=post
	set apaddress("org")=org
	set apaddress=apaddress("flat")_" "_apaddress("building")_","_apaddress("number")_" "_" "_apaddress("depth")_" "_apaddress("street")_","_apaddress("deploc")_" "_apaddress("locality")_","_post
	set apaddress=$$tr^UPRNL(apaddress,"  "," ")
	q
ANYADR(uprn)       ;Returns an adress stringfrom a uprn
	n q,rec
	s q=$q(^UPRN("U",uprn))
	s rec=@q
	q $tr(rec,"~",",,")
	;	
	q
	;	
GETABP(uprn,table,key,flat,build,bno,depth,street,deploc,loc,town,post,org)       ;
	;Returns address variables from UPRN record
	n rec,status
	s rec=^UPRN("U",uprn,table,key,"O")
	d getfields
	Q  
	;	
GETADR(uprn,table,key,flat,build,bno,depth,street,deploc,loc,town,post,org)       ;
	;Returns address variables from UPRN record
	n rec,status
	s rec=^UPRN("U",uprn,table,key)
	d getfields
	Q 
getfields ; 
	s flat=$p(rec,"~",1)
	s build=$p(rec,"~",2)
	s bno=$p(rec,"~",3)
	s depth=$p(rec,"~",4)
	s street=$p(rec,"~",5)
	s deploc=$p(rec,"~",6)
	s loc=$p(rec,"~",7)
	s town=$p(rec,"~",8)
	s post=$p(rec,"~",9)
	s org=$p(rec,"~",10)
	q
ADLPI(uprn,key,address) 
	n rec
	s rec=^UPRN("LPI",uprn,key)
	s saos=$p(rec,"~",1)
	s saosf=$p(rec,"~",2)
	s saoe=$p(rec,"~",3)
	s saoef=$p(rec,"~",4)
	s saot=$p(rec,"~",5)
	s paos=$p(rec,"~",6)
	s paosf=$p(rec,"~",7)
	s paoe=$p(rec,"~",8)
	s paoef=$p(rec,"~",9)
	s paot=$p(rec,"~",10)
	s lpstr=$p(rec,"~",11)
	D GETLPI(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,lpstr,uprn,.address)
	q
	;	
GETLPI(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,lpstr,uprn,apaddress) ;
	;Returns LPI fields in address object
	k apaddress
	S lpdes="",lploc="",lptown=""
	if lpstr'="" d
	. I $D(^UPRN("LPSTR",lpstr)) d
	. . set lpdes=$p(^UPRN("LPSTR",lpstr),"~")
	. . set lploc=$p(^UPRN("LPSTR",lpstr),"~",2)
	. . set lptown=$p(^UPRN("LPSTR",lpstr),"~",3)
	. S lpdes=$tr(lpdes,"'.,")
	set apaddress("flat")=$$getflat(saos,saosf,saoe,saoef,saot)
	set apaddress("building")=paot
	set apaddress("number")=$$getno(paos,paosf,paoe,paoef)
	set apaddress("depth")=""
	set post=$p(^UPRN("U",uprn),"~",2)
	set apaddress("street")=lpdes
	set apaddress("deploc")=""
	set apaddress("locality")=lploc
	set apaddress("town")=lptown
	set apaddress("postcode")=post
	set apaddress=apaddress("flat")_" "_apaddress("building")_","_apaddress("number")_" "_apaddress("street")_","_apaddress("locality")_","_post
	q
	;
stripr(text)    ;
	n i,word
	f i=1:1:$l(text," ") d
	. s word=$p(text," ",i)
	. q:word=""
	. I $D(^UPRNS("ROAD",word)) d
	. . s text=$p(text," ",1,i-1)
	q text
roadmiss(test,tomatch) 
	n matched
	s matched=0
	i $l(tomatch," ")<2 q 0
	i tomatch="" q 0
	i $D(^UPRNS("ROAD",$p(tomatch," ",$l(tomatch," ")))) d
	. i $p(tomatch," ",1,$l(tomatch," ")-1)=test s matched=1
	q matched
contains(depth,street,tstreet) 
	i depth=""!(street="")!(tstreet="") q 0
	;Can discovery street contain both street and depth
	i tstreet[depth,tstreet[street q 1
	q 0
fuzflat(test,tomatch)        ;Tests a fuzzy flat
	i test=tomatch q 1
	i (" "_tomatch_" ")[(" "_test_" ") q 1
	i (" "_test_" ")[(" "_tomatch_" ") q 1
	q 0
mcount(test,tomatch) 
	i test="",tomatch="" q 1
	n i,count
	s count=0
	f i=1:1:$l(test," ") d
	. i $p(test," ",i)=$p(tomatch," ",i) s count=count+1
	q count
partial(test,tomatch)        ;Partial multiword
	n matched
	s matched=0
	d swap(.test,.tmatch)
	d drop(.test,.tomatch)
	i $l(test," ")>1 d
	. i $l(tomatch," ")>$l(test," ") d
	. . i $p(tomatch," ",1,$l(test," "))=test d
	. . . s matched=1
	Q matched
approx(test,tomatch)         ;goes for a very approximatr match
	i $l(test," ")'=$l(tomatch," ") q 0
	n i,count,matched
	s count=0,matched=0
	f i=1:1:$l(test," ") d
	. i $p(test," ",i)=$p(tomatch," ",i) s count=count+1
	i 'count q 0
	i $l(test," ")/count<2 q 0
	f i=1:1:$l(test," ") d
	. i $e($p(test," ",i),1,3)=$e($p(tomatch," ",i),1,3) d
	. . s matched=1
	q matched
matchbld(build,tbuild)       ;
	n test,var,var1,suffix
	d drop(.build,.tbuild)
	i build=tbuild q 1
	i $l(build)<$l(tbuild) d
	. s var="build",var1="tbuild"
	e  d
	. s var="tbuild",var1="build"
	i $D(^UPRNS("DROPSUFFIX",$e(@var1,$l(@var)+2,$l(@var1)))) q 1
	q 0
	;	
equiv(test,tomatch,min,force,droproad)          ;Swaps drops and levenshtein
	i $D(^UPRNW("SFIX",tomatch,test)) q 1
	N otest,otomatch
	s otest=test,otomatch=tomatch
	i $p($tr(test," "),"(")=$p($tr(tomatch," "),"(") q 1
cwm i $l(test)>7 i $e($tr(test," "),1,$l($tr(test," "))-1)=$e($tr(tomatch," "),1,$l($tr(tomatch," "))-1) q 1
	d swap(.test,.tomatch)
	d drop(.test,.tomatch)
	i $d(^UPRNS("TRANSLATE",test,tomatch)) q 1
	I $D(^UPRNS("TRANSLATE",tomatch,test)) q 1
	i $$translate(test,tomatch)  q 1
	d welsh(.test,.tomatch)
	i $g(droproad) d
	. i test[" " d
	. . i $D(^UPRNS("ROAD",$p(test," ",$l(test," ")))) d
	. . . s test=$p(test," ",0,$l(test," ")-1)
	. . i droproad=2 I $D(^UPRNS("HOUSE",$p(test," ",$l(test," ")))) d
	. . . s test=$p(test," ",0,$l(test," ")-1) 
	. i tomatch[" " d
	. . i $D(^UPRNS("ROAD",$p(tomatch," ",$l(tomatch," ")))) d
	. . . s tomatch=$p(tomatch," ",0,$l(tomatch," ")-1)
	. . i droproad=2 I $D(^UPRNS("HOUSE",$p(tomatch," ",$l(tomatch," ")))) d
	. . . s tomatch=$p(tomatch," ",0,$l(tomatch," ")-1) 
	s tomatch=$$tr^UPRNL(tomatch,"eaux","eux")
	i $tr(test," ")=$tr(tomatch," ") q 1
	i $tr(test,"-"," ")=tomatch q 1
	i $tr(tomatch,"-"," ")=test q 1
	set test=$$tr^UPRNL(test,"ei","ie")
	set tomatch=$$tr^UPRNL(tomatch,"ei","ie")
	i $$eqlev(test,tomatch) q 1
	S otest=test
	s otomatch=tomatch
	set test=$$dupl(test)
	set tomatch=$$dupl(tomatch)
	i test'=otest!(otomatch'=tomatch) i $$eqlev(test,tomatch) q 1
	q 0
translate(test,tomatch) ;
	i test="" q 0
		n translate,i
		s translate=1
	f i=1:1:$l(test," ") d  q:(translate=0)
	. i '$d(^UPRNS("TRANSLATE",$p(test," ",i),$p(tomatch," ",i))) s translate=0
	q translate	
eqlev(test,tomatch)          ;Equivalent by levenshtein test
	i $tr(test," ")=$tr(tomatch," ") q 1
	i $e(test)?1n,$e(tomatch)?1l q 0
	i $e(tomatch)?1n,$e(test)?1l q 0
	i $$levensh($tr(test," "),$tr(tomatch," "),$g(min,10),$g(force)) q 1
	s test=otest,tomatch=otomatch
	i test'["ow" q 0
	S test=$$tr^UPRNL(test,"ow","a")
	i $$levensh($tr(test," "),$tr(tomatch," "),$g(min,10),$g(force)) q 1
	q 0
	;	
welsh(test,tomatch)          ;Converts welsh language
	I test["clos ",tomatch[" close" d
	. s test=$tr($p(test," ",2,10)," ")
	. s tomatch=$tr($p(tomatch," ",1,$l(tomatch," ")-1)," ")
	I $E(test)="y" D
	. I $e(test,2,50)=tomatch s test=tomatch
	i $E(tomatch)="y" D
	. I $e(tomatch,2,50)=test s tomatch=test
	Q
	;	
levensh(s,t,min,force) 
	;Levenshtein distance algorithm
	;s and t are the two terms
	;mininum is the minimum length acceptable for a match if less than 10
	;force is when you want to force a minimum distance less than defaults
	;	
	;	
	n matched,d,m,n,result,i,j,result
	set matched=0
	s s=$e(s,1,20)
	s t=$e(t,1,20)
	n dif,m,n,from,to
	set m=$l(s)
	set n=$l(t)
	set min=$g(min,4)
	if m<min D  q matched
	. if s=t set matched=1
	f i=0:1:m d
	. f j=0:1:n d
	. . set d(i,j)=0
	f i=1:1:m set d(i,0)=i
	f j=1:1:n set d(0,j)=j
	F j=1:1:n d
	. f i=1:1:m d
	. . if $e(s,i)=$e(t,j) set cost=0
	. . e  set cost=1
	. . set d(i,j)=$$min(d(i-1,j)+1,d(i,j-1)+1,d(i-1,j-1)+cost)
	set result=d(m,n)
res I result=0 q 1
	if $g(force),result>force q 0
	if $g(force),result'>force q 1
	if result=1 Q 1
	if result=2 do  q matched
	. I m<10 s matched=0 q
	. I m<min s matched=0 q
	. s matched=result q
	if result=3,m>9 Q 1
	Q 0
OK ;
	set matched=1
	Q
	;	
min(one,two,three)         ;
	n order
	set order(one)="",order(two)="",order(three)=""
	q $o(order(""))
	;
soundex(phrase)    ;
	n new,soundex,i,char,lchar,digit,ldigit,hw
	set phrase=$TR(phrase," ")
	set soundex=$e(phrase)
	set new="",lchar=""
	set ldigit=0,hw=""
	f i=1:1:$l(phrase) d
	. set char=$e(phrase,i)
	. if "aeiouyhw"[char set hw=char q
	. set digit=$s("bfpv"[char:1,"cgjkqsxz"[char:2,"dt"[char:3,"l"[char:4,"mn"[char:5,"r"[char:6,1:"")
	. if digit=ldigit,(hw="h")!(hw="w") q
	. if digit=ldigit,hw="" q
	. set soundex=soundex_digit
	. set hw="",ldigit=digit
	q $e(soundex_"00",1,4)
correct(text,tomatch)      ;
	n word,i,saint
	s text=$$tr^UPRNL(text,"lll","ll")
	i $p(text," ",1,2)="known as" d
	. s text=$p(text," ",3,20)
	f i=1:1:$l(text," ") d
	. set word=$p(text," ",i)
	. q:word=""
	. I $D(^UPRNS("CORRECT",word)) d
	. . i word="st" d  q
	. . . s saint="st "_$p(text," ",i+1)
	. . . i $d(^UPRNX("X.STR",saint)) q
	. . . I $O(^UPRNX("X.STR",saint))[saint q
	. . . s $p(text," ",i)="street"
	. . if $g(tomatch)'="" if (" "_tomatch_" ")[(" "_word_" ") d
	. . . set $p(text," ",i)=^UPRNS("CORRECT",word)
	. . e  d
	. . . set $p(text," ",i)=^UPRNS("CORRECT",word)
	s text=$$tr^UPRNL(text," & "," and ")
	q text
swap(text,tomatch)         ;Swaps a word in text
	n word,swapto,swapped
	set word="",swapped=0
	for  set word=$O(^UPRNS("SWAP",word)) q:word=""  d
	. if (" "_text_" ")[(" "_word_" ") d
	. . set swapto=^UPRNS("SWAP",word)
	. . set text=$p(text,word,1)_swapto_$p(text,word,2,20)
	. I $G(tomatch)="" q
	. if (" "_tomatch_" ")[(" "_word_" ") d
	. . set swapto=^UPRNS("SWAP",word)
	. . set tomatch=$p(tomatch,word,1)_swapto_$p(tomatch,word,2,20)
	q
flatsuff(flat,num)   ;Matches a suffix e.g. 25a with the number  e.g. 1
	n suff
	s suff=$p(flat,flat*1,2)
	i suff="" q 0
	i $G(^UPRNS("FLATSUFNUM",suff))=num q 1
	q 0
	;	
	;
SETSWAPS ;
fs f i=1:1:9 S ^UPRNS("FLATSUFNUM",$c(96+i))=i
fs1 f i=1:1:9 S ^UPRNS("FLATNUMSUF",i)=$c(96+i)
	;	
	K ^UPRNS("ROAD")
	S ^UPRNS("NUMWORD",7)="seven"
	K ^UPRNS("BESTFIT")
	K ^UPRNS("CITY")
	K ^UPRNS("CORRECT")
	K ^UPRNS("DROP")
	K ^UPRNS("SWAP")
	K ^UPRNS("FLAT")
	K ^UPRNS("VERTICALS")
	S ^UPRNS("DROPSUFFIX","building")=""
	S ^UPRNS("TRANSLATE","llew","red")=""
	S ^UPRNS("TRANSLATE","coch","lion")=""
	S ^UPRNS("TRANSLATE","red","llew")=""
	S ^UPRNS("TRANSLATE","lion","coch")=""
	n fix
	s fix=1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bf,Ff" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Np,Be,F=N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,N>Ff,Be,Ff" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ni,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ni,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nd,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nd,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,B>F,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,B>F,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fvv" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nf,Be,F>N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nf,Be,Fp>N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nf,Bd,F>N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nf,Bd,Fp>N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fo" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fv" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fpv" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fp" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fp1" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fp2" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bp,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bp,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bp,Fp" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pl,Se,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pl,Se,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bd,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bd,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Nd,Be,F>N" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bd,Fl" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,N>B,Bf,F>Be" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bi,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bi,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bi,Fp" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fs" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Be,Fc" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Sp,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Sp,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ns,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Se,Ne,Bi,Fa" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Si,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,Si,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pl,Se,Ne,Bp,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pl,Se,Ni,Bl,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pl,Se,Ni,Bl,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Bd,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Bd,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Be,Fev" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pp,Se,Ne,Be,Fe" s fix=fix+1
	S ^UPRNS("BESTFIT",fix)="Pe,S<B,N<F,B>S,F>N" s fix=fix+1
	K ^UPRNS("FLOOR")
	S ^UPRNS("FLOOR","basement","a")=""
	S ^UPRNS("FLOOR","ground floor","a")=""
	S ^UPRNS("FLOOR","first floor","b")=""
	S ^UPRNS("FLOOR","basement",0)=""
	S ^UPRNS("FLOOR","ground floor",1)=""
	S ^UPRNS("FLOOR","first floor",2)=""
	S ^UPRNS("FLOOR","second floor",3)=""
	S ^UPRNS("FLOOR","second floor","c")=""
	S ^UPRNS("FLOOR","third floor",4)=""
	S ^UPRNS("FLOOR","third floor","d")=""
	S ^UPRNS("VERTICALS","upper floors")="high"
	d crossv("upper","top")
	D crossv("ground","ground")
	D crossv("first","first")
	d crossv("basement","basement")
	d crossv("upper floors","upper floor")
	;	
	d crossv("second","second")
	;
	S ^UPRNS("GENERIC","the flats")=""	
	S ^UPRNS("VERTICALS","top")="high"
	S ^UPRNS("VERTICALS","top flat")="high"
	S ^UPRNS("VERTICALS","upper floors","first floor")="h"
	S ^UPRNS("VERTICALS","upper floors","second floor")="h"
	S ^UPRNS("VERTICALS","upper floors","third floor")="h"
	S ^UPRNS("VERTICALS","upper floor")="high"
	S ^UPRNS("VERTICALS","upper floor","first floor")="h"
	S ^UPRNS("VERTICALS","upper floor","second floor")="h"
	S ^UPRNS("VERTICALS","upper floor","third floor")="h"
	S ^UPRNS("VERTICALS","pt ground/1st floor")="low"
	S ^UPRNS("VERTICALS","ground part & first floor")="low"
	S ^UPRNS("VERTICALS","ground part and first floor")="low"
	S ^UPRNS("VERTICALS","first and second floor flat")="low"
	S ^UPRNS("VERTICALS","first & second floor flat")="low"
	s ^UPRNS("VERTICALS","basement & ground floor")="low"
	s ^UPRNS("VERTICALS","basement & ground floors")="low"
	s ^UPRNS("VERTICALS","basement & part ground floor")="low"
	s ^UPRNS("VERTICALS","basement and ground floor")="low"
	s ^UPRNS("VERTICALS","basement and ground floors")="low"
	s ^UPRNS("VERTICALS","basement and part ground floor")="low"
	d setvert("fourth and fifth","high")
	S ^UPRNS("VERTICALS","4th & 5thfloor")="high"
	S ^UPRNS("VERTICALS","4th and 5thfloor")="high"
	S ^UPRNS("VERTICALS","first and second floor")="high"
	S ^UPRNS("VERTICALS","1st and 2nd floor")="high"
	S ^UPRNS("VERTICALS","1st & 2nd floor")="high"
	S ^UPRNS("VERTICALS","rear ground floor")="low"
	S ^UPRNS("VERTICALS","first second and third floors")="high"
	S ^UPRNS("VERTICALS","first second and third floor")="high"
	S ^UPRNS("VERTICALS","first second & third floors")="high"
	S ^UPRNS("VERTICALS","first second & third floor")="high"
	S ^UPRNS("VERTICALS","first floor front")="high"
	S ^UPRNS("VERTICALS","first floor rear")="high"
	S ^UPRNS("VERTICALS","ground first and second floors")="low"
	S ^UPRNS("VERTICALS","ground first & second floors")="low"
	S ^UPRNS("VERTICALS","ground front floor and first floor")="low"
	S ^UPRNS("VERTICALS","ground front floor & first floor")="low"
	S ^UPRNS("VERTICALS","ground rear floor and basement")="low"
	S ^UPRNS("VERTICALS","ground rear floor & basement")="low"
	S ^UPRNS("VERTICALS","above")="high"
	S ^UPRNS("VERTICALS","pt ground-1st floor")="low"
	s ^UPRNS("VERTICALS","ground")="low"
	S ^UPRNS("VERTICALS","1st-2nd-3rd")="high"
	S ^UPRNS("VERTICALS","lower flat")="low"
	S ^UPRNS("VERTICALS","upper flat")="high"
	S ^UPRNS("VERTICALS","top flat")="high"
	S ^UPRNS("VERTICALS","lower")="low"
	S ^UPRNS("VERTICALS","upper")="high"
	S ^UPRNS("VERTICALS","top")="high"
	S ^UPRNS("VERTICALS","b-ment and ground floor")="low"
	S ^UPRNS("VERTICALS","b-ment & ground floor")="low"
	S ^UPRNS("VERTICALS","1st2nd and 3rd floors")="high"
	S ^UPRNS("VERTICALS","1st2nd and third floors")="high"
	S ^UPRNS("VERTICALS","1st2nd & 3rd floors")="high"
	S ^UPRNS("VERTICALS","1st2nd & third floors")="high"
	f ew="east","west","flat" d
	. S ^UPRNS("VERTICALS","first floor "_ew)="low"
	. S ^UPRNS("VERTICALS","second floor "_ew)="low"
	. S ^UPRNS("VERTICALS","third floor "_ew)="high"
	. s ^UPRNS("VERTICALS","upper floor "_ew)="high"
	. s ^UPRNS("VERTICALS","top floor "_ew)="high"
	. s ^UPRNS("VERTICALS","ground floor "_ew)="high"
	S ^UPRNS("VERTICALS","first floor")="low"
	S ^UPRNS("VERTICALS","second floor")="low"
	S ^UPRNS("VERTICALS","third floor")="high"
	S ^UPRNS("VERTICALS","1st-2nd-3rd floors")="high"
	S ^UPRNS("VERTICALS","1st-2nd floors")="high"
	S ^UPRNS("VERTICALS","2nd and 3rd floors")="high"
	S ^UPRNS("VERTICALS","second and third floors")="high"
	S ^UPRNS("VERTICALS","first second and third floors")="high"
	S ^UPRNS("VERTICALS","first and second floors")="high"
	S ^UPRNS("VERTICALS","1st and 2nd floors")="high"
	S ^UPRNS("VERTICALS","first and second floors")="high"
	S ^UPRNS("VERTICALS","1st and 2nd floors")="high"
	S ^UPRNS("VERTICALS","2nd & 3rd floors")="high"
	S ^UPRNS("VERTICALS","second & third floors")="high"
	S ^UPRNS("VERTICALS","first second & third floors")="high"
	S ^UPRNS("VERTICALS","first & second floors")="high"
	S ^UPRNS("VERTICALS","1st & 2nd floors")="high"
	S ^UPRNS("VERTICALS","first & second floors")="high"
	S ^UPRNS("VERTICALS","1st & 2nd floors")="high"
	S ^UPRNS("VERTICALS","upper floor")="high"
	S ^UPRNS("VERTICALS","ground floor rear")="low"
	S ^UPRNS("VERTICALS","ground and 1st floors")="low"
	S ^UPRNS("VERTICALS","ground and first floors")="low"
	S ^UPRNS("VERTICALS","ground & 1st floors")="low"
	S ^UPRNS("VERTICALS","ground & first floors")="low"
	S ^UPRNS("VERTICALS","ground floor & basement")="low"
	S ^UPRNS("VERTICALS","ground floor and basement")="low"
	S ^UPRNS("VERTICALS","frst floor front")="low"
	S ^UPRNS("VERTICALS","top floor flat")="high"
	S ^UPRNS("VERTICALS","top floor")="high"
	S ^UPRNS("VERTICALS","top floors")="high"
	s ^UPRNS("VERTICALS","ground floor flat")="low"
	s ^UPRNS("VERTICALS","basement flat")="low"
	s ^UPRNS("VERTICALS","basement")="low"
	s ^UPRNS("VERTICALS","1st floor")="high"
	s ^UPRNS("VERTICALS","2nd floor")="high"
	s ^UPRNS("VERTICALS","1st floor flat")="high"
	s ^UPRNS("VERTICALS","2nd floor flat")="high"
	S ^UPRNS("VERTICALS","grd floor")="low"
	S ^UPRNS("VERTICALS","grnd floor")="low"
everts S ^UPRNS("VERTICALS","ground floor")="low"
	s ^UPRNS("FLOOR","1st",2)=""
	s ^UPRNS("FLOOR","2nd",3)=""
	s ^UPRNS("FLOOR","3rd",4)=""
	s ^UPRNS("FLOOR","6th",7)=""
	S ^UPRNS("FLOOR","4th",5)=""
	S ^UPRNS("FLOOR","5th",6)=""
	S ^UPRNS("FLOORNUM",1)="ground"
	S ^UPRNS("FLOORNUM",2)="first"
	S ^UPRNS("FLOORNUM",3)="Second"
	S ^UPRNS("FLOORNUM",0)="basement"
	S ^UPRNS("FLOORCHAR","a")="ground"
	S ^UPRNS("FLOORCHAR","b")="first"
	S ^UPRNS("FLOORCHAR","c")="Second"
	S ^UPRNS("FLOORCHAR","d")="third"
	S ^UPRNS("FLOORCHAR",$c(96))="basement"
	S ^UPRNS("CITY","london")=""
	set ^UPRNS("CORRECT","1st")="first"
	S ^UPRNS("CORRECT","bsemnt")="basement"
	S ^UPRNS("CORRECT","flaat")="flat"
	S ^UPRNS("CORRECT","flatt")="flat"
	S ^UPRNS("CORRECT","appartments")="apartments"
	S ^UPRNS("CORRECT","1st-2nd-3rd")="first second and third"
	S ^UPRNS("CORRECT","blk")="block"
	S ^UPRNS("CORRECT","hosp")="hospital"
	S ^UPRNS("CORRECT","bsmnt")="basement"
	S ^UPRNS("CORRECT","bsemt")="basement"
	S ^UPRNS("CORRECT","bsmt")="basement"
	S ^UPRNS("CORRECT","b-ment")="basement"
	S ^UPRNS("CORRECT","b-mnt")="basement"
	S ^UPRNS("CORRECT","ist")="first"
	S ^UPRNS("CORRECT","flr")="floor"
	S ^UPRNS("CORRECT","dwlg")="dwelling"
	S ^UPRNS("CORRECT","dwlgs")="dwellings"
	S ^UPRNS("CORRECT","vic")="victoria"
	S ^UPRNS("CORRECT","ldn")="london"
	S ^UPRNS("CORRECT","bsmt")="basement"
	S ^UPRNS("CORRECT","ter")="terrace"
	S ^UPRNS("CORRECT","flrs")="floor"
	S ^UPRNS("CORRECT","fl")="floor"
	S ^UPRNS("CORRECT","sq")="square"
	S ^UPRNS("CORRECT","mais")="maisonette"
	set ^UPRNS("CORRECT","bst")="basement"
	set ^UPRNS("CORRECT","2nd")="second"
	set ^UPRNS("CORRECT","3rd")="third"
	set ^UPRNS("CORRECT","6th")="sixth"
	S ^UPRNS("CORRECT","4th")="fourth"
	S ^UPRNS("CORRECT","5th")="fifth"
	set ^UPRNS("CORRECT","base")="basement"
	S ^UPRNS("CORRECT","almhouse")="almshouse"
	S ^UPRNS("CORRECT","bldg")="building"
	S ^UPRNS("CORRECT","bldgs")="buildings"
	S ^UPRNS("CORRECT","cosmopolitian")="cosmopolitan"
	S ^UPRNS("CORRECT","est")="estate"
	S ^UPRNS("CORRECT","crt")="court"
	S ^UPRNS("CORRECT","falt")="flat"
	S ^UPRNS("CORRECT","cres")="crescent"
	S ^UPRNS("CORRECT","flst")="flat"
	S ^UPRNS("CORRECT","fat")="flat"
	S ^UPRNS("CORRECT","fla")="flat"
	S ^UPRNS("CORRECT","gdns")="gardens"
	S ^UPRNS("CORRECT","grd")="ground"
	S ^UPRNS("CORRECT","grnd")="ground"
	S ^UPRNS("CORRECT","gnd")="ground"
	S ^UPRNS("CORRECT","fla1")="flat"
	S ^UPRNS("CORRECT","flalt")="flat"
	S ^UPRNS("CORRECT","flar")="flat"
	S ^UPRNS("CORRECT","flart")="flat"
	S ^UPRNS("CORRECT","flast")="flat"
	S ^UPRNS("CORRECT","hospit")="hospital"
	S ^UPRNS("CORRECT","rd")="road"
	S ^UPRNS("CORRECT","ci")="city"
	S ^UPRNS("CORRECT","apart")="apartment"
	S ^UPRNS("CORRECT","raod")="road"
	S ^UPRNS("SWAP","boat")="ferry"
	S ^UPRNS("SWAP","house")="building"
	S ^UPRNS("SWAP","mooring")="berth"
	S ^UPRNS("SWAP","johnson")="jonson"
	S ^UPRNS("SWAP","road")="street"
	S ^UPRNS("SWAP","apartments")="building"
	S ^UPRNS("SWAP","apartment")="building"
	S ^UPRNS("SWAP","nursing")="care"
	S ^UPRNS("SWAP","upstairs")="first"
	S ^UPRNS("SWAP","upper")="first"
	;	
	S ^UPRNS("CORRECT","cresent")="crescent"
	S ^UPRNS("CORRECT","sttreet")="street"
	S ^UPRNS("CORRECT","st")="street"
	S ^UPRNS("CORRECT","st","Except",1)=""
	S ^UPRNS("CORRECT","hse")="house"
	S ^UPRNS("CORRECT","hs")="house"
	S ^UPRNS("CORRECT","mans")="mansion"
	S ^UPRNS("CORRECT","apt")="apartment"
	S ^UPRNS("CORRECT","apts")="apartments"
	S ^UPRNS("CORRECT","gff")="ground floor"
	S ^UPRNS("CORRECT","ave")="avenue"
	S ^UPRNS("FLATEXTRA","studio")=""
	S ^UPRNS("FLATEXTRA","house")=""
	S ^UPRNS("FLAT","flat no")=""
	S ^UPRNS("FLAT","rooms")=""
	S ^UPRNS("FLAT","maisonette")=""
	S ^UPRNS("FLAT","flat number")=""
	S ^UPRNS("FLAT","flat")=""
	S ^UPRNS("FLAT","flats")=""
	S ^UPRNS("FLAT","flt")=""
	S ^UPRNS("FLAT","unit")=""
	S ^UPRNS("FLAT","room")=""
	S ^UPRNS("FLAT","apartment")=""
	S ^UPRNS("FLAT","apt")=""
	S ^UPRNS("FLAT","plot")=""
	;S ^UPRNS("FLAT","tower")=""
	S ^UPRNS("FLAT","falt")=""
	S ^UPRNS("FLAT","workshop")=""
	S ^UPRNS("DROP","lane ")=""
	S ^UPRNS("DROP","the ")=""
	S ^UPRNS("DROP","y ")=""
	S ^UPRNS("DROP","basement ")=""
	s ^UPRNS("DROP"," house")=""
	S ^UPRNS("DROP","moorings")=""
	S ^UPRNS("CORRECT","acenue")="avenue"
	F text="house","farm","cottage","manor","hall" d
	. s ^UPRNS("HOUSE",text)=""
	f text="villas","road","street","avenue","court","square","drive","way" d
	. S ^UPRNS("ROAD",text)=""
	f text="lane","grove","row","close","walk","causeway","park","place" d
	. S ^UPRNS("ROAD",text)=""
	f text="lanes","hill","plaza","green","rise","rd","terrace" d
	. S ^UPRNS("ROAD",text)=""
	S ^UPRNS("NUMBERS","one")=1
	S ^UPRNS("NUMBERS","two")=2
	S ^UPRNS("NUMBERS","three")=3
	f text="house","building","place","lodge","cottage","point" d
	. s ^UPRNS("BUILDING",text)=""
	f text="court","close","mews" d
	. S ^UPRNS("COURT",text)=""
	s ^UPRNS("COUNTY","middlesex")=""
	S ^UPRNS("TOWN","neasden")=""
	S ^UPRNS("TOWN","wembley")=""
	S ^UPRNS("TOWN","harlesden")=""
	S ^UPRNS("TOWN","poplar")=""
	;
	;	
	q
setvert(vertical,qual)       ;
	S ^UPRNS("VERTICALS",vertical)=qual
	S ^UPRNS("VERTICALS",vertical_" floor")=qual
	S ^UPRNS("VERTICALS",vertical_" floors")=qual
	i vertical["&" d  q
	. s vertical=$$tr^UPRNU(vertical,"&","and")
	. S ^UPRNS("VERTICALS",vertical)=qual
	. S ^UPRNS("VERTICALS",vertical_" floor")=qual
	. S ^UPRNS("VERTICALS",vertical_" floors")=qual
	i vertical["and" d  q
	. s vertical=$$tr^UPRNL(vertical,"and","&")
	. S ^UPRNS("VERTICALS",vertical)=qual
	. S ^UPRNS("VERTICALS",vertical_" floor")=qual
	. S ^UPRNS("VERTICALS",vertical_" floors")=qual
	q
crossv(var,var1)   ;cross reference vericals
	S ^UPRNS("VERTICALSX",var,var1)=""
	S ^UPRNS("VERTICALSX",var1,var)=""
	S ^UPRNS("VERTICALSX",var_" floor",var1_" floor")=""
	S ^UPRNS("VERTICALSX",var_" floors",var1_" floors")=""
	S ^UPRNS("VERTICALSX",var,var1_" floor")=""
	S ^UPRNS("VERTICALSX",var,var1_" floors")=""
	S ^UPRNS("VERTICALSX",var_" floor",var1)=""
	S ^UPRNS("VERTICALSX",var_" floors",var1)=""
	S ^UPRNS("VERTICALSX",var1_" floor",var_" floor")=""
	S ^UPRNS("VERTICALSX",var1_" floors",var_" floors")=""
	S ^UPRNS("VERTICALSX",var1,var_" floor")=""
	S ^UPRNS("VERTICALSX",var1,var_" floors")=""
	S ^UPRNS("VERTICALSX",var1_" floor",var)=""
	S ^UPRNS("VERTICALSX",var1_" floors",var)=""
	q
dropf(text)      ;Drops prefix word
	i $p(text," ")="the" q $p(text," ",2,20)
	q text
drop(text,tomatch) ;Dropset a first or middle word
	n word
	set word=""
	for  set word=$O(^UPRNS("DROP",word)) q:word=""  d
	. if text[word d
	. . set text=$p(text,word,1)_$p(text,word,2,20)
	. if tomatch[word d
	. . set tomatch=$p(tomatch,word,1)_$p(tomatch,word,2,20)
	q
	;	
flat(text) 
	n word
	I text="flat" q ""
	i text?1"no"1" ".e d
	. s text=$p(text," ",2,10)
	set word=""
	i text?1"flat"1n.n q $p(text,"flat",2,10)
	for  set word=$O(^UPRNS("FLAT",word)) q:word=""  d
	. if text[(word_" ") d
	. . set text=$p(text,word_" ",1)_$p(text,word_" ",2,20)
	i text'="0" for  q:($e(text)'="0")  s text=$e(text,2,50)
flatend ;Flat at end
	i $l(text," ")>1 i $d(^UPRNS("FLAT",$p(text," ",$l(text," ")))) q $p(text," ",1,$l(text," ")-1)
	q text
isflat(text) 
	n word,isflat
	i $p(text," ")="tower",$p(text," ",2)'?1n.n.e q 0
	set word="",isflat=0
	for  set word=$O(^UPRNS("FLAT",word)) q:word=""  do  q:isflat
	. if $p(text," ")=word set isflat=1
isfloor i text?1l.l1" ".e,$d(^UPRNS("FLOOR",text)) q 1
	q isflat
hasflat(text) 
	n word,hasflat
	set word="",hasflat=0
	for  set word=$O(^UPRNS("FLAT",word)) q:word=""  do  q:hasflat
	. if (" "_text_" ")[(" "_word_" ") set hasflat=1
	q hasflat
FLOOR(text)        ;
	if text["floor " q $p(text,"floor ",2)
	q text
PLURAL(text)       ;Removeset plurals
	n i,word
	f i=1:1:$l(text," ") d
	. set word=$p(text," ",i)
	. if $e(word,$l(word))="s" d
	. . set word=$e(word,1,$l(word)-1)
	. . q:word=""
	. . set $p(text," ",i)=word
	. . S PLURAL=1
	q text
getfront(text,tomatch,front,back)          ;Phrase contains phrase
	;front is the front part of the phrase
	s front=""
	i tomatch[(" "_text) d  q 1
	. s front=$p(tomatch," "_text,1)
	. s back=$p(tomatch," "_text,2)
	q 0
getback(text,tomatch,back)          ;Phrase contains phrase
	;front is the front part of the phrase
	i text="" q 0
	I $e(text,1,$l(tomatch))=tomatch d  q 1
	. S back=$$lt^UPRNL($p(text,tomatch,2,5))
	I $E(tomatch,1,$l(text))=text d  q 1
	. s back=$$lt^UPRNL($p(tomatch,text,2,5))
	q 0
MPART(test,tomatch,mincount)         ;
	;One word match only
	n matched,stest,stomatch
	s stest=$tr(test," ")
	s stomatch=$tr(tomatch," ")
	i $l(stest)>6 i $e(stomatch,1,$l(stest))=stest q 1
	i $l(stomatch)>6 i $e(stest,1,$l(stomatch))=stomatch q 1
	i $l(test," ")-$l(tomatch," ")>5 q 0
	d swap(.test,.tomatch)
	d drop(.test,.tomatch)
	set test=$$dupl(test)
	set tomatch=$$dupl(tomatch)
	set test=$$tr^UPRNL(test,"ei","ie")
	set tomatch=$$tr^UPRNL(tomatch,"ei","ie")
	set matched=0
	n i,j,ltest,lto,from,to,count,maxlen
	set ltest=$l(test," ")
	set lto=$l(tomatch," ")
	set from=$s(lto>ltest:"test",1:"tomatch")
	set to=$s(from="test":"tomatch",1:"test")
	set maxlen=$l(@to," ")
	set mincount=$g(mincount,maxlen-1)
	i mincount=0 s mincount=1
	set count=0
	f i=1:1:$l(@from," ") d
	. set word=$p(@from," ",i)
	. I word'="" I $D(^UPRNS("ROAD",word))!($D(^UPRNS("BUILDING",word))) q
	. f j=i:1:$l(@to," ") d
	. . set tword=$p(@to," ",j)
	. . i tword'="",$D(^UPRNS("ROAD",tword))!($d(^UPRNS("BUILDING",word))) q
	. . I $$levensh(word,tword) d
	. . . set count=count+1
	I count'<mincount q 1
	q matched
plural(text)       ;
	;Function to remove trailing s
	f i=1:1:$l(text," ") d
	. set word=$p(text," ",i)
	. q:word=""
	. if $l(word)>1,$e(word,$l(word))="s" d
	. . set word=$e(word,1,$l(word)-1)
	. . i word="" q
	. . set $p(text," ",i)=word
	q text
dupl(text)         ;Removes duplicate
	n wordlist
	n word
	n i
	f i=1:1:$l(text," ") d
	. set word=$p(text," ",i)
	. q:word=""
	. if $e(word,$l(word))="s" d
	. . set word=$e(word,1,$l(word)-1)
	. . i word="" q
	. . set $p(text," ",i)=word
	. i word="" q
	. if $d(wordlist(word)) do  q
	. . set text=$p(text," ",1,i-1)_" "_$p(text," ",i+1,20)
	. set wordlist(word)=""
	q text
MFRONT(test,tomatch,count,leftover) ;
	;Matcheset the fist part of a phrase
	N matched,done
	n ltest,ltomatch,from,to,i,word,word1,mcount
	set matched=0,done=0
	set ltest=$L(test," "),ltomatch=$l(tomatch," ")
	set from=$s(ltest>ltomatch:"tomatch",1:"test")
	set to=$s(from="tomatch":"test",1:"tomatch")
	I $l(@from," ")<count q 0
	set mcount=0
	F i=1:1:$l(@from," ") do  Q:done
	. set word=$p(@from," ",i)
	. set word1=$p(@to," ",i)
	. if $$LEVENSH^UPRNU(word,word1) do  q
	. . set mcount=mcount+1
	. set done=1
	if mcount<count q 0
	set leftover=$p(@to," ",mcount+1,20)
	q 1
	;
	;
	;