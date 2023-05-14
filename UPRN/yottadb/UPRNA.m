UPRNA ;Address dformat [ 05/14/2023  10:50 AM ]
 ;
reformat(adrec,address)    ;
 s reformed=0
 ;Drop room
 I $p(address,"~")?1"room "1ln1" "1n.n.l1" ".e d
 .s $p(adrec,"~",1)=$p($p(adrec,"~",1)," ",3,20)
 .d format(adrec,.address)
 .s reformed=1
 e  i $p(address,"~")?1"room "1ln d
 .i $p(address,"~",2)?1n.n.l1" ".l.e d
 ..s adrec=$p(adrec,"~",2,20)
 ..d format(adrec,.address)
 ..s reformed=1
 e  i $p(address,"~",2)?1"flat "1n.n.e d
 .i $p(address,"~")?1n.n.l1" ".e d
 ..s address("flat")=$p($p(address,"~",2)," ",2)
 ..s address("number")=$p(address," ")
 ..s address("building")=$p($p(address,"~")," ",2,20)
 ..s address("street")=$p($p(address,"~",2)," ",3,20)
 ..s reformed=1
 q reformed
 q
 
format(adrec,address)    ; ;[ 05/11/2023  12:33 PM ]
 ;Populates the discovery address object
 ;initialise address field variabls
 k address
 n d,tempadd
 s d="~"
 set adflat=""
 set adbuild=""
 set adbno=""
 set adepth=""
 set adeploc=""
 set adstreet=""
 set adloc=""
 set post=""
 set tempadd=""
 ;remove london
 
 
 ;Lower case the address, remove characterset /. double spaces
 set d="~" ;field delimiter is ~
 set address=$$lc^UPRNL(adrec)
 set address=$tr(address,","," ")
 set address=$tr(address,"',")
 set address=$tr(address,"/","-")
 s ISFLAT=0
 I address?1"flat"1" "1n.n.l1" ".e d
 .S ISFLAT=1
 .I $P(address," ",3)?1n.n.e d
 ..s address=$p(address," ",1,2)_"~"_$p(address," ",3,20)
 i address["." d
 .f i=1:1:$l(address," ") d
 ..s word=$p(address," ",i)
 ..I word["." d
 ...i word?1n.n1"."1n.n.e!(word?1n.n1"."1l1n.n) d
 ....s $p(address," ",i)=$tr(word,".","-")
 set address=$tr(address,"."," ")
 set address=$tr(address,"*"," ")
 set address=$$tr^UPRNL(address,"  "," ")
 set address=$$tr^UPRNL(address,"~ ","~")
f1 d spelchk(.address)
 
 
 ;get the post code from the last field
 set length=$length(address,d)
 set post=$$lc^UPRNL($p(address,d,length))
 set post=$tr(post," ") ;Remove spaces
 
 i '$$validp^UPRN(post) do
 .S p=""
 .F i=$l(address)-10:1:$l(address) s p=p_$e(address,i)
 .S x=$$TR^LIB($p(p," ",$l(p," ")-1,$l(p," "))," ","")
 .I $$validp^UPRN(x) s post=x quit
 .s x=$p(p," ",$l(p," "))
 .I $$validp^UPRN(x) s post=x
 .quit
 
 i $D(^UPRNS("TOWN",post)) s post=""
 
 ;Try to find how many address lines and which is which
 ;Use lines before the city if present
 ;addlines is number of address lines to format
 ;
 set addlines=0
 ;remove london,middlesex
 s tempadd=""
f2 F i=1:1:(length-1) d
 .s part=$p(address,d,i)
 .q:part=""
 .i $D(^UPRNS("CITY",part)) q
 .I $D(^UPRNS("COUNTY",part)) q
 .I $D(^UPRNS("COUNTY",$p(part," ",$l(part," ")))) d
 ..S part=$p(part," ",1,$l(part," ")-1)
 .i $d(^UPRNS("CITY",$p(part," ",$l(part," ")))) D
 ..S part=$p(part," ",1,$l(part," ")-1)
 .s tempadd=tempadd_$s(tempadd="":part,1:"~"_part)
 s address=tempadd_"~"_post
 S addlines=$l(address,"~")-1
 
f3 ;too many address lines may be duplicate post code
 i addlines>2 d
 .f i=2:1:addlines d
 ..I $D(^UPRNX("X5",$tr($p(address,d,i)," "))) d
 ...s post=$tr($p(address,d,i)," ")
 ...s addlines=i-1
 ...s address=$p(address,d,1,addlines+1)
 
f4 ;may have too many address lines number is alone in field 1
 I addlines>2 d
 .i $p(address,d,1)?1n.n."-".n,$p(address,d,2)?1l.e d
 ..s $p(address,d,1)=$p(address,d,1)_" "_$p(address,d,2)
 ..s address=$p(address,d,1)_d_$p(address,d,3,10)
 ..s addlines=addlines-1
 
f5 ;Still too many, number s alone in field 2
 i addlines>2 d
 .i $p(address,d,2)?1n.n,$p(address,d,3)?1l.e d
 ..s $p(address,d,2)=$p(address,d,2)_" "_$p(address,d,3)
 ..s address=$p(address,d,1,2)_d_$p(address,d,4,10)
 ..s addlines=addlines-1
 
f6 ;Duplicate street?
 i addlines>2 d
 .i $p($p(address,d,2)," ",2,10)=$p(address,d,3) d
 ..s address=$p(address,d,1,2)_"~"_$p(address,d,4,10)
 ..s addlines=addlines-1
 
 
f7 ;Initialise address line variabs
 ;flat and building is line 1, number and street is line 2
 i addlines=1 d
 .s adbuild=""
 .s adstreet=$p(address,d,1)
 .s strfound=0
 .n last
 .i $l(adstreet," ")>1 d
 ..s lenstr=$l(adstreet," ")
 ..f i=1:1:lenstr d  q:strfound
f8 ...i $D(^UPRNX("X.STR",$p(adstreet," ",i,lenstr))) d
 ....s strfound=1
 ....i $p(adstreet," ",i-1)?1n.n.l d
 .....i ISFLAT D  q
 ......s adflat=$p(adstreet," ",1,2)
 ......s adstreet=$p(adstreet," ",3,$l(adstreet," "))
 .....s adbuild=$p(adstreet," ",0,i-2)
 .....s adstreet=$p(adstreet," ",i-1,lenstr)
 .....s last=$p(adbuild," ",$l(adbuild," "))
 .....i last["-" d
 ......i last?1n.n1"-" d  q
 .......s adstreet=last_adstreet
 .......s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 ......i last="-" d
 .......i $p(adbuild," ",$l(adbuild," ")-1)?1n.n.l d
 ........s adstreet=$p(adbuild," ",$l(adbuild," ")-1)_"-"_adstreet
 ........s adbuild=$p(adbuild," ",0,$l(adbuild," ")-2)
 ....e  d
 .....s adbuild=$p(adstreet," ",0,i-1)
 .....s adstreet=$p(adstreet," ",i,lenstr)
f9 .i adstreet?1l.e d
 ..f i=1:1:$l(adstreet," ") q:(adbuild'="")  d
 ...i $p(adstreet," ",i)?1n.n.l d
 ....i $p(adstreet," ",i+1)?1n.n.l d  q
 .....s adbuild=$p(adstreet," ",1,i)
 .....s adstreet=$p(adstreet," ",i+1,20)
 ....s adbuild=$p(adstreet," ",1,i-1),adstreet=$p(adstreet," ",i,20)
 ....s last=$p(adbuild," ",$l(adbuild," "))
 ....i last["-" d
 .....i last?1n.n1"-" d  q
 ......s adstreet=last_adstreet
 ......s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 
f10 i addlines=2 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .i adstreet?1n.n,adbuild'="" d
 ..s adstreet=adstreet_" "_adbuild
 ..s adbuild=""
f11 i addlines=3 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .s adloc=$p(address,d,3)
f12 i addlines=4 d
 .s adbuild=$p(address,d,1)
 .s adstreet=$p(address,d,2)
 .s adeploc=$p(address,d,3)
 .s adloc=$p(address,d,4)
f13 i addlines=5 d
 .s adbuild=$p(address,d,1)
 .s adepth=$p(address,d,2)
 .s adstreet=$p(address,d,3)
 .s adeploc=$p(address,d,4)
 .s adloc=$p(address,d,5)
f14 i addlines=6 d
 .s adbuild=$p(address,d,1)_" "_$p(address,d,2)
 .s adepth=$p(address,d,3)
 .s adstreet=$p(address,d,4)
 .s adeploc=$p(address,d,5)
 .s adloc=$p(address,d,6)
 .;.s adepth=$p(address,d,3)
 .;.s adeploc=$p(address,d,4)
 .;.s adloc=$p(address,d,5)
 .;.i adepth?1n.n!(adepth?1n.n1),adeploc'="" d
 .;..s adbuild=adbuild_" "_adstreet
 .;..s adstreet=adepth_" "_adeploc
 .;..s adepth="",adeploc=""
f15 i addlines=7 d
 .s adbuild=$p(address,d,1)_" "_$p(address,d,2)
 .s adepth=$p(address,d,3)
 .s adstreet=$p(address,d,4)_" "_$p(address,d,5)
 .s adeploc=$p(address,d,6)
 .s adloc=$p(address,d,7)
f16 f var="adbuild","adstreet","adepth","adeploc","adloc" d
 .s @var=$$lt^UPRNL(@var)
 
04021 ;
 set address("original")=$$tr^UPRNL($$lt^UPRNL(post_" "_$$flat^UPRNU(adflat)_" "_$$flat^UPRNU(adbuild)_" "_adepth_" "_adstreet_" "_adeploc),"  "," ")
 
 ;
f17 ;Dependent locality is street
 i adeploc'="" d
 .i $$isroad(adeploc),'$$isroad(adstreet) d
 ..i adstreet?1"no"1" "1n.n d
 ...s adstreet=$p(adstreet," ",2)_" "_adeploc
 ...s adeploc=""
 ..I adbuild'="",adstreet?1n.n!(adstreet?1n.n1l) d
 ...s adstreet=adstreet_" "_adeploc,adeploc=""
f18 ..if adstreet?1l.e,adeploc?1n.n."-".n1" "1l.e d  q
 ...i adstreet["flat" d
 ....s adbuild=adstreet_" "_adbuild
 ....s adstreet=adeploc
 ....s adeploc=""
f19 ...e  d
 ....s adbuild=adbuild_" "_adstreet
 ....s adstreet=adeploc
 ....s adeploc=""
f20 ..i adbuild'="" d
 ...i $d(^UPRNS("FLOOR",$p(adstreet," "))) d  q
 ....s adbuild=adbuild_" "_adstreet
 ....s adstreet=""
f21 ....i adepth'="" d
 .....s adstreet=adepth_" "_adeploc
 .....s adepth="",adeploc=""
f22 ....e  d
 .....s adstreet=adeploc
 ...i $$isflat^UPRNU(adstreet) d  q
 ....s adbuild=adstreet_" "_adbuild
 ....s adstreet=adepth_" "_adeploc
 ....s adepth="",adeploc=""
 
f23 ;Location is street, street is building
 i adloc'="",adstreet'="" d
 .if $$isroad(adloc),'$$isroad(adstreet) do
f24 ..if adloc?1n.n1" "1l.e d  q
f25 ...if adstreet?1n.n do
 ....i adbuild?1l.l.e d  q
 .....s adbuild=adstreet_" "_adbuild
 .....s adstreet=adloc
 .....s adloc=""
f26 ..i adstreet?1n.n!(adstreet?1n.n1"-"1n.n)!(adstreet?1n.n1l) do  q
 ...s adstreet=adstreet_" "_adloc
 ...s adloc=""
f27 ..i adflat="" d  q
 ...s adflat=adbuild
f28 ...I adstreet'="" d
 ....set adbuild=adstreet
f29 ...e  i adflat?1n.n.l1" "2l.e d
 ....set adbuild=$p(adflat," ",2,20)
 ....set adflat=$p(adflat," ")
 ...set adstreet=adloc
 ...set adloc=""
 ..set adbuild=adbuild_" "_adstreet
 ..set adstreet=adloc
 ..set adloc=""
 
 ;Only one  line, likely to be street But may be flat and building
 
 
 ;Location is actually number and street
f30 if adloc?1n.n.l1" "1l.e d
 .if adstreet'?1n.n.l1" ".e d
 ..set adbuild=adbuild_" "_adstreet
 ..set adstreet=adloc
 ..set adloc=""
 
 ;Street starts with flat number so swap
 ;May or may not contain building
f31 if $$isflat^UPRNU(adstreet) d  ;Might be flat
f32 .if '$$isroad(adstreet) do   q ;straight swap
 ..set xbuild=adbuild
 ..set adbuild=adstreet
 ..set adstreet=xbuild
f33 .else  d
 ..if $$isno($p(adstreet," ",3)) do
f34 ...if adbuild'="" d
 ....set adbuild=$p(adstreet," ",1,2)_" "_adbuild
f35 ...else  d
 ....s adbuild=$p(adstreet," ",1,2)
 ...set adstreet=$p(adstreet," ",3,20)
f35a ;Brackets
 i adbuild["(" d
 .i adbuild["(l)" q
 .s adbuild=$tr(adbuild,"("," ")
 .s adbuild=$tr(adbuild,")"," ")
 .s adbuild=$$tr^UPRNL(adbuild,"  "," ")
 
 ;Ordinary flat building various formats, split it up
 if adflat="" do flatbld(.adflat,.adbuild)
 s adflat=$$fixflat(adflat)
 
 ;Ordinary street format , split it up
 do numstr(.adbno,.adstreet,.adflat,.adbuild)
 s adstreet=$$fixstr("X.STR",adstreet)
 
 ;
 
f84 ;Left shift locality to street, street to building, building to flat?
 i adloc?1n.n1" "1l.e d
 .i adbuild="",adbno'="" do
 ..s adflat=adflat_" "_adbno
 ..s adbuild=adstreet
 ..s adbno=$p(adloc," ",1)
 ..s adstreet=$p(adloc," ",2,10)
 ..s adloc=""
 
 
f85 ;Is number in the flat field?
 if $$isno(adflat) d
 .if adbuild="" d
 ..if adbno="" d
 ...set adbno=adflat
 ...set adflat=""
 
f86 ;Building is street,street is null or not
 ;111 abbotts park road,  ,
 ;111 abotts park road, leyton,,
 ;111 abbotts park road , leyton, leyton
 if $$isroad(adbuild) do
 .i adbno="" d
f87 ..i adstreet="" d  q
f88 ...I $$isflat^UPRNU(adbuild) d  q
 ....i $p(adbuild," ",2)?1n.n d  q
 .....s xflat=adflat
 .....s adflat=$p(adbuild," ",1,2)
 .....s adbno=xflat
 .....s adbuild=$p(adbuild," ",3,20)
f89 ...I adbuild?1l.l.e d  q
 ....s adbno=adflat
 ....s adstreet=adbuild
 ....s adflat="",adbuild=""
f90 ...i adbuild?1n.n.l1" "1l.e d  q
 ....s adbno=$p(adbuild," ",1)
 ....s adstreet=$p(adbuild," ",2,10)
 ....s adbuild=""
f91 ..i adloc="" d
 ...i '$$isroad(adstreet) d
 ....s adloc=adstreet
 ....s adstreet=adbuild
 ....s adbno=adflat
 ....s (adflat,adbuild)=""
f92 if adflat'="",adbuild'="",adbno="",adstreet="" d
f93 .if adbno="",adstreet="" d  q
f94 ..i adflat["flat" d  q
 ...s adstreet=adbuild
 ...s adbuild=""
 ..set adbno=adflat
 ..set adstreet=adbuild
 ..set adflat="",adbuild=""
f95 .if adbno="",adloc="" d
f96 ..i '$$hasflat^UPRNU(adflat_" "_adbuild) d  Q
 ...set adloc=adstreet
 ...set adbno=adflat
 ...set adstreet=adbuild
 ...set adflat=""
 ...set adbuild=""
 ..d splitstr(adflat,adbuild,adbno,adstreet,.adflat,.adbuild,.adbno,.adstreet)
f97 .if '$$isroad(adstreet) do
f98 ..if adbno="" do  q
 ...if adstreet=adloc  d
 ....set adstreet=adbuild
 ....set adbuild=""
 ....set adbno=adflat
f99 ..if adbno'="" do
 ...set xbuild=adbuild
 ...set xflat=adflat
 ...set adbuild=adstreet
 ...set adflat=adbno
 ...set adbno=xflat
 ...set adstreet=xbuild
 
f100 ;Building is number,make sure street doesn't have the number !
 ;Number contains flat so assign number to flat
 if adbno?1n.n.l1" "1n.n.l d
 .s adflat=$p(adbno," ")
 .s adbno=$p(adbno," ",2)
 
 ;
f101 ;Strip space from number to assign suffix
 if adbno?1n.n1" "1l s adbno=$tr(adbno," ")
 
 ;Street is a number, locality is the street
f102 if $$isno(adstreet) d
 .if adbno'="" d
 ..s adbno=adstreet
 ..s adstreet=adloc
 ..s adloc=""
 
f103 ;Locality is street, street is building
 if $$isroad(adloc) d
 .if adflat="",adbuild="" d
 ..s adflat=adbno,adbno=""
 ..s adbuild=adstreet
 ..s adstreet=adloc,adloc=""
 
 
f104 ;Confusing flat number now split out
 if $$isflat^UPRNU(adbuild) d
f105 .if adflat=adbno d
 ..s adflat=$p(adbuild," ",1,2)
 ..s adbuild=$p(adbuild," ",3,10)
f106 .else  d
 ..if adflat'="" d
f107 ...if adbuild?1l.l1" "1l1" "1l.e d  q ; room f unite stratford
 ....set adflat=adflat_" "_$p(adbuild," ",1,2)
 ....set adbuild=$p(adbuild," ",3,20)
f108 ...i adbuild?1l.l1" "1l d  q ; room h
 ....set adflat=adflat_" "_$p(adbuild," ",1,2)
 ....set adbuild=$p(adbuild," ",3,20)
f108a    ...else  d
 ....if adbuild?1l.l1" "1n.n d
 .....s xflat=adbuild,adbuild=adflat,adflat=xflat
 
f109 ;Street has flat name and flat has street
 if $$isflat^UPRNU(adstreet) d
 .if adflat?1n.n d
 ..if adbuild'="" d
 ...n flatbuild
 ...set flatbuild=$S(adbno'="":adbno_" ",1:"")_adstreet
 ...set adbno=adflat
 ...set adstreet=adbuild
 ...set adflat=$p(flatbuild," ",1,2)
 ...set adbuild=$p(flatbuild," ",3,20)
 ...if adbuild?1l do
 ...set adflat=adflat_" "_adbuild,adbuild=""
 
f110 ;Duplicate flat building number and street,remove flat and building
 if adflat'="",adbuild'="",adbno'="",adstreet'="" d
 .if $e((adbno*1)_" "_adstreet,1,$l((adflat*1)_" "_adbuild))=((adflat*1)_" "_adbuild) d
 ..i adflat?1n.nl,adbno?1n.n d
 ...s adbno=adflat
 ..set adflat="",adbuild=""
 
 
f1101 ;first floor 96a second avenue
 ;street contains flat term before the number
 n i,word
 if adbno="" do
 .for i=2:1:$l(adstreet," ") do
 ..set word=$p(adstreet," ",i)
f111 ..if word?1n.n.l do
 ...if adflat="",adbuild="" d
 ....set adflat=$p(adstreet," ",1,i-1)
f112 ...else  do
 ....if adflat'="" do
f113 .....if adbuild="" d
 ......set adbuild=$p(adstreet," ",1,i-1)
f114 .....else  do
 ......s adbuild=adbuild_" "_$p(adstreet," ",1,i-1)
 ...set adbno=word
 ...set adstreet=$p(adstreet," ",i+1,20)
 
 ;
f115 ;street contains flat number near the end
 if adstreet[" flat " d
 .set adflat="flat "_$p(adstreet,"flat ",2,10)
 .set adstreet=$p(adstreet," flat",1)
 
f116 ;Bulding is number suffix
 ; a~12 high street
 if adbuild?1l,adflat="",adbno?1n.n do
 .set adbno=adbno_adbuild
 .set adbuild=""
 
f117 ;Street number mixed with flat and building
 ;20 284-288 haggerston studios~ kingsland road
 if adbuild?1n.n1" "1n.n."-".n1" "1l.e do
 .if adflat="",adbno="" d
 ..set adflat=$p(adbuild," ",1)
 ..set adbno=$p(adbuild," ",2)
 ..set adbuild=$p(adbuild,3,20)
 
f118 ;duplicate flat number in building number without street
 ;46, 46 ballance road
 if adbuild?1n.n1" "1n.n do
 .if adbno="",adflat="" do
 ..set adbno=$p(adbuild," ",2)
 ..set adflat=$p(adbuild," ",1)
 ..set adbuild=""
 
f119 ;110 , 110 carlton road
 ;Duplicate flat and number
 if adflat=adbno,adbuild="",adflat>20 d
 .set adflat=""
 
f120 ;street number is in location!
 ; bendish road , 11
 if adloc?1n.n,adbno="" do
 .set adbno=adloc
 .set adloc=""
 
f121 ;Error in flat number
 ;flat go1
 if $p(adflat," ",2)?1l.l1"o"1n.n d
 .set $p(adflat," ",2)=$tr($p(adflat," ",2),"o","0")
 
f122 ;Now has flat as number and number still in street
 ;,,flat 1, 22 plashet road
 if adbno'="",$$isno($P(adstreet," ")) do
 .if adflat="",adbuild="" d
 ..set adflat=adbno
 ..set adbno=$p(adstreet," ")
 ..set adstreet=$p(adstreet," ",2,20)
 
f123 ;area in street
 ;First fix street
 s adstreet=$$fixstr("X.STR",adstreet)
 I adloc="",$l(adstreet," ")>1 d
 .I '$d(^UPRNX("X.BLD",adstreet))&('$D(^UPRNX("X.STR",adstreet))) d
 ..i $D(^UPRNS("TOWN",$p(adstreet," ",$l(adstreet," ")))) d
 ...s adloc=$p(adstreet," ",$l(adstreet," "))
 ...s adstreet=$p(adstreet," ",0,$l(adstreet," ")-1)
 
f124 ;building is the number
 i adbuild'="" d
 .s adbuild=$$fixstr("X.BLD",adbuild)
   
 if $$isno(adbuild),adstreet'="",adbno="" do
 .set adbno=adbuild
 .set adbuild=""
 
f125 ;suffixes split across fields
 if adflat'="",adbuild?1l1" "1l.e do
 .set adflat=adflat_$e(adbuild)
 .set adbuild=$p(adbuild,2,20)
 .set adbuild=$p(adbuild,2,20)
 
f126 if adbno'="",adstreet?1l1" "1l.e d
 .I $e(adstreet)'="y" d
 ..set adbno=adbno_$e(adstreet)
 ..set adstreet=$p(adstreet," ",2,20)
 
f127 ;Two streets
 if $$isroad(adloc),$$isroad(adstreet) do
 .if adflat="",adbuild="" do
 ..set adflat=adbno
 ..set adbuild=adstreet
 ..set adbno=""
 ..set adstreet=adloc
 ..set adloc=""
 ;
 
f128 ;009 
 ;strip leading zeros
 if adflat?1n.n set adflat=adflat*1
 if adbno?1n.n set adbno=adbno*1
 
f129 ;Building ends in number
 i adbno="",adflat="",adstreet?1l.l1" "1l.l.e d
 .i $p(adbuild," ",$l(adbuild," "))?1n.n d
 ..s adbno=$p(adbuild," ",$l(adbuild," "))
 ..s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 ;Correct spelling
f130 i '$d(address("obuild")) s address("obuild")=adbuild
 s address("ostr")=adstreet
 s adbuild=$$correct^UPRNU(adbuild)
 s adstreet=$$correct^UPRNU(adstreet)
 set adflat=$$flat^UPRNU($$co($$correct^UPRNU(adflat)))
 
f131 i adbno'="" s adbno=$$flat^UPRNU($$co($$correct^UPRNU(adbno)))
 
f132 ;Duplicate building
 i adbuild=adstreet d
 .i adbno="",adflat'="" d
 ..s adbno=adflat
 ..s adbuild=""
 ..s adflat=""
 
f133 ;Street still has number
 i adstreet?1n.n1l1" "1l.e,adbno="",adflat'="" d
 .s adbno=$p(adstreet," ")
 .s adstreet=$p(adstreet," ",2,10)
 
f134 ;Street contains building
 i adbuild="",adflat="" d
 .i $$isroad(adstreet) d
 ..f i=1:1:($l(adstreet," ")-2) D
f135 ...i $d(^UPRNS("BUILDING",$p(adstreet," ",i)))!($d(^UPRNS("COURT",$p(adstreet," ",i)))) d
 ....s adbuild=$p(adstreet," ",1,i)
 ....s adstreet=$p(adstreet," ",i+1,$l(adstreet," "))
 ....s adflat=adbno
 ....s adbno=""
 
 
f136 ;dependent locality has number
 i adepth?1n.n1l!(adeploc?1n.n),adbno="" d
 .s adbno=adepth
 .s adepth=""
 
f137 ;House and street in same line
 i adflat="",adbuild="",adbno'="",$l(adstreet," ")>2 d
 .s lenstr=$l(adstreet," ")
 .i $p(adstreet," ",lenstr)?1n.n d
 ..s strfound=0
 ..f i=1:1:lenstr-1 d  q:strfound
f138 ...i $D(^UPRNX("X.STR",$p(adstreet," ",i,lenstr-1))) d
 ....s strfound=1
 ....s adflat=adbno
 ....s adbno=$p(adstreet," ",lenstr)
 ....s adbuild=$p(adstreet," ",0,i-1)
 ....s adstreet=$p(adstreet," ",i,lenstr-1)
f139 .I $D(^UPRNX("X.STR",adstreet)) q
 .f i=$l(adstreet," ")-1:-1:2 i $D(^UPRNX("X.STR",$p(adstreet," ",i,$l(adstreet," ")))) d  q
 ..s adflat=adbno
 ..s adbuild=$p(adstreet," ",1,i-1)
 ..s adbno=""
 ..s adstreet=$p(adstreet," ",i,$l(adstreet," "))
 
 
f140 ;Shifts building to stree if its in street dictionary
 i adbno="",adbuild'="",adflat'="" d
 .I $D(^UPRNX("X.STR",adbuild)) d
 ..i '$D(^UPRNX("X.STR",adstreet)) d
 ...i adloc[" " q
 ...i adeploc'="" d
 ....s adloc=adeploc_$s(adloc="":"",1:" ")_adloc
 ....s adeploc=adstreet
 ...e  d
 ....s adloc=adstreet
 ...s adstreet=adbuild
 ...s adbno=adflat
 ...s adflat=""
 ...s adbuild=""
 
f141 ;town in street
 i adloc'="",adbno="" d
 .I $D(^UPRNS("TOWN",adloc)) d
 ..i adstreet'="" d
 ...I $D(^UPRNS("TOWN",adstreet)) d
 ....s adtown=adloc
 ....s adloc=adstreet
 ....s adstreet=adbuild
 ....s adbno=adflat
 ....s adflat="",adbuild=""
 
f142 ;Looks for more verticals
 I $D(^UPRNS("VERTICALS",adflat_" "_adbuild)) d
 .s adflat=adflat_" "_adbuild
 .s adbuild=""
F142a i adflat="" d
 .s numpos=$$numpos(adbuild)
 .i numpos>0 d
 ..I $D(^UPRNS("VERTICALS",$p(adbuild," ",1,numpos-1))) d
 ...s adflat=$p(adbuild," ",1,numpos)
 ...s adbuild=$p(adbuild," ",numpos+1,20)
 
f143 i adflat="" d
 .s fbuild=adbuild
f144 .i $$isflat^UPRNU($p(adbuild," ")) s fbuild=$p(adbuild," ",2,20)
 .f i=$l(fbuild," "):-1:2 i $D(^UPRNS("VERTICALS",$p(fbuild," ",1,i))) d  q
 ..s adflat=$p(fbuild," ",1,i)
 ..s adbuild=$p(fbuild," ",i+1,20)
 
f145 ;Flat not yet found
 i adflat="",adbuild'="",adstreet'="" d
 .F i=1:1:$l(adbuild," ") i $p(adbuild," ",i)?1n.n.l d  q
 ..s adflat=$p(adbuild," ",1,i)
 ..s adbuild=$P(adbuild," ",i+1,20)
 .i adflat'="" q
 .i adbuild?1"studio"1" "1l s adflat=adbuild,adbuild="" q
 .i adbuild?1"studio"1" "1n s adflat=adbuild,adbuild="" q
 .i adbuild?1"studio"1" "1n1" ".e s adflat=$p(adbuild," ",1,2),adbuild=$p(adbuild," ",3,10) q
 ;
f147 ;Look again for verticals
 ;Still looking
 i adbuild?1p1" ".e I $D(^UPRNS("VERTICALS",$p(adbuild," ",2,20))) d
 .s adflat=adflat_" "_$p(adbuild," ",2,20)
 .s adbuild=""
f148 I $d(^UPRNS("VERTICALS",adbuild)) d
 .s adflat=$s(adflat="":adbuild,1:adflat_" "_adbuild)
 .s adbuild=""
 
f149 ;Probably got flat and number wrong
 i adbuild="flat",adflat?1n.n1l,adbno?1n.n d
 .s temp=adflat
 .s adflat=adbno
 .s adbno=temp
 .s adbuild=""
 
f150 ;Building has range number in it
 i adbno="",$p(adbuild," ",$l(adbuild," "))?1n.n."-".n d
 .s adbno=$p(adbuild," ",$l(adbuild," "))
 .s adbuild=$p(adbuild," ",0,$l(adbuild," ")-1)
 .I $D(^UPRNS("VERTICALS",adflat_" "_adbuild)) d
 ..s adflat=adflat_" "_adbuild
 ..s adbuild=""
 
f151 ;Street is building
 I adflat'="",adbuild="",adbno="",'$D(^UPRNX("X.STR",adstreet)) d
 .I $D(^UPRNX("X.BLD",adstreet)) d
 ..s adbuild=adstreet,adstreet=""
 
f152 ;Flat contains street number
 i adflat?1n.n1" "1n.n,adbno="",$d(^UPRNX("X.STR",adbuild_" "_adstreet))  d
 .s adbno=$p(adflat," ",2)
 .s adflat=$p(adflat," ")
 .s adstreet=adbuild_" "_adstreet
 .s adbuild=""
 ;
 
f153 ;
 D ^UPRNA1(.adflat,.adbuild,.adbno,.adstreet,.adloc,.adeploc)
 
 
setadd ;set address object values
 s address("town")=$g(adtown)
 s address("flat")=adflat
 s address("building")=adbuild
 s address("number")=adbno
 s address("deploc")=adeploc
 s address("depth")=adepth
 s address("street")=adstreet
 s address("locality")=adloc
 s address("postcode")=post
 s short="",long=""
 
eform q
co(number)         ;Strips off care of
 i $tr($p(number," "),"-")="co" d
 .i $l(number," ")>1 d
 ..s number=$p(number," ",2,10)
 q number
 
splitstr(oflat,obuild,obno,ostreet,adflat,adbuild,adbno,adstreet) 
 ;Splits up building into street and vice versa
 n i,xbuild,xstreet
 f i=1:1:$l(obuild," ") d
 .i $p(obuild," ",i)?1n.n d
 ..i $$hasflat^UPRNU($p(obuild," ",i+1,i+10)) d
 ...s adbno=adflat
 ...s xstreet=adstreet
 ...s adstreet=$p(obuild," ",0,i-1)
 ...s adflat=$p(obuild," ",i,i+10)
 ...s adbuild=xstreet
 q
isno(word)         ;is it a number
 if word?1n.n q 1
 if word?1n.n1l q 1
 if word?1n.n1"-"1n.n q 1
 if word?1n.n1l1"-"1n.n1l q 1
 q 0
fixflat(adflat)    ;
 i adflat?1n.n1" flat".e d
 .i $p(adflat," ",$l(adflat," "))="g" d
 ..s adflat="g"_$p(adflat," ")
 .e  i $p(adflat," ",$l(adflat," "))="flat" d
 ..s adflat="flat "_$p(adflat," ")
 q adflat
getnum(term)       ;
 n i,num
 s num="",done=0,rest=""
 f i=1:1:$l(term) d
 .i $e(term,i)?1n d
 ..s num=num_$e(term,i)
 .e  s rest=rest_$e(term,i)
 q num_" "_rest
 
flatbld(adflat,adbuild) ;
 i adbuild?1"flat"1n.n.l d
 .s adbuild="flat "_$$getnum($p(adbuild,"flat",2))
 
 
DS1105A i adbuild?1n.n1" flat".e d
 .i $p(adbuild," ",$l(adbuild," "))="flat" d
 ..s adbuild="flat "_$p(adbuild," ")
 .i $p(adbuild," ",$l(adbuild," "))="g" d
 ..s adflat="g"_$p(adbuild," ")
DS1105B ..s adbuild=""
 ;is it a flat or number and if so what piece is the rest?
 s adbuild=$$co(adbuild)
 I adbuild["flat-" s adbuild=$tr(adbuild,"-"," ")
 
 ;Welsh 'y'
f36 i adbuild?1n.n1" "1"y"1" "1l.e d
 .s adflat=adbuild*1
 .s adbuild="y"_$p(adbuild," ",3,10)
 
f37 if $$isflat^UPRNU(adbuild) do  q
 .set adflat=$p(adbuild," ",1,2)
 .set adbuild=$p(adbuild," ",3,10)
 .I adbuild?1"floor"1" "1n.n.l1" ".e d
 ..s adflat=adflat_" "_$p(adbuild," ",1,2)
 ..s adbuild=$p(adbuild," ",3,20)
f38 .I $d(^UPRNS("FLAT",adflat)) d
 ..s adflat=adbuild,adbuild=""
f39 .I $D(^UPRNS("VERTICALS",adbuild)) d
 ..s adflat=$s(adflat="":adbuild,1:adflat_" "_adbuild)
 ..s adbuild=""
f40 .i adbuild="floors"!(adbuild="floor") s adflat=adflat_" "_adbuild,adbuild="" Q
f41 .if adbuild?1l1" ".e d
 ..set adflat=adflat_$p(adbuild," ")
 ..set adbuild=$p(adbuild," ",2,20)
f42 .if adbuild?1n.n.l1" "1l.e d
 ..i $D(^UPRNS("FLOOR",$P(adbuild," "))) q
 ..s adflat=adflat_" "_$p(adbuild," ")
 ..s adbuild=$p(adbuild," ",2,10)
 
f43 ;is it a vertical flat?
 I $D(^UPRNS("VERTICALS",adbuild)) d  q
 .s adflat=adbuild
 .s adbuild=""
 
f44 ;2nd floor flat etc
 i adbuild'="" d
 .s address("obuild")=adbuild
 .s $p(adbuild," ")=$$correct^UPRNU($p(adbuild," "))
 
f45 ;18pondo road
 if adbuild?1n.n2l.l1" "2l.e do  q
 .n i
 .f i=1:1 q:$e(adbuild,i)'?1n  d
 ..set adflat=adflat_$e(adbuild,i)
 .set adbuild=$p(adbuild,adflat,2,10)
 
f46 ;19a
 if adbuild?1n.n.l do  q
 .set adflat=adbuild
 .set adbuild=""
 
f47 if adbuild?1n.n1" "1l do  q
 .set adflat=$p(adbuild," ")_$p(adbuild," ",2)
 .set adbuild=""
 
f48 ;19 a eagle house
 if adbuild?1n.n1" "1l1" ".e do  q
 .set adflat=$p(adbuild," ",1)_$p(adbuild," ",2)
 .set adbuild=$p(adbuild," ",3,20)
 
f49 ;18dn forth avenue
 if adbuild?1n.n2l1" "1l.e d  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,10)
 
f50 ;19 eagle house or garden flat 1
 if adbuild?1n.n.l1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
 
f51 ;19a-19c eagle house
 if adbuild?1n.n.l1"-"1n.n.1" ".l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
f51a ;73a-b
 if adbuild?1n.n.l1"-"1l1" ".l.e do  q
 .set adflat=$p(adbuild," ",1)
f51a3 .set adbuild=$p(adbuild," ",2,20)
 
f52 ;19- eagle house
 if adbuild?1n.n1"-"1" "1l.e do  q
 .set adflat=$p(adbuild,"-",1)
 .set adbuild=$p(adbuild," ",2,20)
 
f53 ;first floor flat
 if adbuild[" flat"!(adbuild[" room"),adflat="" do  q
 .n i,flatfound,word
 .s flatfound=0
 .F i=1:1:$l(adbuild," ") d  q:flatfound
 ..s word=$p(adbuild," ",i)
f54 ..i word="flat"!(word="room") d
 ...s flatfound=1
f55 ...i $p(adbuild," ",i+1)?.n!($p(adbuild," ",i+1)?.n1l) d  q
 ....s adflat=$p(adbuild," ",1,i+1)
 ....s adbuild=$p(adbuild," ",i+2,$l(adbuild))
 ....I adbuild="",$D(^UPRNS("BUILDING",$p(adflat," ",i-1))) d
 .....s adbuild=$p(adflat," ",1,i-1)
 .....s adflat=$p(adflat," ",i,20)
 ...E  D
 ....S adflat=$p(adbuild," ",1,i)
 ....s adbuild=$p(adbuild," ",i+1,20)
 
 
 
 
f57 ;house 23
 i adbuild?1"house"1" "1n.n.e d
 .s adflat=$p(adbuild," ",2)
 .s adbuild=$p(adbuild," ",3,20)
 
f571 ;116 - 118 
 if adbuild?1n.n.l1" "1"-"1" "1n.n.l.e do  q
 .set adflat=$p(adbuild," ",1)_"-"_$p(adbuild," ",3)
 .set adbuild=$p(adbuild," ",4,20)
 
f58 ;12 -20 rosina street
 if adbuild?1n.n1" "1"-"1n.n1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)_$p(adbuild," ",2)
 .set adbuild=$p(adbuild," ",3,20)
 
f59 ;a cranberry lane
 if adbuild?1l1" "1l.l1" "1l.e do  q
 .set adflat=$p(adbuild," ")
 .set adbuild=$p(adbuild," ",2,10)
 
f60 ;a203 carmine wharf
 ;dlg02 carminw wharf
 if adbuild?1l.l1n.n.1" "1l.e do  q
 .set adflat=$p(adbuild," ")
 .set adbuild=$p(adbuild," ",2,20)
 
f61 ;b202h unit building
 if adbuild?1l1n.n.l1" "1l.e do  q
 .set adflat=$p(adbuild," ",1)
 .set adbuild=$p(adbuild," ",2,20)
 
f62 ;flaflat 10 mileset lodge
 if $p(adbuild," ")["flat" do  q
f63 .I $p(adbuild," ",2)?1n.n.l d
 ..set adflat="flat"_" "_$p(adbuild," ",2)
 ..set adbuild=$p(adbuild," ",3,20)
f64 .e  d
 ..if adflat'="" d
 ...set adflat="flat "_adflat
 ...set adbuild=$p(adbuild," ",2,20)
 
f65 ;workshop 6
 if adflat="",adbuild?1.l1" "1n.n.l do  q
 .s adflat=adbuild
 .s adbuild=""
 
 
 
 q
numpos(text)       ;
 n (text)
 s pos=0
 f i=1:1:$l(text," ") d
 .i $p(text," ",i)?1n.n.l d
 ..s pos=i
 q pos
 
numstr(adbno,adstreet,adflat,adbuild) ;
 ;Reformat a variety of number and street patterns
 
f66 ;38 & 40 arthur street
 i adstreet?1n.n1" "1"&"1" "1n.n1" "1l.e d  q
 .s adbno=$p(adstreet," ",1)_"-"_$p(adstreet," ",3)
 .s adstreet=$p(adstreet," ",4,40)
f66a ;Off road
 i adstreet?1"off"1" "1l.e d
 .i $d(^UPRNX("X.STR",$p(adstreet," ",2,20))) d
F66d ..s adstreet=$p(adstreet," ",2,20)
 
f67 ;11 high street
 if adstreet?1n.n1" "2l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,10)
f68 .if adstreet?1"flat "1n.n.l1" "1l.e d
 ..i adflat="" d
 ...s adflat=$p(adstreet," ",1,2)
 ...s adstreet=$p(adstreet," ",3,20)
 .i $D(^UPRNS("FLAT",adflat)) d
 ..s adflat=adbno
 ..s adbno=""
 
f69 ;100 S0oth
 if adstreet?1n.n1" "1l.n.l.e d  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,10)
 
f70 ;123-15 dunlace road
 if adstreet?1n.n1"-"1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
f71 ;11a high street
 if adstreet?1n.n1l1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
f72 ;14 - 16 lower clapton road
 if adstreet?1n.n1" "1"-"1" "1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)_"-"_$p(adstreet," ",3)
 .set adstreet=$p(adstreet," ",4,10)
 
f73 ;109- 111 Leytonstone road....
 if adstreet?1n.n1"-"1" "1n.n1" ".l.e do  q
 .set adbno=$p(adstreet," ",1)_$p(adstreet," ",2)
 .set adstreet=$p(adstreet," ",3,20)
 
f74 ;109a-111 Leytonstone road....
 if adstreet?1n.n1l1"-"1n.n1" "1l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
f75 ;110haley road
 if adstreet?1n.n2l.l1" "2l.e do  q
 .n i
 .f i=1:1 q:$e(adstreet,i)'?1n  d
 ..set adbno=adbno_$e(adstreet,i)
 .set adstreet=$p(adstreet,adbno,2,10)
 
f76 ;1a 
 if adstreet?1n.n1l do  q
 .set adbno=adstreet
 .set adstreet=""
   
f77 ;99 a high street
 if adstreet?1n.n1" "1l1" ".e do  q
f78 .if $p(adstreet," ",2)="y" d
 ..set adbno=$p(adstreet," ",1)
 ..set adstreet=$p(adstreet," ",2,20)
f79 .e  d
 ..set adbno=$p(adstreet," ",1)_$p(adstreet," ",2)
 ..set adstreet=$p(adstreet," ",3,20)
 
f80 ;9a-11b high street
 if adstreet?1n.n1l1"-"1n.n1l1" ".l.e do  q
 .set adbno=$p(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
 
f81 ;10-10a blurton road
 if adstreet?1n.n1"-"1n.n1l1" "1l.e d
 .set adbno=$P(adstreet," ",1)
 .set adstreet=$p(adstreet," ",2,20)
 
f82 ;99- high street
 if adstreet?1n.n1"-"1" "1l.e d
 .set adbno=$p(adbuild,"-",1)
 .set adstreet=$p(adstreet," ",2,20)
 
f83 ;westdown road 99
 i $p(adstreet," ",$l(adstreet," "))?1n.n d
 .s adbno=$p(adstreet," ",$l(adstreet," "))
 .s adstreet=$p(adstreet," ",0,$l(adstreet," ")-1)
 
f841 ;
 i adbno="",adstreet?1n.n1"-"1n.n d
 .s adbno=adstreet
 .s adstreet=""
 .i adloc'="" d
 .s adstreet=adloc,adloc=""
 q
 
 
 q
 
isroad(text)       ;
 n i,word,road
 s road=0
 f i=1:1:$l(text," ") d
 .s word=$p(text," ",i)
 .q:word=""
 .I $D(^UPRNS("ROAD",word)) s road=1
 q road
 
iscity(text)       ;
 n word,done
 s done=0
 s word=""
 for  s word=$O(^UPRNS("CITY",word)) q:word=""  d
 .i text[word s done=1
 q done
spelchk(address)   ;
 n (address)
 i address[" to - " d
 .s address=$$tr^UPRNL(address," to - ","-")
 f part=1:1:($l(address,"~")-1) d
 .s field=$p(address,"~",part)
 .f wordno=1:1:$l(field," ") d
 ..s word=$p(field," ",wordno)
 ..i word="st" d  q
 ...s saint="st "_$p(field," ",wordno+1)
 ...I saint="st " d  q
 ....s word="street"
 ....s $p(field," ",wordno)=word
 ...i $D(^UPRNX("X.STR",saint)) q
 ...i $O(^UPRNX("X.STR",saint))[saint q
 ...s word="street"
 ...s $p(field," ",wordno)=word
 ..i word="p" d  q
 ...i $p(field," ",wordno+1)="h" d
 ....s word="public house"
 ....s $p(field," ",wordno,wordno+1)=word
 ..s word=$$correct^UPRNU(word)
 ..s $p(field," ",wordno)=word
 .s $p(address,"~",part)=field
 q
fixstr(index,str)        ;
 n (index,str)
 i $D(^UPRNX(index,str)) d  q str
 .i ^UPRNX(index,str)[" " d
 ..s str=^UPRNX(index,str)
 s new=str
 I str[" " i $D(^UPRNX(index,$tr(str," "))) d
 .s new=^UPRNX(index,$tr(str," "))
 q new
