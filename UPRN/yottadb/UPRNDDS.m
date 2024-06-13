UPRNDDS ; ; 4/15/24 3:38pm
 quit
 
SETUP S ^%W(17.6001,"B","GET","api/getcsv","GETCSV2^UPRNDDS",77)=""
 S ^%W(17.6001,77,"AUTH")=2
 QUIT
 
GETID() ;
 L ^AUDIT:5
 I '$T Q 0
 S ID=$I(^AUDIT)
 L -^AUDIT
 Q ID
 
TESTCSV2 ;
 new a,r
 kill ^TMP($job)
 s a("adrec")="10 Downing St,Westminster,London,SW1A2AA"
 s a("adrec")="9 SALISBURY VIEW,MAYFIELD,,EH225JH"
 s a("delim")="~"
 s a("ids")="123"
 D GETCSV2(.r,.a)
 write !,^TMP($J,1)
 write !,^TMP($J,2)
 ;D GETCSV(.r,.a)
 ;write !,^TMP($J,1)
 quit
 
GETCSV2(result,arguments) ;
 k ^TMP($J),^TPARAMS($J)
 set adrec=$get(arguments("adrec"))
 set del=$get(arguments("delim"))
 set ids=$get(arguments("ids"))
 i $g(del)="" s del=","
 
 S ^TEST=adrec_"~"_$g(ids)
 
 S log=$GET(^ICONFIG("UPRN-LOG"))
 if log'="" do
 .S zID=$$GETID()
 .S ^AUDIT(ID)=adrec_"|"_$HOROLOG_"|"_ids
 .quit
 
 ;D GETUPRN^UPRNMGR(adrec,"","","",0,0)
 D GETUPRN^UPRN(adrec,"","","")
 set rec=$$BLOCK()
 S (LOCALITY,NUMBER,ORG,POSTCODE,STREET,TOWN,QUALITY,POINT)=""
 ; 1.  uprn
 set UPRN=$piece(rec,"~",1)
 ; 2.  algorithm
 set ALG=$p(rec,"~",2)
 ; 3.  classcode
 set CLASS=$P(rec,"~",3)
 ; 4.  qualifier
 set QUAL=$P(rec,"~",4)
 ; 5.  organisation
 set ORG=""
 ; 6.  building (pattern)
 set MATPATBUILD=$p(rec,"~",6)
 ; 7.  flat (pattern)
 set MATPATFLAT=$p(rec,"~",7)
 ; 8.  number (pattern)
 set MATPATNUMBER=$p(rec,"~",8)
 ; 9.  street (pattern)
 set MATPATSTRT=$p(rec,"~",9)
 ; 10. postcode (pattern)
 set MATPATPSTCDE=$p(rec,"~",10)
 ; 11. latitude
 set LAT=$p(rec,"~",11)
 ; 12. longitude
 set LONG=$p(rec,"~",12)
 ; 13. x coordinate
 set X=$p(rec,"~",13)
 ; 14. y coordinate
 set Y=$p(rec,"~",14)
 s csv=LOCALITY_del_NUMBER_del_ORG_del_POSTCODE_del_STREET_del_TOWN
 set csv=csv_del_ALG_del_QUAL_del_MATPATBUILD_del_MATPATFLAT_del
 s csv=csv_MATPATNUMBER_del_MATPATPSTCDE_del_MATPATSTRT_del
 S QUALITY=$GET(^TUPRN($J,"INVALID"))
 s csv=csv_QUALITY_del_$g(LAT)_del_$g(LONG)_del_$g(POINT)_del_$g(X)_del_$g(Y)_del_$g(CLASS)_del_UPRN
 S ALGVERSION=$GET(^ICONFIG("ALG-VERSION"))
 ;S EPOCH=$GET(^ICONFIG("EPOCH-PIPELINE"))
 S EPOCH=$O(^DSYSTEM("COU",""),-1)
 S csv=csv_del_ALGVERSION_del_EPOCH
 s ^TMP($J,1)=csv
 ; abp address fields
 ;s zflat=$p(rec,"~",15),zbuild=$p(rec,"~",16),zbno=$p(rec,"~",17)
 ;s zdepth=$p(rec,"~",18),zstreet=$p(rec,19),zdeploc=$p(rec,"~",20)
 ;s zloc=$p(rec,"~",21),ztown=$p(rec,"~",22),zpost=$p(rec,"~",23)
 ;s zorg=$p(rec,"~",24)
 set abp=$p(rec,del,15,99)
 ; if not a pipeline request
 if ids="" s ^TMP($J,2)=abp
 set result("mime")="text/plain, */*"
 set result=$na(^TMP($j))
 quit
 
GETCSV(result,arguments) ;
 K ^TMP($J),^TPARAMS($J)
 S CR=$C(13,10)
 set ^change($J)=3
 ;
 set adrec=$Get(arguments("adrec"))
 set del=$Get(arguments("delim"))
 set ids=$Get(arguments("ids"))
 i $g(del)="" s del=","
 S ^TEST=adrec_"~"_$g(ids)
 
 I ids["org`" S ^TPARAMS($J,"commercials")=1
 I ids["odsload`" S ^TPARAMS($J,"commercials")=1
 I ids["cqc`" S ^TPARAMS($J,"commercials")=1
 
 S zID=$$GETID()
 ;S ^AUDIT(ID)=adrec_"|"_$HOROLOG
 
 ;S ^TMP($J,1)="TEST"
 K json
 K ^temp($j)
 ;D GETUPRN^UPRNMGR(adrec)
 D GETUPRN^UPRNMGR(adrec,"","","",0,0)
 K b
 D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 set UPRN=$get(b("BestMatch","UPRN"))
 
 D STT^SOURCE(ids,UPRN)
 
 ;S ^PS($O(^PS(""),-1)+1)=UPRN_"~"_ids_"~"_adrec
 ; STOP AUDITING 1/3/2021
 ; STARTED AUDITING AGAIN 22/3/2021
 ; STOP AUDITING 29/03/21
 I $GET(^ICONFIG("START-AUDIT"))'="" S ^AUDIT(zID)=UPRN_"|"_ids_"|"_adrec_"|"_$HOROLOG
 ;do META(.b)
 set ALG=$get(b("BestMatch","Algorithm"))
 set QUAL=$get(b("BestMatch","Qualifier"))
 set MATPATBUILD=$get(b("BestMatch","Match_pattern","Building"))
 set MATPATFLAT=$get(b("BestMatch","Match_pattern","Flat"))
 set MATPATNUMBER=$get(b("BestMatch","Match_pattern","Number"))
 set MATPATPSTCDE=$get(b("BestMatch","Match_pattern","Postcode"))
 set MATPATSTRT=$get(b("BestMatch","Match_pattern","Street"))
 set QUALITY=$get(b("BestMatch","Address_format"))
 ;S ^PS($O(^PS(""),-1)+1)=$G(LONG)
 S (COORD,LAT,LONG,POINT,X,Y,CLASS)=""
 if UPRN'="" do
 .;S ^FRED($O(^FRED(""),-1)+1)=UPRN_"~"_$A(UPRN)
 .S COORD=$piece($get(^UPRN("U",UPRN)),"~",7)
 .S LAT=$P(COORD,",",3),LONG=$P(COORD,",",4)
 .S POINT="",X=$P(COORD,",",1),Y=$P(COORD,",",2)
 .S CLASS=$piece($get(^UPRN("CLASS",UPRN)),"~",1)
 .quit
 S LOCALITY=$get(b("BestMatch","ABPAddress","Locality"))
 S NUMBER=$g(b("BestMatch","ABPAddress","Number"))
 S ORG=$g(b("BestMatch","ABPAddress","Organisaton"))
 S POSTCODE=$g(b("BestMatch","ABPAddress","Postcode"))
 S STREET=$g(b("BestMatch","ABPAddress","Street"))
 S TOWN=$g(b("BestMatch","ABPAddress","Town"))
 ; 13/09/2021 nul ABP address data
 S (LOCALITY,NUMBER,ORG,POSTCODE,STREET,TOWN)=""
 s csv=LOCALITY_del_NUMBER_del_ORG_del_POSTCODE_del_STREET_del_TOWN
 set csv=csv_del_ALG_del_QUAL_del_MATPATBUILD_del_MATPATFLAT_del
 s csv=csv_MATPATNUMBER_del_MATPATPSTCDE_del_MATPATSTRT_del
 s csv=csv_QUALITY_del_$g(LAT)_del_$g(LONG)_del_$g(POINT)_del_$g(X)_del_$g(Y)_del_$g(CLASS)_del_UPRN
 S ALGVERSION=$GET(^ICONFIG("ALG-VERSION"))
 S EPOCH=$GET(^ICONFIG("EPOCH-PIPELINE"))
 S csv=csv_del_ALGVERSION_del_EPOCH
 s ^TMP($J,1)=csv
 set result("mime")="text/plain, */*"
 set result=$na(^TMP($j))
 QUIT
 ;
META(b) ;
 q
 
TEST ;
 kill
 
 set adrec="10 Downing St,Westminster,London,SW1A2AA"
 set adrec="9 SALISBURY VIEW,MAYFIELD,,EH225JH"
 ;D GETUPRN^UPRNMGR(adrec,"","","",0,0)
 D GETUPRN^UPRN(adrec,"","","")
 set rec=$$BLOCK()
 ;write !,rec
 w !
 zwr rec
 quit
 
BLOCK() 
 new rec
 set zok=1
 set (algorithm,classterm,classcode,qualifier,uprn)=""
 i $data(^TUPRN($J,"NOMATCH")) s zok=0
 i $data(^TUPRN($J,"OUTOFAREA")) s zok=0
 i $data(^TUPRN($J,"INVALID")) S zok=0
 kill data,patterns
 i zok do MATCHED(1,$get(^TUPRN($J,"COMMERCIAL")),.data,.patterns)
 set qualifier=$get(data(0))
 set uprn=$get(data(1))
 set classcode=$get(data(2))
 set algorithm=$get(data(3))
 set table=$get(data(4))
 set key=$get(data(5))
 s building=$get(patterns("Building")),flat=$get(patterns("Flat"))
 s number=$get(patterns("Number"))
 s postcode=$get(patterns("Postcode"))
 s street=$get(patterns("Street"))
 s (lat,long,x,y)=""
 i uprn'="" do
 . set coord=$p(^UPRN("U",uprn),"~",7)
 . set lat=$p(coord,",",3),long=$p(coord,",",4)
 . set lat=$j(lat,0,$l($p(lat,".",2)))
 . s long=$j(long,0,$l($p(long,".",2)))
 . set x=$p(coord,",",1)
 . set y=$p(coord,",",2)
 . quit
 set patterns=building_"~"_flat_"~"_number_"~"_street_"~"_postcode
 set organisation=""
 set rec=uprn_"~"_algorithm_"~"_classcode_"~"_qualifier_"~"_organisation_"~"_patterns_"~"_lat_"~"_long_"~"_x_"~"_y
 
 if zok do
 .D GETABP^UPRNU(uprn,table,key,.zflat,.zbuild,.zbno,.zdepth,.zstreet,.zdeploc,.zloc,.ztown,.zpost,.zorg)
 .f var="zbuild","zdepth","zstreet","zdeploc","zloc","ztown" d
 .. i @var'="" s @var=$$in^UPRNL(@var)
 .. quit
 .s zpost=$$repost^UPRN2(zpost)
 .set rec=rec_"~"_zflat_"~"_zbuild_"~"_zbno_"~"_zdepth_"~"_zstreet_"~"_zdeploc_"~"_zloc_"~"_ztown_"~"_zpost_"~"_zorg
 .quit
 
 quit rec
 
MATCHED(best,commerce,data,patterns) 
 n glob,i
 s glob="^TUPRN"
 s uprn=$o(@glob@($J,"MATCHED",""),-1)
 s table=$O(@glob@($j,"MATCHED",uprn,""),-1)
 s key=$O(@glob@($J,"MATCHED",uprn,table,""),-1)
 S matchrec=@glob@($j,"MATCHED",uprn,table,key)
 set qual=$$qual^UPRN2(matchrec,commerce)
 set data(0)=qual
 set data(1)=uprn
 set data(4)=table
 set data(5)=key
 I $D(^UPRN("CLASS",uprn)) d
 . set classcode=$tr($p(^UPRN("CLASS",uprn),"~"),"""")
 . set data(2)=classcode
 . quit
 s alg=@glob@($J,"MATCHED",uprn,table,key,"A")
 set data(3)=alg
 f i=1:1:$l(matchrec,",") d
 . s pattern=$p(matchrec,",",i)
 . set part=$$part^UPRN2($e(pattern))
 . set degree=$$degree^UPRN2(pattern)
 . set patterns(part)=degree
 . quit
 quit
