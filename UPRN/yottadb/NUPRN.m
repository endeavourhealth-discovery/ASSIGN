NUPRN ;Command line Main routine for processing a batch of addresseset [ 06/10/2019   8:22 AM ]
 
 ;Enter the post code filter
 w !,"Post code prefix :" r qpost
 
 ;Variable Uif set to 0= no display, 1 = display unmatched, 2 display all
 ;W !,"Ui setting ? : " r UI
 
 ;W !,"All or unmatched (A,U) ; " r all
 
 ;if 'UI W !,"No UI",!,"......"
 ;Processet the address files
 s all="a"
 D GO($$lc^UPRNL(qpost),$$lc^UPRNL(all))
 q
 
GO(qpost,all)          ;Processes a global list of addresses filtered by qpost%
 ;
 s xh=$p($H,",",2)
 S UI=$G(UI,0)
 ;Matching all (D) or just unmatched (UM)
 
 ;Sets index value to D for all, UM for unmatched
 set mkey=$s(all="a":"D",1:"UM")
 
 ;lower case the post code filter
 set qpost=$$lc^UPRNL(qpost)
 
 ;Initiate the spelling swap  and corrections
 d SETSWAPS^UPRNU
 
 ;Set File delimiter
 set d="~"
   
 ;Initiate the counts
 set nopost=0,total=0,mcount=0,outarea=0
 set impossible=0
 set unmatched=0
 set nonumber=0
 
 ;Loop through the table of addresses, 
 set adno=""
REDO for  set adno=$O(^UPRN(mkey,adno)) q:adno=""  d
 .d tomatch(adno) ;Match 1 address
 .if UI=0 if '(total#1000) do
 ..w !,total," Time=",($p($h,",",2)-xh\60),",",($p($h,",",2)-xh#60)
 ..w " matched="_mcount," unmatched="_unmatched
 .Q
 
 ;Display Final statset at end of run
STATS 
 w !,"Total processed= ",total
 i total=0 q
 w !,"Put of area=",outarea
 w !,"No post=",nopost
 w !,"Unmatched=",unmatched
 w !,"No match possible=",impossible
 w !,"Misssing flat/number or no ADP flat/number ",nonumber
 w !,"Matched=",mcount
 W !,"i.e. "_$j((mcount/total*100),1,2)_"%"
 q
 
tomatch(adno)      ;Match one Discovery address
 
 ;Remove from unmatched and matched resultset list
 ;K ^UPRN("UM",adno)
 K ^UPRN("M",adno)
 
 ;Initiate global find variabls
 ;Retrieve address record
 set adrec=^UPRN("D",adno)
 
 ;Find post code in the last field
 set length=$length(adrec,d)
 set post=$$lc^UPRNL($p(adrec,d,length))
 set post=$tr(post," ") ;Remove spaces
 
 ;If post code null increment nopost and quit
 if post="" set nopost=nopost+1 Quit
 
 ;if post code doesn't start with qpost quit
 if $e(post,1,$l(qpost))'=qpost quit
 
 ;Date in address, remove from file
 i adrec?2n1"/"2n1"/".n1"~".e K ^UPRN("D",adno) q
 ;Address already marked as impossible quit
 if $D(^UPRN1(adrec)) D  q
 .S impossible=impossible+1
 
 d format^UPRNA(adrec,.address)
 ;
 ;format the address record
 set adflat=address("flat")
 set adbuild=address("building")
 set adbno=address("number")
 set adstreet=address("street")
 set adloc=address("locality")
 set adpost=address("postcode")
 set adepth=address("depth")
 set adeploc=address("deploc")
 set adpstreet=$$plural^UPRNU(adstreet)
 set adpbuild=$$plural^UPRNU(adbuild)
 set adflatbl=$$flat^UPRNU(adbuild_" ")
 set adplural=0
 i adpstreet'=adstreet s adplural=1
 if adpbuild'=adbuild s adplural=1
 set adb2=""
 set adf2=""
 i adbuild'="",adflat?1n.n1" "1l.l d
 .s adb2=$p(adflat," ",2,10)_" "_adbuild
 .s adf2=$p(adflat," ")
 
 s indrec=adpost_" "_adflat_" "_adbuild_" "_adbno_" "_adepth_" "_adstreet_" "_adeploc_" "_adloc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 i adplural d
 .s indprec=adpost_" "_adflat_" "_adpbuild_" "_adbno_" "_adepth_" "_adpstreet_" "_adeploc_" "_adloc
 for  q:(indprec'["  ")  s indprec=$$tr^UPRNL(indprec,"  "," ")
 s indprec=$$lt^UPRNL(indrec)
 
 k ^TUPRN
 
 ;Total Count incremented
 set total=total+1
 
 
 ;clear down variables
 do clrvars
 
 ;Exact match all fields directly i.e. 1 candidate
 D match(adflat,adbuild,adbno,adepth,adstreet,adeploc,adloc,adpost,adf2,adb2)
 ;Long shot for post code drop number, very fuzzy on building
2600 I '$D(^TUPRN($J)) D
 .S ALG="2600-"
 .s matches=$$match26(adpost,adstreet,adbno,adbuild,adflat)
 i $D(^TUPRN($J)) d  q
 .d matched
 e  d  q
 .d nomatch
 q
 
 
match(adflat,adbuild,adbno,adepth,adstreet,adeploc,adloc,adpost,adf2,adb2) ;
 ;Match algorithms
 n matched
 s matched=0
 s ALG=""
 
 ;Full match on post,street, building and flat
1 s matches=$$matchall(indrec)
 I $D(^TUPRN($J)) Q
 
10 S ALG="10-"
 s matchrec="Pe,Se"
 s matches=$$match1(adpost,adstreet,adbno,adbuild,adflat)
 i $d(^TUPRN($J)) Q
 I adplural d
 .s matches=$$match1(adpost,adpstreet,adbno,adpbuild,adflat)
 I $D(^TUPRN($J)) b  Q
 q
 
 
 ;Full match on dependent street
 i adepth'="" d
20 .s ALG="20-"
 .s matches=$$match1(adpost,adepth_" "_adstreet,adbno,adbuild,adflat)
 .i $D(^TUPRN($J)) Q
 .I adplural d
 ..s matches=$$match1(adpost,adepth_" "_adpstreet,adbno,adpbuild,adflat)
 .I $D(^TUPRN($J)) Q
30 .S ALG="30-"
 .s matches=$$match1(adpost,adepth,adbno,adbuild,adflat)
 .i $D(^TUPRN($J)) Q
 .i adplural d
 ..s matches=$$match1(adpost,adepth,adbno,adpbuild,adflat)
 i $D(^TUPRN($J)) Q
 
 
 ;Full match Swap building flat with number and street
40 s ALG="40-"
 s matches=$$match1(adpost,adbuild,adflat,adstreet,adbno)
 I $D(^TUPRN($J)) Q
 i adplural d
 .s matches=$$match1(adpost,adpbuild,adflat,adstreet,adbno)
 I $D(^TUPRN($J)) q
 
 ;Full match locality swap for street
 i '$D(^TUPRN($J)),adloc'="" d
50 .S ALG="50-"
 .set matchrec="Pe,Se"
 .s matches=$$match1(adpost,adloc,adbno,adbuild,adflat)
 .i $D(^TUPRN($J)) Q
 .i adplural d
 ..s matches=$$match1(adpost,adloc,adbno,adpbuild,adflat)
 i $D(^TUPRN($J)) Q
 
 ;Full match Try swapping flat and mumber
 I '$D(^TUPRN($J)) D
60 .S ALG="60-"
 .S matches=$$match4(adpost,adstreet,adbno,adbuild,adflat)
 .I $D(^TUPRN($J)) Q
 .I adplural d
 ..S matches=$$match4(adpost,adpstreet,adbno,adpbuild,adflat)
 i $D(^TUPRN($J)) q
 
 ;Special flat in building
 i adflatbl'=(adbuild_" "),adflat'="" d
70 .s ALG="70-"
 .s matches=$$match1(adpost,adstreet,adbno,"",adflatbl_adflat)
 
 I $d(^TUPRN($J)) Q
 
 
 ;Part building in flat
 i adf2'="" d
80 .S ALG="80-"
 .s matches=$$match1(adpost,adstreet,adbno,adb2,adf2)
 i $D(^TUPRN($J)) Q
 
 ;Full match with street spelling corrections
 s matchrec="Pe,Se"
90 S ALG="90-"
 I adstreet'="" d
 .s street=""
 .for  s street=$O(^UPRNW("SFIX",adstreet,street)) q:street=""  d  I $D(^TUPRN($J)) Q
 ..S ALG="90-"
 ..set matchrec="Pe,Sl"
 ..s matches=$$match1(adpost,street,adbno,adbuild,adflat)
 ..i $D(^TUPRN($J)) Q
 ..i adflat'="",adbuild'="" d
100 ...s ALG="100-"
 ...s matches=$$match1(adpost,street,adbno,adflat_" "_adbuild,"")
 ...i $D(^TUPRN($J)) q  
 ..I adf2'="" d
110 ...S ALG="110-"
 ...s matches=$$match1(adpost,street,adbno,adb2,adf2)
 ...I $D(^TUPRN($J)) Q
 ..i $D(^TUPRN($J)) Q
120 ..S ALG="120-"
 ..s matches=$$match2(adpost,street,adbno,adbuild,adflat)
 ..I $D(^TUPRN($J)) Q
 ..i adbno?1n.n1l,adflat="" d
125 ...s ALG="125-"
 ...s matches=$$match1(adpost,street,adbno*1,adbuild,$p(adbno,adbno*1,2))
 ..i adflat?1n.n
 i $d(^TUPRN($J)) Q
 
 ;Matches post code street and number, try fuzzy building/ flat       
130 s ALG="130-"
 s matches=$$match2(adpost,adstreet,adbno,adbuild,adflat)
 i $D(^TUPRN($J)) Q
 i adepth'="" d
140 .s ALG="140-"
 .s matches=$$match2(adpost,adepth_" "_adstreet,adbno,adbuild,adflat)
 i $D(^TUPRN($J)) Q
 
 
 ;Match on street and number, try another post code
 I '$D(^TUPRN($J)),adstreet'="" d
300 .s ALG="300-"
 .s matchrec=",Se"
 .s matches=$$match7(adpost,adstreet,adbno,adbuild,adflat)
 
350 ;near post code Matches with flat and building split out from street
 I '$D(^TUPRN($J)),adbno'="",adflat="",adbuild="",adstreet'="" d
 .S ALG="350-"
 .s matches=$$match28(adpost,adstreet,adbno,adbuild,adflat)
 
i ;Swaps building and street try another post code
 I '$d(^TUPRN($J)),adbuild'="" d
310 .s ALG="310-"
 .s matches=$$match7(adpost,adbuild,adflat,adstreet,adbno)
 
j ;Parse building from street and use number as flat
 i '$D(^TUPRN($J)) d
500 .S ALG="500-"
 .s matches=$$match5(adpost,adstreet,adbno,adbuild,adflat)
 
 
 
k ;try different post code on levenstreet
 I '$D(^TUPRN($J)),adstreet'="" d
600 .s ALG="600-"
 .I adbno="",adbuild="" q  ;Wrong post code Not enough fields
 .s street=""
 .for  s street=$O(^UPRNW("SFIX",adstreet,street)) q:street=""  d
 ..s matchrec=",Sl"
 ..s matches=$$match7(adpost,street,adbno,adbuild,adflat)
 
 
l ;Try equivalent and levenshtein on building as street
 i '$d(^TUPRN($J)),adbuild'="" d
700 .S ALG="700-"
 .s build=""
 .s matchrec="Pe"
 .for  s build=$O(^UPRN("X5",adpost,build)) q:build=""  d
 ..i $$equiv^UPRNU(build,adbuild) d
 ...S $p(matchrec,",",2)="Sl"
 ...s matches=$$match1(adpost,build,adflat,adstreet,adbno)
 ...I $D(^TUPRN($J)) Q
 ...S $p(matchrec,",",2)="Sl"
 ...s matches=$$match2(adpost,build,adflat,adstreet,adbno)
 
 
m ;Now try approximation of number
 I '$D(^TUPRN($J)),adstreet'="",adbno'="" d
800 .s ALG="800-"
 .s matchrec="Pe"
 .s matches=$$match6(adpost,adstreet,adbno,adbuild,adflat)
 
 I '$D(^TUPRN($J)),adbno'="",adflat'="",adbuild'="",adstreet'="" d
900 .s ALG="900-"
 .s matches=$$match21(adpost,adstreet,adbno,adbuild,adflat)
 
 
 ;Wrong street, try post code - building flat 
 i '$D(^TUPRN($J)),adbuild'="",adflat'="" d
1000 .S ALG="1000-"
 .set matchrec="Pe,,,Be,Fe"
 .set matches=$$match3(adpost,adstreet,adbno,adbuild,adflat)
 
 
o ;right post code approx street
 I '$D(^TUPRN($J)) D
1100 .s ALG="1100-"
 .s matchrec="Pe"
 .s matches=$$match11(adpost,adstreet,adbno,adbuild,adflat)
 q
 
p ;Completely wrong post code so needs a building, number and street
 I '$D(^TUPRN($J)) D
1200 .s ALG="1200-"
 .i adstreet'="",adbno'="",adbuild'="" d
 ..s matches=$$match14(adpost,adstreet,adbno,adbuild,adflat)
 
 ;Swap building and street and fuzzy match
 S matchrec="Pe"
 I '$D(^TUPRN($J)) D
1300 .s ALG="1300-"
 .I adbuild'="",adbno'="" d
 ..;s matches=$$match2(adpost,adbuild,adbno,adstreet,adflat)
 
r ;Drop suffix from the number
 i '$D(^TUPRN($J)) D
1400 .s ALG="1400-"
 .s matches=$$match15(adpost,adstreet,adbno,adbuild,adflat)
 
s ; street number wandered into flat field
 I '$D(^TUPRN($J)) D
1500 .s ALG="1500-"
 .s matches=$$match17(adpost,adstreet,adbno,adbuild,adflat)
 
t ; missing number so needs to match on building and flat
 I '$D(^TUPRN($J)) D
1600 .s ALG="1600-"
 .s matches=$$match18(adpost,adstreet,adbno,adbuild,adflat)
 
u ;post code street match but high level on flat and building
 i '$D(^TUPRN($J)) d
1700 .s ALG="1700-"
 .s matches=$$match19(adpost,adstreet,adbno,adbuild,adflat)
 
v ;Levenshtein street, drop number if flat and building, different post
 I '$D(^TUPRN($J)),adstreet'="" d
1800 .s ALG="1800-"
 .I adbno=""!(adflat="")!(adbuild="") q
 .s street=""
 .for  s street=$O(^UPRNW("SFIX",adstreet,street)) q:street=""  d
 ..s matchrec=",Sl"
 ..s matches=$$match20(adpost,street,"",adbuild,adflat)
 
w ;street and number was building and flat with missing street
 I '$D(^TUPRN($J)),adstreet'="",adbno'="",adbuild="",adflat="" d
1900 .s ALG="1900-"
 .s matchrec="Pe"
 .s matches=$$match22(adpost,adstreet,adbno,adbuild,adflat)
 
x ;building is in locality, street contains flat
 I '$D(^TUPRN($J)),adloc'="",adstreet'="",adbuild="",adflat="" d
2000 .s ALG="2000-"
 .s matches=$$match23(adpost,adstreet,adbno,adloc,adflat)
 
y ;In case of suffix numbers
 I '$D(^TUPRN($J)),adbno'="" d
2100 .s ALG="2100-"
 .s matches=$$match24(adpost,adstreet,adbno,adbuild,adflat)
 
2200 ;Concatenate number and flat
 I '$D(^TUPRN($J)),adflat?1l,adbno?1n.n d
 .s ALG="2200-"
 .s matchrec=",Se"
 .s matches=$$match7(adpost,adstreet,adbno_adflat,adbuild,"")
 
p1 ;Completely wrong post code ignore, building, null flat, needs number and street
 I '$D(^TUPRN($J)) D
2300 .s ALG="2300-"
 .i adstreet'="",adbno'="",adbuild="" d
 ..s matches=$$match14(adpost,adstreet,adbno,adbuild,adflat,1)
 
 ;right post code last chance for approx street
 I '$D(^TUPRN($J)) D
2400 .s ALG="2400-"
 .s matchrec="Pe"
 .s matches=$$match11(adpost,adstreet,adbno,adbuild,adflat,1)
 
2450 ;Drop number and street, building and flat is number and street
 I '$D(^TUPRN($J)) D
 .S ALG="2450-"
 .s matchrec="Pe"
 .s matches=$$match27(adpost,adstreet,adbno,adbuild,adflat)
 
2500 ;Exact or Near post code, Swap flat into number, parse out flat from building
 I '$D(^TUPRN($J)) D
 .S ALG="2500-"
 .s matches=$$match25(adpost,adstreet,adbno,adbuild,adflat)
 q
 ;
match23(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Location is building, strip flat out of street
 n i
 f i=1:1:$l(tstreet," ") d  q:$d(^TUPRN($J))
 .s street=$p(tstreet," ",1,i)
 .I $D(^UPRN("X5",tpost,street,tbno,tbuild)) do
 ..s tflat=$p(tstreet," ",i+1,10)
 ..I $$mflat(tpost,street,tbno,tbuild,tflat,.flat,.approx) d
 ...s $p(matchrec,",",2)="Se"
 ...s $p(matchrec,",",3)="Ne"
 ...s $p(matchrec,",",4)="Be"
 ...s $p(matchrec,",",5)="F"_approx
 ...d setuprns("X5",tpost,street,tbno,tbuild,flat)
 ...s ALG=ALG_"match23"
 q $D(^TUPRN($J))
 
 
match22(tpost,tstreet,tbno,tbuild,tflat)          ;
 
 ;Checks the building index
 i $D(^UPRN("X3",tstreet,tbno,tpost)) d
 .s street=""
 .for  s street=$O(^UPRN("X5",tpost,street)) q:street=""  d  Q:$D(^TUPRN($J))
 ..I $D(^UPRN("X5",tpost,street,"",tstreet,tbno)) d
 ...s $p(matchrec,",",2,3)="Si,Ne"
 ...s $p(matchrec,",",4,5)="Be,Fe"
 ...d setuprns("X5",tpost,street,"",tstreet,tbno)
 ...s ALG=ALG_"match22"
 Q $G(^TUPRN($J))
 
match20(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Alternative post codes for null street number
 ;e152pu , 1 castor park road, 1 casitor house
 ;= e153pu, caistor park road, caistor house, 1
 s post=""
 for  s post=$O(^UPRN("X3",tstreet,"",post)) q:post=""  d  q:$G(^TUPRN($J))
 .q:post=tpost
 .s matchrec=""
 .i $e(post,1,$l(adpost))=adpost d
 ..s $p(matchrec,",",1)="Pp"
 .e  d
 ..i $$levensh^UPRNU(post,adpost,5) d
 ...s $p(matchrec,",",1)="Pl"
 ..E  i $e(post,1,3)=$e(adpost,1,3) D
 ...s $p(matchrec,",",1)="Pp"
 .i matchrec="" q
 .s matches=$$match20a(post,tstreet,tbno,tbuild,tflat)
 I $G(^TUPRN($J))>1 d prefer
 q $g(^TUPRN($J))
 
match20a(post,tstreet,tbno,tbuild,tflat) 
 ;Wrong post code, drop street number must match on building flat
 ;levensthein building bu exact on flat
 N matched
 s matched=0
 S $p(matchrec,",",2,3)="Se,Ne"
 ;Looping through UPRNs for match
 s uprn=""
 for  s uprn=$O(^UPRN("X3",tstreet,"",post,uprn)) q:uprn=""  d  Q:matched
 .s table=""
 .for  s table=$O(^UPRN("X3",tstreet,tbno,post,uprn,table)) q:table=""  d  Q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("X3",tstreet,tbno,post,uprn,table,key)) q:key=""  d  q:matched
 ...D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.lpost,.org)
 ...I $$equiv^UPRNU(build,tbuild) d
 ....i tflat=flat d
 .....s $p(matchrec,",",4,5)="Bl,Fe"
 .....s ALG=ALG_"match20"
 .....d set(uprn,table,key)
 .....s matched=1
 Q $G(^TUPRN($J))
 
match21(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Checks building flat and post code and works back
 i '$d(^UPRN("X3",tbuild,tflat)) q 0
 s post=""
 for  s post=$O(^UPRN("X3",tbuild,tflat,post)) q:post=""  d  q:$G(^TUPRN($J))
 .q:post=tpost
 .s matchrec=""
 .i $$levensh^UPRNU(post,adpost,5) d
 ..s $p(matchrec,",",1)="Pl"
 .E  i $e(post,1,3)=$e(adpost,1,3) D
 ..s $p(matchrec,",",1)="Pp"
 .i matchrec="" q
 .i '$D(^UPRN("X5",post,tstreet)) q
 .s bno=""
 .for  s bno=$O(^UPRN("X5",post,tstreet,bno)) q:bno=""  d  q:$D(^TUPRN($J))
 ..i $D(^UPRN("X5",post,tstreet,bno,tbuild,tflat)) d
 ...s $p(matchrec,",",2)="Se"
 ...s $p(matchrec,",",3)="Ni"
 ...s $p(matchrec,",",4,5)="Be,Fe"
 ...d setuprns("X5",post,tstreet,bno,tbuild,tflat)
 ...s ALG=ALG_"match21"
 q $G(^TUPRN($J))
match7(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Alternative post codes
 s post=""
 for  s post=$O(^UPRN("X3",tstreet,tbno,post)) q:post=""  d
 .q:post=tpost
 .s $p(matchrec,",",1)=""
 .i $e(post,1,$l(adpost))=adpost d
 ..s $p(matchrec,",",1)="Pp"
 .E  D
 ..i $$levensh^UPRNU(post,adpost,5) d
 ...s $p(matchrec,",",1)="Pl"
 ..E  D
 ...i $e(post,1,3)=$e(adpost,1,3) D
 ....s $p(matchrec,",",1)="Pp"
 ...E  D
 ....I '$d(^UPRN("X1",tpost)) i $e(post)=qpost d
 .....i '$d(^UPRN("X5",post,tstreet,tbno,tbuild,tflat)) q
 .....s $p(matchrec,",",1)="Pp"
 .i $P(matchrec,",",1)="" q
 .s matches=$$match8(post,tstreet,tbno,tbuild,tflat)
 i $G(^TUPRN($J))>1 d prefer
 
 q $g(^TUPRN($J))
prefer ;
 n prefer
 s prefer=0
 s (uprn,table,key)=""
 for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 .s table=""
 .for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ..s key=""
 ..for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ...s lprec=^(key)
 ...D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 ...i flat=adflat,build=adbuild,depth=adepth,street=adstreet,bno=adbno d
 ....s pref=$s($e(post,1,3)=$e(adpost,1,3):0,1:1)
 ....s prefer(pref,uprn,table,key)=^TUPRN($J,uprn,table,key)
 ....s prefer=prefer+1
 i '$d(prefer) q
 B
 K ^TUPRN
 s pref=$o(prefer(""))
 s uprn=$o(prefer(pref,""))
 s table=""
 for  s table=$O(prefer(pref,uprn,table)) q:table=""  d
 .s key=""
 .for  s key=$O(prefer(pref,uprn,table,key)) q:key=""  d
 ..s ^TUPRN=1
 ..S ^TUPRN($J,uprn,table,key)=prefer(pref,uprn,table,key)
 Q
 
match8(post,tstreet,tbno,tbuild,tflat)         ;
 ;Called from match7
 ;Matches using X3
 ;Assumes flat and number match
 ;straight match
 n matched
 s matched=0
 N build,street,bno,flat
 I $D(^UPRN("X5",post,tstreet,tbno,tbuild,tflat)) d
 .s $p(matchrec,",",3,5)="Ne,Be,Fe"
 .s $p(ALG,"-",2)="match8"
 .d setuprns("X5",post,tstreet,tbno,tbuild,tflat) 
 i $g(^TUPRN($J)) Q $G(^TUPRN($J))
 
 S $p(matchrec,",",3)="Ne"
 ;Looping through UPRNs for match
 s uprn=""
 for  s uprn=$O(^UPRN("X3",tstreet,tbno,post,uprn)) q:uprn=""  d  Q:matched
 .s table=""
 .for  s table=$O(^UPRN("X3",tstreet,tbno,post,uprn,table)) q:table=""  d  Q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("X3",tstreet,tbno,post,uprn,table,key)) q:key=""  d  q:matched
 ...s lprec=^(key)
 ...D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 ...S $p(matchrec,",",3)=$s(bno=tbno:"Ne",bno=""&(tbno'=""):"Nd",1:"Ni")
 ...i build="",tbuild="" d  q
 ....s $p(matchrec,",",4)="Be"
 ....i flat="",tflat="" d  q
 .....s $p(matchrec,",",5)="Fe"
 .....d set(uprn,table,key) q
 .....s matched=1
 .....s ALG=ALG_"match8a"
 ....i $$mflat2(flat,tflat) d  q
 .....s $p(matchrec,",",5)="Fp"
 .....d set(uprn,table,key)
 .....s ALG=ALG_"match8b"
 .....s matched=1
 ...i $$equiv^UPRNU(build,tbuild) d  q
 ....s $p(matchrec,",",4)="Bl"
 ....i $$mflat1(tflat,flat,.approx) d
 .....s $p(matchrec,",",5)="F"_approx
 .....d set(uprn,table,key)
 .....s ALG=ALG_"match8c"
 .....s matched=1
 ...s $p(matchrec,",",4)=""
 ...i $$equiv^UPRNU(build,tstreet) d
 ....s $p(matchrec,",",4)="Bl"
 ...I $$MPART^UPRNU(street,tbuild) d
 ....S $P(matchrec,",",2)="Sp"
 ...i $p(matchrec,",",4)="" q
 ...i tflat=bno,tbno=flat d
 ....s $p(matchrec,",",2)="Ne"
 ....s $p(matchrec,",",5)="Fe"
 ....d set(uprn,table,key)
 ....S ALG=ALG_"match8e"
 ....s matched=1
 Q $G(^TUPRN($J))
 
match6(tpost,tstreet,tbno,tbuild,tflat) 
 ;Suffix drop or ignore on number
 n bno,build
 i $D(^UPRN("X5",tpost,tstreet)) d
 .s $p(matchrec,",",2)="Se"
 .s bno=""
 .for  s bno=$O(^UPRN("X5",tpost,tstreet,bno)) q:bno=""  d  q:$d(^TUPRN($J))
 ..i $$mno1(tbno,bno,.approx) do
 ...s $p(matchrec,",",3)="N"_approx
 ...i $D(^UPRN("X5",tpost,tstreet,bno,tbuild)) d  q
 ....s $p(matchrec,",",4)="Be"
 ....i $$mflat(tpost,tstreet,bno,"",tflat,.flat,.approx) d  q
 .....s $p(matchrec,",",5)="F"_approx
 .....d setuprns("X5",tpost,tstreet,tbno,"",flat)
 .....s ALG=ALG_"match6"
 ...if tbuild'="" d
 ....i $$mflat(tpost,tstreet,bno,"",tflat,.flat,.approx) d
 .....s $p(matchrec,",",4)="Bi"
 .....s $p(matchrec,",",5)="F"_approx
 .....d setuprns("X5",tpost,tstreet,bno,"",flat)
 .....s ALG=ALG_"match6a"
 q $G(^TUPRN($J))
 
match18(tpost,tstreet,tbno,tbuild,tflat) 
 ;Final run through for this post code, might need to go for parent
 n matched,front,back
 k flatlist
 s matched=0
 s uprn=""
 for  s uprn=$O(^UPRN("X1",tpost,uprn)) q:uprn=""  d  q:matched
 .s table=""
 .for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  q:matched
 ...s rec=^(key)
 ...s flat=$p(rec,"~",1),build=$p(rec,"~",2)
 ...s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
 ...s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
 ...S loc=$p(rec,"~",7),town=$p(rec,"~",8)
 ...S pstreet=$$plural^UPRNU(street)
 ...i pstreet'=tstreet,tbuild="" d  q
 ....d match18a
 ....i $D(^TUPRN($J)) s matched=1
 ...i tbuild'="",$$equiv^UPRNU(street,tbuild_" "_tstreet) d  q
 ....s matched=$$match18h()
 ...I tstreet'="",pstreet'="",tstreet'=pstreet d
 ....i tbno=bno,tflat'="",flat'="" d
 .....i build'="",tbuild'="" d
 ......i $$equiv^UPRNU(build,tbuild) d
 .......i $$mflat1(tflat,flat,.approx) d
 ........s $p(matchrec,",",2,5)="Si,Ne,Bl,F"_approx
 ........d set(uprn,table,key)
 ........s ALG=ALG_"match18b"
 ........s matched=1
 ...i $$roadmiss^UPRNU(tbuild,pstreet) d  q
 ....i tflat=bno,flat="",tbno="",build="" d
 .....s $p(matchrec,",",2,5)="Sp,Ne,Be,Fe"
 .....s ALG=ALG_"match18c"
 .....s matched=1
 .....d set(uprn,table,key)
 ...I tflat'="",$$equiv^UPRNU(build,tflat_" "_tbuild) d
 ....i $$equiv^UPRNU(loc,tstreet) d
 .....i bno="",tbno="" d
 ......s $p(matchrec,",",2,5)="Se,Ne,Be,Fe"
 ......s ALG=ALG_"match18d"
 ......d set(uprn,table,key)
 ......s matched=1
 ...i pstreet'=tstreet q
 ...s $p(matchrec,",",1,2)="Pe,Se"
 ...i bno="",flat="",tbuild="",build=(tflat_" "_tbno) d  q ;unit 6 tilia
 ....s $p(mathcrec,",",3,5)="Ne,Be,Fe"
 ....d set(uprn,table,key)
 ....s ALG=ALG_"match18e"
 ....S matched=1
 ...i bno="",flat="",tflat="",build=(tbno_" "_tbuild) d  q ; 75 ability
 ....s $p(matchrec,",",1,5)="Pe,Se,Ne,Be,Fe"
 ....s ALG=ALG_"match18f"
 ....d set(uprn,table,key)
 ....s matched=1
 ...i bno=tbno q  ;Already processed in match2
 ...;101 101a problem
 ...i build="",tbuild="" d  q
 ....i $$fnsplit(tbno,bno,tflat,flat) d  q
 .....s $p(matchrec,",",3)="Ne"
 .....s $p(matchrec,",",4)="Be"
 .....s $p(matchrec,",",5)="Fe"
 .....d set(uprn,table,key)
 .....s ALG=ALG_"match18g"
 .....s matched=1
 ....I bno="",tflat="",tbno'="",tbno=flat d  q
 .....s $p(matchrec,",",4,5)="Be,Fe"
 .....d set(uprn,table,key)
 .....s ALG=ALG_"match18h"
 .....s matched=1
 ....i flat="",tflat="",bno*1=(tbno*1) d
 .....s $p(matchrec,",",2)=$s(tbno?1n.n1l:"Nds",1:"Nis")
 .....s ALG=ALG_"match18i"
 .....d set(uprn,table,key)
 .....s matched=1
 ....i tbno*1=(bno*1),tflat="",flat'="" d
 .....s flatlist(flat)=uprn_"~"_table_"~"_key
 ....i tbno*1=(bno*1),tflat'="",tflat=flat d  q
 .....s $p(matchrec,",",3)="Nds"
 .....s $p(matchrec,",",4,5)="Be,Fe"
 .....d set(uprn,table,key)
 .....s ALG=ALG_"match18j"
 .....S matched=1
 ...I build=""!(tbuild="") q
 ...i $$MPART^UPRNU(build,tbuild) d
 ....i flat=tflat,tbno="",bno'="" d  q
 .....s $p(matchrec,",",3,5)="Ni,Bp,Fe"
 .....d set(uprn,table,key)
 .....s $p(ALG,"-",2)="match18k"
 ....i flat=tflat,tbno=bno d
 .....s $p(matchrec,",",4,5)="Bp,Fe"
 .....d set(uprn,table,key)
 .....S ALG=ALG_"match18l"
 .....s matched=1
 ....I tbno=flat,tflat=bno d
 .....s $p(matchrec,",",3)="Ne"
 .....s $p(matchrec,",",4)="Bp,Fe"
 .....d set(uprn,table,key)
 .....S ALG=ALG_"match18m"
 .....s matched=1
 i $D(^TUPRN($J)) Q $G(^TUPRN($J))
 i $d(flatlist) d
 .i $$fmatch(tbno,.flatlist,.uprn,.table,.key) d
 ..s $p(matchrec,",",3)="Np"
 ..s $p(matchrec,",",4,5)="Be,Fe"
 ..d set(uprn,table,key)
 ..s ALG=ALG_"match18n"
 Q $G(^TUPRN($J))
 
 
match18h()         ;Matched on building and street
 i bno=tflat,tbno="" d
 .s $p(matchrec,",",2)="Sp"
 .s $p(matchrec,",",3)="Ne"
 .s $p(matchrec,",",4)="Be"
 .s $p(matchrec,",",5)="Fe"
 .s ALG=ALG_"match18h"
 .d set(uprn,table,key)
 Q $D(^TUPRN($J))
 
match18a         ;
 ;street building mix ups 1
 ;Building has slid into street
 n matched
 s matched=0
 i $$getfront^UPRNU(pstreet,tstreet,.front,.back) d  q
 .s xbuild=$s(tbuild="":front,1:tbuild_" "_front)
 .i xbuild=build d
 ..s $p(matchrec,",",2)="Se"
 ..s $p(matchrec,",",4)="Be"
 ..i tbno="",bno'="" s $p(matchrec,",",3)="Ni"
 ..i bno="",tbno'="" s $p(matchrec,",",3)="Nd"
 ..i tflat'="",flat="" s $p(matchrec,",",5)="Fd"
 ..i flat'="",tflat="" s $p(matchrec,",",5)="Fi"
 ..d set(uprn,table,key)
 ..s matched=1
 ..s ALG=ALG_"match18a"
 i $D(^TUPRN($J)) Q
 
 ;street equivalent, building equivalent to street
 I $$equiv^UPRNU(pstreet,tstreet,8) d
 .I bno=tbno,flat="",tflat="" d
 ..i tbuild="" do
 ...i build'="",$$equiv^UPRNU(build,tstreet,8) d  q
 ....s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
 ....s ALG=ALG_"match18aa"
 ....d set(uprn,table,key)
 ...i build="" d  Q
 ....s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
 ....s ALG=ALG_"match18ab"
 ....d set(uprn,table,key)
 
 I $D(^TUPRN($J)) Q
 n troad
 s troad=$$stripr^UPRNU(tstreet)
 I $$equiv^UPRNU(pstreet,troad,7) d
 .I bno=tbno,flat="",tflat="" d
 ..i tbuild="" do
 ...i build'="",$$equiv^UPRNU(build,tstreet,8) d  q
 ....s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
 ....s ALG=ALG_"match18ac"
 ....d set(uprn,table,key)
 ...i build="" d  Q
 ....s $p(matchrec,",",2,5)="Sl,Ne,Bp,Fe"
 ....s ALG=ALG_"match18ad"
 ....d set(uprn,table,key)
 i $d(^TUPRN($J)) Q
 
 ;building is equivalent to street
 ;Doesnt have the right street
 ;Flat matches number?
 i build'="",$$equiv^UPRNU(build,tstreet) d  q
 .i bno="",tbno=flat d  q
 ..i tbuild="",flat="",tflat="" d  q:matched
 ...s $p(matchrec,",",2,5)="Si,Ni,Bl,Fe"
 ...s ALG=ALG_"match18ae"
 ...d set(uprn,table,key)
 ...s matched=1
 ..i flat'=tbno q
 ..s $p(matchrec,",",2)="Si"
 ..s $p(matchrec,",",3)="Ne"
 ..s $p(matchrec,",",4)="Be"
 ..s $p(matchrec,",",5)="Fe"
 ..d set(uprn,table,key)
 ..s ALG=ALG_"match18af"
 ..s matched=1
 .i bno'="",tbno'="" d  Q:matched
 ..i flat'=tbno q
 ..s $p(matchrec,",",2)="Si"
 ..s $p(matchrec,",",3)="Ni"
 ..s $p(matchrec,",",4)="Be"
 ..s $p(matchrec,",",5)="Fe"
 ..d set(uprn,table,key)
 ..s ALG=ALG_"match18ag"
 ..s matched=1
 .I flat=tflat,flat'="" d
 ..s $p(matchrec,",",2)="Si"
 ..i bno="",tbno'="" s $p(matchrec,",",3)="Nd"
 ..i tbno="",bno'="" s $p(matchrec,",",3)="Ni"
 ..I bno=tbno s $p(matchrec,",",3)="Ne"
 ..s $p(matchrec,",",4,5)="Bl,Fe"
 ..d set(uprn,table,key)
 ..S ALG=ALG_"match18ah"
 
 ;first part of streets match, building has second part
 I $P(pstreet," ")=$p(tstreet," ") d
 .s back=$p(tstreet," ",2,10)
 .I back'="",build'="",build[back d
 ..i bno=tbno,flat=tflat d
 ...s $p(matchrec,",",2)="Sp"
 ...s $p(matchrec,",",3)="Ne"
 ...s $p(matchrec,",",4)="Bp"
 ...s $p(matchrec,",",5)="Fe"
 ...d set(uprn,table,key)
 ...s ALG=ALG_"match18ai"
 
 q
fbno(bno,flat)     ;matches a flat floor to a suffix
 n letter
 s letter=$p(bno,bno*1,2)
 i letter="" q 0
 i $d(^UPRNS("FLOOR",flat,letter)) q 1
 q 0
 
fmatch(tbno,flatlist,uprn,table,key)        ;
 n letter,matched
 s matched=0
 i tbno?1n.n1l d
 .s letter=$p(tbno,tbno*1,2)
 .i letter="a" d  q:matched
 ..i $$floor("basement") d  q
 ...d mfloor("basement")
 ...s matched=1
 ..i $$floor("ground") d  q
 ...d mfloor("ground")
 ...s matched=1
 ..i $$floor("first") d  q
 ...d mfloor("first")
 ...s matched=1
 .i matched q
 .i letter="b" d  q:matched
 ..i $$floor("basement") d  q
 ...i $$floor("ground") d  q
 ....d mfloor("ground")
 ....s matched=1
 ..i $$floor("ground") d  q
 ...i $$floor("first") d  q
 ....d mfloor("first")
 ....s matched=1
 ..i $$floor("first") d  q
 ...i $$floor("second") d  q
 ....d mfloor("second")
 ....s matched=1
 q matched
 
mfloor(term)       ;
 s floor=""
 for  s floor=$o(flatlist(floor)) q:floor=""  d
 .i floor[term d
 ..s uprn=$p(flatlist(floor),"~"),table=$p(flatlist(floor),"~",2),key=$p(flatlist(floor),"~",3)
 q
 
floor(term)        ;Scans for floor in a term
 n floor,found
 s floor="",found=0
 for  s floor=$o(flatlist(floor)) q:floor=""  d
 .i floor[term s found=1
 q found
 
fnsplit(tbno,bno,tflat,flat) ;Number includes flat
 n matched
 s matched=0
 i bno'="",tbno'="",flat=tbno,(tbno*1)=bno q 1 ;
 i flat?1l,$e(tbno,$l(tbno))=flat,bno=(tbno*1) b  q 1
 q 0
match11(tpost,tstreet,tbno,tbuild,tflat,lastchan) 
 ;Cycles through all uprns looking for fuzzy streets
 n matched,front,back,flatlist
 s matched=0
 s uprn=""
 for  s uprn=$O(^UPRN("X1",tpost,uprn)) q:uprn=""  d  q:$D(^TUPRN($J))
 .s table=""
 .for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  Q:$D(^TUPRN($J))
 ..s key=""
 ..for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  Q:$D(^TUPRN($J))
 ...s rec=^(key)
 ...s flat=$p(rec,"~",1),build=$p(rec,"~",2)
 ...s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
 ...s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
 ...I $g(lastchance) d  q
 ....i $$MPART^UPRNU(street,tstreet,1) d  q
 .....i bno'=tbno q
 .....s matched=$$match11a(uprn,table,key) Q
 ...i $$equiv^UPRNU(street,tstreet) d  q
 ....i bno'=tbno q
 ....s matched=$$match11a(uprn,table,key) Q
 ...I tbno="",tstreet'="" d
 ....i bno=$G(^UPRNS("NUMBERS",$p(tstreet," "))) d
 .....i street=$p(tstreet," ",2,10) d
 ......s tbno=bno
 ......s tstreet=street
 ...I bno'=tbno q
 ...s pstreet=$$PLURAL^UPRNU(street)
 ...i $$getfront^UPRNU(pstreet,tstreet,.front,.back) d  q
 ....s xbuild=$s(tbuild="":front,1:tbuild_" "_front)
 ....i build=xbuild d
 .....s matched=$$match11a(uprn,table,key)
 ...i $$getback^UPRNU(pstreet,tstreet,.back) d  q
 ....i back'="",$D(^UPRNS("ROAD",back)) d
 .....s matched=$$match11a(uprn,table,key)
 q matched
 
match11a(uprn,table,key)          ;from match11
 ;uses street
 ;bno,build,depth,flat already defined
 n matched
 s matched=0
 s $p(matchrec,",",2)="Sl"
 s $p(matchrec,",",3)="Ne"
 I tbuild=build,tflat=flat d  q 1
 .s $p(matchrec,",",4,5)="Be,Fe"
 .d set(uprn,table,key)
 .s matched=1
 .s ALG=ALG_"match11a"
 i tbuild'="",build'="" d  q $G(^TUPRN($J))
 .i $$equiv^UPRNU(build,tbuild) d
 ..s $p(matchrec,",",4)="Bl"
 ..s matched=$$match11b()
 .e  I $$MPART^UPRNU(build,tbuild,2) d
 ..s $p(matchrec,",",4)="Bp"
 ..s matched=$$match11b()
 i tbuild="",build="" d  q $G(^TUPRN($J))
 .s matched=$$match11b()
 I tbuild="",build'="" d
 .i $l(tflat," ")>2 d
 ..I $P(tflat," ",$l(tflat," ")-1,$l(tflat," "))?1n.n1" "1l d
 ...s tflat=$p(tflat," ",1,$l(tflat," ")-1)_$p(tflat," ",$l(tflat," "))
 ..i $p(tflat," ",$l(tflat," "))?1n.n.l d
 .i $$MPART^UPRNU(build,$p(tflat," ",1,$l(tflat," ")-1),1) d
 ..i $$mflat1($p(tflat," ",$l(tflat," ")),flat,.approx) d
 ...S matched=1
 ...s $p(matchrec,",",4,5)="Bp,F"_approx
 ...d set(uprn,table,key)
 ...s ALG=ALG_"match11e"
 q matched
 
match11b()          ;
 n matched,swapflat
 s matched=0
 ;matches flat
 i tflat="",flat="" d  Q 1
 .s $p(matchrec,",",5)="Fe"
 .d set(uprn,table,key)
 .set matched=1
 .s ALG=ALG_"match11b"
 s swapflat=tflat
 d swap^UPRNU(.swapflat)
 i flat[$p(swapflat," ") d  q 1
 .s $p(matchrec,",",5)="Fp"
 .d set(uprn,table,key)
 .set ALG=ALG_"match11c"
 i $$mflat1(tflat,flat,.approx) d
 .s $p(matchrec,",",5)="F"_approx
 .d set(uprn,table,key)
 .set matched=1
 .set ALG=ALG_"match11d"
 q matched
 
match17(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Number slipped into flat field
 i tbno="",tbuild="",tflat'="" d
 .i $p(tflat," ",$l(tflat," "))?1n.n.l d
 ..s tbno=$p(tflat," ",$l(tflat," "))
 ..s tflat=$p(tflat," ",0,$l(tflat," ")-1)
 ..s matches=$$match2(tpost,tstreet,tbno,tbuild,tflat)
 Q $G(^TUPRN($J))
 
 ;
match2c(tpost,tstreet,bno,tbuild,tflat)   ;Fuzzy buulding
 ;Unit stratford / unite building
 ;If build the same find nearest flat
 ;If building partial flat must match
 n build,flat
 s build=""
 for  s build=$O(^UPRN("X5",tpost,tstreet,bno,build)) q:build=""  d  q:$D(^TUPRN($J))
 .i ($$equiv^UPRNU(build,tbuild)) d  q
 ..s $p(matchrec,",",3,4)="Se,Bl"
 ..d match2ca
 .I $$MPART^UPRNU(build,tbuild,1) D  q
 ..s $p(matchrec,",",4)="Bp"
 ..D match2ca
 
 i $d(^TUPRN($J)) Q
 ;Try for sibling, child or parent flat
 s build=""
 for  s build=$O(^UPRN("X5",tpost,tstreet,bno,build)) q:build=""  d  q:$D(^TUPRN($J))
 .i ($$equiv^UPRNU(build,tbuild)) d  q
 ..s $p(matchrec,",",4)="Bl"
 ..d match2cb
 .I $$MPART^UPRNU(build,tbuild,1) D  q
 ..s $p(matchrec,",",4)="Bp"
 ..D match2cb
 q
 
match2ca          ;
 i $d(^UPRN("X5",post,tstreet,bno,build,tflat)) d  q
 .s $p(matchrec,",",5)="Fe"
 .S ALG=ALG_"match2ca"
 .d setuprns("X5",tpost,tstreet,bno,build,tflat)
 s flat=""
 for  s flat=$O(^UPRN("X5",tpost,tstreet,bno,build,flat)) q:flat=""  d  q:$d(^TUPRN($J))
 .i $$mflat1(tflat,flat,.approx) d
 ..s $p(matchrec,",",5)="F"_approx
 ..S ALG=ALG_"match2caa"
 ..d setuprns("X5",tpost,tstreet,bno,build,flat)
 q
 
match2cb ;Allows an approximation on flat
 i $$mflat(tpost,tstreet,tbno,build,tflat,.flat,.approx) d
 .s $p(matchrec,",",5)="F"_approx
 .d setuprns("X5",tpost,tstreet,tbno,build,flat)
 .S ALG=ALG_"match2cb"
 q
 
 ;
match2g(tpost,tstreet,tbno,null,adbuild)         ;
 ;Already matched on street, number and null building
 ;Matches on a flat, might have a fuzzy match
 n matched,flat
 s matched=0
 i $D(^UPRN("X5",tpost,tstreet,tbno,null,adbuild)) d
 .s $p(mathrec,",",4)="Be"
 .s $p(matchrec,",",5)="Fe"
 .d setuprns("X5",tpost,tstreet,bno,"",adbuild)
 .s ALG=ALG_"match2g"
 
 I $D(^TUPRN($J)) Q 1
 
 d swap^UPRNU(.tflat)
 s flat=$p(tflat," ")
 for  s flat=$o(^UPRN("X5",tpost,tstreet,tbno,"",flat)) q:flat=""  q:(flat'[$p(tflat," "))  d  q:matched
 .i $$equiv^UPRNU(flat,adbuild) d
 ..s $p(matchrec,",",4)="Be"
 ..s $p(matchrec,",",5)="Fl"
 ..d setuprns("X5",tpost,tstreet,bno,"",flat)
 ..s ALG=ALG_"match2h"
 ..s matched=1
 q matched
 
 ;
match15(tpost,tstreet,tbno,tbuild,tflat)          ;
 ;Suffix drop in number
 n matched
 s matched=0
 I $D(^UPRN("X5",tpost,tstreet)) d
 .s $p(matchrec,",",2)="Se"
 .i tbno?1l.l1n.n d  Q
 ..f i=1:1:$l(tbno) q:($e(tbno,i)?1n)
 ..s tbno=$e(tbno,i,i+4)
 ..i $D(^UPRN("X5",tpost,tstreet,tbno)) d
 ...I $d(^UPRN("X5",tpost,tstreet,tbno,tbuild,tflat)) d
 ....s $p(matchrec,",",3)="Np"
 ....s $p(matchrec,",",4,5)="Be,Fe"
 ....d setuprns("X5",tpost,tstreet,tbno,tbuild,tflat)
 ....s matched=1
 ....s ALG=ALG_"match15"
 .I tbno?4n d
 ..s xtbno=$e(tbno,1,2)_"-"_$e(tbno,3,4)
 ..I $D(^UPRN("X5",tpost,tstreet,xtbno,tbuild,tflat)) d
 ...s $p(matchrec,",",3)="Np"
 ...s $p(matchrec,",",4,5)="Be,Fe"
 ...d setuprns("X5",tpost,tstreet,xtbno,tbuild,tflat)
 ...s ALG=ALG_"match15a"
 q matched
 ;
match14(tpost,tstreet,tbno,tbuild,tflat,skipbld)          ;
 ;Alternative post codes
 s post=""
 for  s post=$O(^UPRN("X3",tstreet,tbno,post)) q:post=""  d  q:$G(^TUPRN($J))
 .q:post=tpost
 .S matchrec="Pi,Ne"
 .s build=""
 .for  s build=$O(^UPRN("X5",post,tstreet,tbno,build)) q:build=""  d  q:$G(^TUPRN($J))
 ..i $D(^UPRN("X5",post,tstreet,tbno,build,tflat)) D
 ...i build=tbuild d  q
 ....s $p(matchrec,",",4,5)="Be,Fe"
 ....d setuprns("X5",post,tstreet,tbno,tbuild,tflat)
 ....s ALG=ALG_"match14"
 ...i $g(skipbld)'="" d
 ....s $p(matchrec,",",4,5)="Bi,Fe"
 ....d setuprns("X5",post,tstreet,tbno,build,tflat)
 ....s ALG=ALG_"match14b"
 ...I $$MPART^UPRNU(build,tbuild,1) d
 ....S $p(matchrec,",",4,5)="Bp,Fe"
 ....d setuprns("X5",post,tstreet,tbno,build,tflat)
 ....s ALG=ALG_"match14a"
 Q $G(^TUPRN($J))
 
 ;
match19(tpost,tstreet,tbno,tbuild,tflat) 
 ;Running our of options
 ;Assumes a rough match on the number but degrades flat and building
 
 n bno,build,street,bno,flat,matched
 s matched=0
 I '$$mno(tpost,tstreet,tbno,.bno) Q 0
 s $p(matchrec,",",3)="Ne"
 i tbuild'="",tflat'="" d
 .I $D(^UPRN("X5",tpost,tstreet,bno,"","")) d
 ..s $p(matchrec,",",4,5)="Bd,Fd"
 ..d setuprns("X5",tpost,tstreet,bno,"","")
 ..s ALG=ALG_"match19"
 Q $G(^TUPRN($J))
matchall(indrec)   ;
 i $D(^UPRN("X",indrec)) d  Q $G(^TUPRN($J))
 .S ALG="1-match"
 .d setuprns("X",indrec)
 i adplural d
 .i $D(^UPRN("X",indprec)) d
 ..S ALG="1-match"
 ..d setuprns("X",indprec)
 Q $D(^TUPRN($J))
 
match1(tpost,tstreet,tbno,tbuild,tflat) 
 ;Match algorithms on a post code and street
 n matches
  
 ;Full 5 field match
 i $d(^UPRN("X5",tpost,tstreet,tbno,tbuild,tflat)) d  q $G(^TUPRN($J))
 .s matchrec=$P(matchrec,",",1,2)_",Ne,Be,Fe"
 .s ALG=ALG_"match1"
 .d setuprns("X5",tpost,tstreet,tbno,tbuild,tflat)
 Q $D(^TUPRN($J))
 
match2(tpost,tstreet,tbno,tbuild,tflat) 
 ;Assumes a match on the number
 
 n bno,build,street,bno,flat,matched
 s matched=0
 
 
 ;First match post, street and number
 I '$$mno(tpost,tstreet,tbno,.bno) Q 0
 s $p(matchrec,",",3)="Ne"
 
 ;Match building and flat ?
 I $D(^UPRN("X5",tpost,tstreet,bno,tbuild)) d  q 1
 .s $p(matchrec,",",4)="Be"
 .i $$mflat(tpost,tstreet,bno,tbuild,tflat,.flat,.approx) d  q
 ..s $p(matchrec,",",5)="F"_approx
 ..s ALG=ALG_"match2a"
 ..d setuprns("X5",tpost,tstreet,bno,tbuild,flat)
 .i $D(^UPRN("X5",tpost,tstreet,bno,tbuild,"")) d
 ..i $$fbno(bno,tflat) d
 ...s $p(matchrec,",",5)="Fe"
 ..e  d
 ...s $p(matchrec,",",5)="Fc"
 ..s ALG=ALG_"match2b"
 ..d setuprns("X5",tpost,tstreet,bno,tbuild,"")
 
 I $D(^TUPRN($J)) Q 1
 
 ;Discovery missing the number
 i tbno="",tbuild'="",tflat'="",tstreet'="" d
 .i $g(adostreet)="" q
 .s num=$O(^UPRN("X5A",tpost,adstreet,adbuild,tflat,""))
 .i num'="" d
 ..s $p(matchrec,",",2,5)="Se,Ni,Be,Fe"
 ..s ALG=ALG_"match2c"
 ..d setuprns("X5A",tpost,tstreet,tbuild,tflat,num)
 
 ;Try building Levenstein and partial match
 
 d match2c(tpost,tstreet,bno,tbuild,tflat)
 
 i $D(^TUPRN($J)) Q 1 
 
 ;Possible building in flat field
 s ALG=ALG_"match2d"
 i tbuild="",$l(tflat," ")>2 d
 .I $P(tflat," ",$l(tflat," ")-1,$l(tflat," "))?1n.n1" "1l d
 ..s tflat=$p(tflat," ",1,$l(tflat," ")-1)_$p(tflat," ",$l(tflat," "))
 .i $p(tflat," ",$l(tflat," "))?1n.n.l d
 ..d match2c(tpost,tstreet,bno,$p(tflat," ",1,$l(tflat," ")-1),$p(tflat," ",$l(tflat," ")))
 ..i $D(^TUPRN($J)) B  Q
 s ALG=$P(ALG,"-")_"-"
 
 i $D(^TUPRN($J)) Q 1 
 
 
 
 ;Drop building or check for weird flat/building 
 ;Windy hill, 117 hermon hill, no flat, drop building
 ;Use original building if being used in flat field
 i $D(^UPRN("X5",tpost,tstreet,bno,"")) d
 .i tflat="",tbuild'="" I $$match2g(tpost,tstreet,bno,"",adbuild) q
 .s $p(matchrec,",",4)="Bd"
 .I $$mflat(tpost,tstreet,bno,"",tflat,.flat,.approx) d
 ..s $p(matchrec,",",5)="F"_approx
 ..d setuprns("X5",tpost,tstreet,bno,"",flat)
 ..s ALG=ALG_"match2e"
 
 i $d(^TUPRN($J)) Q 1
 
 
6 ;Ignore building
 i tbuild="" d
 .I tbno="",tflat="",tbuild="" q
 .s $p(matchrec,",",4)="Ba"
 .s build=""
 .for  s build=$O(^UPRN("X5",tpost,tstreet,bno,build)) q:build=""  d  q:$g(^TUPRN($J))
 ..i $D(^UPRN("X5",tpost,tstreet,bno,build,tflat)) d
 ...s $p(matchrec,",",5)="Fe"
 ...d setuprns("X5",tpost,tstreet,bno,build,tflat)
 ...s ALG=ALG_"match2f"
 .I $d(^TUPRN($J)) Q
 .s $p(matchrec,",",4)="Ba"
 .s build=""
 .for  s build=$O(^UPRN("X5",tpost,tstreet,bno,build)) q:build=""  d  q:$G(^TUPRN($J))
 ..I $$mflat(tpost,tstreet,bno,build,tflat,.flat,.approx) d
 ...s $p(matchrec,",",5)="F"_approx
 ...d setuprns("X5",tpost,tstreet,bno,build,flat)
 ...s ALG=ALG_"match2fa"
 
7 ;Finally building name ok but won't match
 i tbuild'="",tbno'="" d
 .s build=""
 .for  s build=$O(^UPRN("X5",tpost,tstreet,bno,build)) q:build=""  d  q:matched
 ..I $D(^UPRN("X5",tpost,tstreet,bno,build,tflat)) d
 ...s $p(matchrec,",",4)="Bi"
 ...s $p(matchrec,",",5)="Fe"
 ...d setuprns("X5",tpost,tstreet,bno,build,tflat)
 ...s matched=1
 ...s ALG=ALG_"match2fb"
 Q $G(^TUPRN($J))
 
 
 
mno(tpost,tstreet,tbno,bno)      ;
 ;Matches two numbers
 N matched
 s matched=0
 I $D(^UPRN("X5",tpost,tstreet,tbno)) s bno=tbno q 1
 S tbno=$tr(tbno,"/","-")
 i tbno["-" d
 .n no
 .f no=$p(tbno,"-",1):1:$p(tbno,"-",2) d  q:matched
 ..i $D(^UPRN("X5",tpost,tstreet,no)) d
 ...s bno=no
 ...s matched=1
 q matched
 
match3(tpost,tstreet,tbno,tbuild,tflat)          ;Try from building and flat
 ;Matches using building and flat
 n street,bno,build,flat
 I '$D(^UPRN("X3",tbuild,tflat,tpost)) q 0
 s uprn=""
 for  s uprn=$O(^UPRN("X3",tbuild,tflat,tpost,uprn)) q:uprn=""  d  Q:matched
 .s table=""
 .for  s table=$O(^UPRN("X3",tbuild,tflat,tpost,uprn,table)) q:table=""  d  Q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("X3",tbuild,tflat,tpost,uprn,table,key)) q:key=""  d  q:matched
 ...D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.lpost,.org)
 ...S $p(matchrec,",",2)=""
 ...I street=tstreet d
 ....s $p(matchrec,",",2)="Se"
 ...e  d
 ....I $$equiv^UPRNU(street,tstreet) d  q
 .....s $p(matchrec,",",2)="Sl"
 ....E  d
 .....I $$MPART^UPRNU(street,tstreet,1) d
 ......s $p(matchec,",",2)="Sp"
 ...i $p(matchrec,",",2)="" q
 ...s $p(matchrec,",",3)="Ni"
 ...i $$mno1(tbno,bno,.approx) d
 ....s $p(matchrec,",",3)="N"_approx
 ...s ALG=ALG_"match3"
 ...d set(uprn,table,key)
 ...s matched=1
 i $D(^TUPRN($J)) q $G(^TUPRN($J))
 s street=""
 for  s street=$O(^UPRN("X5",tpost,street)) q:street=""  d  q:matched
 .I $D(^UPRN("X5",tpost,street,tbno,tbuild,tflat)) d  q
 ..S $p(matchrec,",",2,3)="Si,Ne"
 ..d setuprns("X5",tpost,street,tbno,tbuild,tflat)
 ..s ALG=ALG_"match3a"
 ..s matched=1
 i $G(^TUPRN($J)) Q $G(^TUPRN($J))
 s street=""
 for  s street=$O(^UPRN("X5",tpost,street)) q:street=""  d  q:matched
 .s bno=""
 .for  s bno=$O(^UPRN("X5",tpost,street,bno)) q:bno=""  d
 ..I $D(^UPRN("X5",tpost,street,bno,tbuild,tflat)) d
 ...s $p(matchrec,",",2,3)="Si,Ni"
 ...d setuprns("X5",tpost,street,bno,tbuild,tflat)
 ...s $p(ALG,"-",2)="match3b"
 ...s matched=1
 Q $G(^TUPRN($J))
 
 
match4(tpost,tstreet,tbno,tbuild,tflat)          ;Try swapping flat and building
 ;Only swap if flat doesnt exist
 i $D(^UPRN("X3",tbuild,tflat)) q 0
 s matches=$$match1(tpost,tstreet,tflat,tbuild,tbno)
 Q $G(^TUPRN($J))
 
match5(tpost,tstreet,tbno,tbuild,tflat)          ;parse for street
 n strlen,i,build
 s strlen=$l(tstreet," ")
 i tbuild="" d
 .f i=strlen-1:-1:1 do
 ..s street=$p(tstreet," ",i,strlen)
 ..s build=$p(tstreet," ",0,i-1)
 ..I $D(^UPRN("X5",tpost,street,"",build,tbno)) d
 ...s $p(matchrec,",",3)="Ne"
 ...s $p(matchrec,",",4)="Be"
 ...s $p(matchrec,",",5)="Fe" d
 ...d setuprns("X5",tpost,street,"",build,tbno)
 ...s ALG=ALG_"match5"
 q $G(^TUPRN($J))
 
match24(tpost,tstreet,tbno,tbuild,tflat) 
 ;run through for  sibling numbers
 n matched,front,back
 s matched=0
 s uprn=""
 for  s uprn=$O(^UPRN("X1",tpost,uprn)) q:uprn=""  d  q:matched
 .s table=""
 .for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  q:matched
 ...s rec=^(key)
 ...s flat=$p(rec,"~",1),build=$p(rec,"~",2)
 ...s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
 ...s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
 ...i street=tstreet,build=tbuild,flat=tflat d
 ....i tbno?1n.n,bno?1n.n1l d
 .....i (bno*1)=(tbno*1) d
 ......s $p(matchrec,",",2,5)="Se,Nis,Be,Fe"
 ......d set(uprn,table,key)
 ......s ALG=ALG_"match24"
 ......s matched=1
 ....i tbno?1n.n1l,bno?1n.n d
 .....i (bno*1)=(tbno*1) d
 ......s $p(matchrec,",",2,5)="Se,Nds,Be,Fe"
 ......d set(uprn,table,key)
 ......s ALG=ALG_"match24a"
 ......s matched=1
 Q $D(^TUPRN($J))
 
match25(tpost,tstreet,tbno,tbuild,tflat) 
 ;Swap flat into number, parse flat out of building
 ;Accept wrong post code
 i $d(^UPRN("X3",tstreet,tflat)) d
 .i $p(tbuild,"flat ",2)?1n.n.l d
 ..s tbno=tflat
 ..s tflat=$p(tbuild,"flat ",2)
 ..s tbuild=$p(tbuild," flat",1)
 ..B
 ..s post=""
 ..for  s post=$O(^UPRN("X3",tstreet,tbno,post)) q:post=""  d  Q:$G(^TUPRN($J))
 ...s $p(matchrec,",",1)=""
 ...i post=tpost d
 ....s $p(matchrec,",",1)="Pe"
 ...e  d
 ....i $e(post,1,$l(adpost))=adpost d
 .....s $p(matchrec,",",1)="Pp"
 ....E  D
 .....i $$levensh^UPRNU(post,adpost,5) d
 ......s $p(matchrec,",",1)="Pl"
 .....E  D
 ......i $e(post,1,3)=$e(adpost,1,3) D
 .......s $p(matchrec,",",1)="Pp"
 ...I $p(matchrec,",",1)="" q
 ...i $$match1(post,tstreet,tbno,tbuild,tflat) q
 q $G(^TUPRN($J))
 
 
match26(tpost,tstreet,tbno,tbuild,tflat) 
 ;Lonshot match for this post code, ignore number
 n matched,front,back
 k flatlist
 s matched=0
 s matchrec="Pe"
 s uprn=""
 for  s uprn=$O(^UPRN("X1",tpost,uprn)) q:uprn=""  d  q:matched
 .s table=""
 .for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d  q:matched
 ..s key=""
 ..for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d  q:matched
 ...s rec=^(key)
 ...s flat=$p(rec,"~",1),build=$p(rec,"~",2)
 ...s bno=$p(rec,"~",3),depth=$p(rec,"~",4)
 ...s street=$p(rec,"~",5),deploc=$p(rec,"~",6)
 ...S loc=$p(rec,"~",7),town=$p(rec,"~",8)
 ...i tbno="",bno'="",tflat=flat D
 ....s $p(matchrec,",",3)="Ni"
 ....s $p(matchrec,",",5)="Fe"
 ....I $$equiv^UPRNU(street,tstreet,5,2) d
 .....I $$equiv^UPRNU(build,tbuild,5,3) d
 ......s $p(matchrec,",",1)="Sl"
 ......s $p(matchrec,",",4)="Bp"
 ......d set(uprn,table,key)
 ......S ALG=ALG_"match26"
 ......s matched=1
 Q $g(^TUPRN($J))
 
match27(tpost,tstreet,tbno,tbuild,tflat) 
 i tstreet="" q 0
 i $$isroad^UPRNA(tstreet),$$isroad^UPRNA(tbuild) d
 .I '$D(^UPRN("X5",tpost,tbuild,tflat)) q
 .I $d(^UPRN("X5",tpost,tbuild,tflat,"","")) d
 ..s ALG=ALG_"match27"
 ..s $p(matchrec,",",2,5)="Se,Ne,Bd,Fd"
 ..d setuprns("X5",tpost,tbuild,tflat,"","")
 Q $G(^TUPRN($J))
 
 
match28(tpost,tstreet,tbno,tbuild,tflat) 
 ;Strips out flat and building
 s tflat=tbno,tbno=""
 n i,t1,t2
 f i=1:1:$l(tstreet," ") d  q:$G(^TUPRN($J))
 .s t1=$p(tstreet," ",1,i)
 .I $D(^UPRN("X3",t1,tflat)) d
 ..s t2=$p(tstreet," ",i+1,20)
 ..s matches=$$match7(tpost,t2,"",t1,tflat)
 q $G(^TUPRN($J))
 
setuprns(index,n1,n2,n3,n4,n5) 
 n uprn,table,key
 s (uprn,table,key)=""
 i index="X" d
 .for  s uprn=$O(^UPRN(index,n1,uprn)) q:uprn=""  d
 ..for  s table=$O(^UPRN(index,n1,uprn,table)) q:table=""  d
 ...for  s key=$O(^UPRN(index,n1,uprn,table,key)) q:key=""  d
 ....d set(uprn,table,key)
 
 i index["X5" d
 .for  s uprn=$O(^UPRN(index,n1,n2,n3,n4,n5,uprn)) q:uprn=""  d
 ..for  s table=$O(^UPRN(index,n1,n2,n3,n4,n5,uprn,table)) q:table=""  d
 ...for  s key=$O(^UPRN(index,n1,n2,n3,n4,n5,uprn,table,key)) q:key=""  d
 ....d set(uprn,table,key)
 i index="X3"!(index="X3") d
 .for  s uprn=$O(^UPRN(index,n1,n2,n3,uprn)) q:uprn=""  d
 ..for  s table=$O(^UPRN(index,n1,n2,n3,uprn,table)) q:table=""  d
 ...for  s key=$O(^UPRN(index,n1,n2,n3,uprn,table,key)) q:key=""  d
 ....d set(uprn,table,key)
 q
set(uprn,table,key) ;
 i '$D(^TUPRN($J,uprn)) d
 .S ^TUPRN=$g(^TUPRN($J))+1
 s ^TUPRN($J,uprn,table,key)=matchrec
 q
 
 
 
nearest(test,before,after)    ;Returns the nearest number
 N nearest
 s nearest(test)=""
 i before'="" d
 .s nearest(before)=""
 i after'="" d
 .s nearest(after)=""
 i $o(nearest(test))="" q before
 i $o(nearest(test),-1)="" q after
 i after-test<(test-before) q after
 q before
 
 
 
mflat(tpost,tstreet,tbno,tbuild,tflat,flat,approx)         ;
 N matched
 s matched=0
 
 ;null flat match
 i tflat="",$D(^UPRN("X5",tpost,tstreet,tbno,tbuild,"")) d
 .s approx="e"
 .s matched=1
 .s flat=""
 i matched q 1
 
 ;Fuzzy flat match
 i tflat?1n.n1" "1l.e d
 .I $D(^UPRN("X5",tpost,tstreet,tbno,tbuild,tflat*1)) d
 ..s flat=tflat*1
 ..s approx="p"
 ..s matched=1
 i matched q matched
 
 i tflat?1l.l.e d
 .s flat=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,$p(tflat," ")))
 .i flat[tflat d  q
 ..s approx="p"
 ..s matched=1
 .d swap^UPRNU(.tflat)
 .s flat=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,$p(tflat," ")))
 .i flat[$P(tflat," ") d
 ..S approx="p"
 ..s matched=1
 
 i matched q 1
 ;Cycles through flats
 s flat=""
 for  s flat=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,flat)) q:flat=""  d  q:matched
 .i $$mflat1(tflat,flat,.approx) D  q
 ..s matched=1
 i matched q matched
 
 i tflat?1n.n d
 .s near1=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,tflat),-1)
 .s near2=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,tflat))
 .s near=$$nearest(tflat,near1,near2)
 .i near'="" d  q
 ..S flat=near
 ..s matched=1
 ..s approx="s"
 .i near="" d  q
 ..s matched=1
 ..s flat=""
 ..s approx="c"
 
 ;Must be a parent approximation
 I 'matched,tflat="" d
 .s approx="a"
 .s matched=1
 .S flat=$O(^UPRN("X5",tpost,tstreet,tbno,tbuild,""))
 q matched
 
mflat1(tflat,flat,approx) ;Matches two flats
 n matched,tflatno
 s matched=0
 
 ;5-6
 i flat["-" d
 .i tflat=$p(flat,"-")!(tflat=$p(flat,"-",2)) d
 ..s matched=1
 ..s approx="e"
 .i tflat<$p(flat,"-")!(tflat<$p(flat,"-",2)) d
 ..s matched=1
 ..s approx="e"
 i matched q 1
 
 ;workshop 6
 i $p(tflat," ",$l(tflat," "))?1n.n.l d
 .set tflatno=$p(tflat," ",$l(tflat," "))
 .if tflatno=flat d
 ..s approx="e"
 ..s matched=1
 i matched q 1
 
 ;flat 6 f
 s tflat=$tr(tflat," "),flat=$tr(flat," ")
 
 ;3c to 4
 i tflat?1n.n.1l,flat?1n.n,(flat*1=(tflat*1)) d
 .s matched=1
 .s approx="ds"
 i tflat?1n.n,(flat*1)=tflat*1 d
 .s matched=1
 .s approx="is"
 
        
 
 q matched
mflat2(flat,tflat) ;Matches 2 flats fuzzy match
 n matched
 s matched=0
 i flat=""!(tflat="") q 0
 s flat=$$flat^UPRNU(flat)
 i tflat?1n.n!(tflat?1n.n1l) d
 .i flat[tflat s matched=1
 q matched
 
mno1(tbno,bno,approx) ;Matches two numbers
 n matched
 s matched=0
 s approx="e"
 i tbno=bno q 1
 ;94a to 94
 i tbno?1n.n1l,bno?1n.n,(bno*1=(tbno*1)) d
 .s matched=1
 .s approx="ds"
 i tbno?1n.n,(bno*1)=tbno*1 d
 .s matched=1
 .s approx="is"
 i tbno?1n.n1"-"1n.n d
 .i bno?1n.n1"-"1n.n d  q
 ..i $p(tbno,"-")'<$p(bno,"-") d
 ...i $p(tbno,"-",2)'>$p(bno,"-",2) d
 ....s matched=1
 .i bno'<$p(tbno,"-"),bno'>$p(tbno,"-",2) d
 ..s matched=1
 q matched
 
nomatch ;
 ;Exception
 i adstreet?1l.l,adbno="",adbuild="",adflat="" d  q
 .s impossible=impossible+1
 .s ^UPRN1(adrec)=""
 S unmatched=unmatched+1
 S ^UPRN("UM",adno)=""
 if UI D
 .W !,"total so far=",total
 .W !!!,"No match"
 .W !,adrec
 .d ^EXP
 .w !,"Ignore (i):" r ignore
 .i $$lc^UPRNL(ignore)="i" d
 ..s ^UPRN1(adrec)=""
 q
 
matched ;
 n table,key,ui
 set mcount=mcount+1
 I ^TUPRN>1 D filter
 s ui=$G(UI,2)
 
 
 ;Clear the match results
 ;i $D(^UPRN("UM",adno)) d
 ;.s ui=3
 ;i ALG["match2k-" s ui=2
 
 K ^UPRN("UM",adno)
 K ^UPRN("M",adno)
 I ui>1 D
 .w !!,"Matched"
 .w "  "_ALG
 .w !,"M: "_address
 S uprn=""
 for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 .i ui>1 d
 ..f table="DPA","LPI" d
 ...s abkey=""
 ...for  s abkey=$O(^UPRN(table,uprn,abkey)) q:abkey=""  d
 ....w !,uprn," ",table,": ",^(abkey)
 .s table=""
 .for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ..s key=""
 ..for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ...s matchrec=^(key)
 ...I table="D",$p(matchrec,",",4)="Bd" d
 ....I adbuild'="" d
 ....i $P(^UPRN("U",uprn,table,key),"~",10)=adbuild d
 .....s $p(matchrec,",",4)="Be"
 ...S ^UPRN("M",adno,uprn,table,key)=matchrec
 ...S ^UPRN("M",adno,uprn,table,key,"A")=ALG
 ...I ui>1 D
 ....w !,uprn," ",table_": "_^UPRN("U",uprn,table,key)
 ....w ?65,matchrec
 ....i table="L" D
 .....w !,uprn," ","LPI : "_^UPRN("LPI",uprn,key)
 ....i table="D" d
 .....W !,uprn," ","DPA : "_^UPRN("DPA",uprn,key)
 I $G(^TUPRN($J))>1 D
 .W *7,!,"Multiple matches"
 .r t
 I ui=2 r t
 q
 
filter ;Filter
 n uprn,key,preferred,exact
 ;
 ;Tries to match on organisation
 ;Gets as many as possible with matches
 f i=0:1:4 d  q:(^TUPRN=1)
 .d fexact(i)
 i ^TUPRN=1 Q
 
 n current
 s current=""
 ;Gets nearest match
 n nearcount
 s nearest=""
 f i=1:1:4 d
 .s uprn="",key=""
 .for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 ..s table=""
 ..for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ...s key=""
 ...for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ....s matchrec=^(key)
 ....i $e($p(matchrec,",",i),2)="e" d
 .....s nearest=uprn_"~"_table_"~"_key
 .....i table="L" d
 ......I $P(^UPRN("LPI",uprn,key),"~",12)=1 d
 .......s current=uprn_"~"_table_"~"_key
 I current'="" d  q
 .s matchrec=^TUPRN($J,$p(current,"~"),$p(current,"~",2),$p(current,"~",3))
 .K ^TUPRN
 .s uprn=$p(current,"~"),table=$p(current,"~",2),key=$p(current,"~",3)
 .S ^TUPRN($J,uprn,table,key)=matchrec
 .S ^TUPRN=1
 
 i nearest'="" d
 .s matchrec=^TUPRN($J,$p(nearest,"~"),$p(nearest,"~",2),$p(nearest,"~",3))
 .K ^TUPRN
 .s uprn=$p(nearest,"~"),table=$p(nearest,"~",2),key=$p(nearest,"~",3)
 .S ^TUPRN($J,uprn,table,key)=matchrec
 .S ^TUPRN=1
 Q
 Q
fexact(mfield)     ;Filters out if possible
 n preferred
 s preferred=0
 s uprn="",key=""
 for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 .s table=""
 .for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ..for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ...s matchrec=^(key)
 ...I $p(matchrec,"~",5)="Fe" d
 ....i table="D" d
 .....s org=$p(^UPRN("U",uprn,table,key),"~",10)
 .....i org'="",org=adflat,$p(matchrec,"~",5)="Fe" d
 ......s $p(matchrec,",",5)="Fe"
 ......s ^TUPRN($J,uprn,table,key)=matchrec
 ...i mfield=0,matchrec="Pe,Se,Ne,Be,Fe" d
 ....s preferred=1
 ....s preferred(uprn,table,key)=""
 ...i mfield>0,$e($p(matchrec,"~",mfield),2)="e" do
 ....s preferred=1
 ....s preferred(uprn,table,key)=""
 i preferred do
 .s (uprn,key)=""
 .for  s uprn=$O(^TUPRN($J,uprn)) q:uprn=""  d
 ..for  s table=$O(^TUPRN($J,uprn,table)) q:table=""  d
 ...for  s key=$O(^TUPRN($J,uprn,table,key)) q:key=""  d
 ....i '$d(preferred(uprn,table,key)) d
 .....K ^TUPRN($J,uprn,table,key)
 .....I '$D(^TUPRN($J,uprn)) s ^TUPRN=^TUPRN-1
 q
 Q
 
 Q
 
ONE ;
 D SETSWAPS^UPRNU
 set d="~"
 s qpost=^QPOST
 set total=0,mcount=0,unmatched=0
 D tomatch(adno)
 Q
 ;
 ;
clrvars ;Resetset the flags
 S WRONGPOST=""
 S SUFFIGNORE=""
 S FLATNC="",SUPRA=""
 S NUMSTREET=""
 s ALG=""
 s FIELDS=""
 
 S FLAT="",PLURAL="",DROP="",CORRECT=""
 S SWAP="",DUPL="",SUB="",SIMILAR="",PARTIAL=""
 S ANDLPI="",FIRSTPART="",LEVENOK="",SIBLING="",SUPRA=""
 S SUFFDROP="",SUBFLATI="",SUBFLATD=""
 Q
 
