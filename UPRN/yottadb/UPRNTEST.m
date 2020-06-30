UPRNTEST ; ; 3/20/20 2:44pm
 S ^%W(17.6001,"B","GET","api/getcsv","GETCSV^UPRNTEST",77)=""
 S ^%W(17.6001,77,"AUTH")=1
 S ^%W(17.6001,77,0)="GET"
 S ^%W(17.6001,77,1)="api/getcsv"
 S ^%W(17.6001,77,2)="GETCSV^UPRNTEST"
 QUIT
 
GETID() ;
 L ^AUDIT:5
 I '$T Q 0
 S ID=$I(^AUDIT)
 L -^AUDIT
 Q ID
 
GETCSV(result,arguments) ;
 K ^TMP($J)
 S CR=$C(13,10)
 ;
 set adrec=$Get(arguments("adrec"))
 set del=$Get(arguments("delim"))
 set ids=$Get(arguments("ids"))
 i $g(del)="" s del=","
 S ^TEST=adrec
 
 S zID=$$GETID()
 ;S ^AUDIT(ID)=adrec_"|"_$HOROLOG
 
 ;S ^TMP($J,1)="TEST"
 K json
 K ^temp($j)
 ;D GETUPRN^UPRNMGR(adrec)
 D GETUPRN^UPRNMGR(adrec,"","","",0,0)
 K b
 D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 set UPRN=$get(b("UPRN"))
 ;S ^PS($O(^PS(""),-1)+1)=UPRN_"~"_ids_"~"_adrec
 S ^AUDIT(zID)=UPRN_"|"_ids_"|"_adrec_"|"_$HOROLOG
 ;do META(.b)
 set ALG=$get(b("Algorithm"))
 set QUAL=$get(b("Qualifier"))
 set MATPATBUILD=$get(b("Match_pattern","Building"))
 set MATPATFLAT=$get(b("Match_pattern","Flat"))
 set MATPATNUMBER=$get(b("Match_patrtern","Number"))
 set MATPATPSTCDE=$get(b("Match_patrtern","Postcode"))
 set MATPATSTRT=$get(b("Match_patrtern","Street"))
 set QUALITY=$get(b("Address_format"))
 ;S ^PS($O(^PS(""),-1)+1)=$G(LONG)
 S (COORD,LAT,LONG,POINT,X,Y,CLASS)=""
 if UPRN'="" do
 .;S ^FRED($O(^FRED(""),-1)+1)=UPRN_"~"_$A(UPRN)
 .S COORD=$piece($get(^UPRN("U",UPRN)),"~",7)
 .S LAT=$P(COORD,",",3),LONG=$P(COORD,",",4)
 .S POINT=$P(COORD,",",3),X=$P(COORD,",",1),Y=$P(COORD,",",2)
 .S CLASS=$piece($get(^UPRN("CLASS",UPRN)),"~",1)
 .quit
 S LOCALITY=$get(b("ABPAddress","Locality"))
 S NUMBER=$g(b("ABPAddress","Number"))
 S ORG=$g(b("ABPAddress","Organisaton"))
 S POSTCODE=$g(b("ABPAddress","Postcode"))
 S STREET=$g(b("ABPAddress","Street"))
 S TOWN=$g(b("ABPAddress","Town"))
 s csv=LOCALITY_del_NUMBER_del_ORG_del_POSTCODE_del_STREET_del_TOWN
 set csv=csv_del_ALG_del_QUAL_del_MATPATBUILD_del_MATPATFLAT_del
 s csv=csv_MATPATNUMBER_del_MATPATPSTCDE_del_MATPATSTRT_del
 s csv=csv_QUALITY_del_$g(LAT)_del_$g(LONG)_del_$g(POINT)_del_$g(X)_del_$g(Y)_del_$g(CLASS)_del_UPRN
 s ^TMP($J,1)=csv
 set result("mime")="text/plain, */*"
 set result=$na(^TMP($j))
 QUIT
 ;
META(b) ;
 q
 quit
