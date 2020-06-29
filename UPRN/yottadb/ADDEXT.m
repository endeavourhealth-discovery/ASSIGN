ADDEXT ; ; 8/2/19 10:15am
 ;D GO("/tmp/address_extract.csv")
 D GO2("/tmp/address_extract.csv")
 QUIT
 
 ;10008321125,D,53129828,130-match2ca,Pe,Se,Ne,Bp,Fe
 ;$C(9)
 ;^TUPRN(15011,"MATCHED")=1
 ;^TUPRN(15011,"MATCHED",10008321125,"D",53129828)="Pe,Se,Ne,Bp,Fe"
 ;^TUPRN(15011,"MATCHED",10008321125,"D",53129828,"A")="130-match2ca"
 ;
 
OUTPUT ; 
 S F="/tmp/20190802_YottaUPRN_NoReturn.txt"
 O F:(writeonly)
 S (G)=""
 F  S G=$O(^NOMATCH(G)) Q:G=""  D
 .S OUT=^NOMATCH(G)
 .U F W OUT,!
 .QUIT
 C F
 QUIT
OUTPUT2 ;
 S F="/tmp/20190802_YottaUPRN_Return.txt"
 O F:(writeonly)
 S (G,Z)=""
 F  S G=$O(^MATCH(G)) Q:G=""  D
 .F  S Z=$O(^MATCH(G,Z)) Q:Z=""  D
 ..U F W ^(Z),!
 ..Q
 .Q
 C F
 QUIT
 
MATCH(G) ;
 n uprn,a,b,z,codes
 set (uprn,a,b)=""
 for  set uprn=$order(^TUPRN($job,"MATCHED",uprn)) quit:uprn=""  do
 .for  set a=$order(^TUPRN($job,"MATCHED",uprn,a)) quit:a=""  do
 ..for  s b=$order(^TUPRN($job,"MATCHED",uprn,a,b)) quit:b=""  do 
 ...set alg=$get(^TUPRN($job,"MATCHED",uprn,a,b,"A"))
 ...set codes=$get(^TUPRN($job,"MATCHED",uprn,a,b))
 ...set z=$i(^MATCH)
 ...;w !,uprn,"*",a,"*",b,"*",alg
 ...set ^MATCH(G,z)=uprn_$c(9)_a_$c(9)_b_$c(9)_alg_$c(9)_codes
 ...quit 
 ..quit
 .quit
 quit
 
GO2(file) 
 new z,i,G,T
 
 K ^MATCH,^NOMATCH
 o file:(readonly):0
 
 S (G,T)=0
 
 for i=1:1 use file read x q:$zeof  do
 .set z=$tr(x,"""")
 .set orgpost=$p(z,",",1)
 .set personid=$p(z,",",2)
 .set add1=$p(z,",",3)
 .set add2=$p(z,",",4)
 .set add3=$p(z,",",5)
 .set add4=$p(z,",",6)
 .set county=$p(z,",",7)
 .set postcode=$p(z,",",8)
 .set adrec=add1_","_add2_","_add3_","_add4_","_county_","_postcode
 .set adrec=$tr(adrec,$c(13),"")
 .set orgpost=$tr(orgpost,$c(13),"")
 .d GETUPRN^UPRNMGR(adrec,"",orgpost)
 .I G#1000=0 U 0 W !,adrec
 .set G=G+1
 .if $data(^TUPRN($job,"MATCHED")) do MATCH(G)
 .if '$data(^TUPRN($job,"MATCHED")) set ^NOMATCH(G)=adrec_"|"_orgpost,T=T+1
 .quit
 
 close file
 
 W !,"T = ",T
 W !,"G = ",G
 
 quit
 
GO(file) 
 new z,i
 o file:(readonly):0
 
 S (G,T)=0
 
 for i=1:1 use file read x q:$zeof  do
 .set z=$tr(x,"""")
 .set orgpost=$p(z,",",1)
 .set personid=$p(z,",",2)
 .set add1=$p(z,",",3)
 .set add2=$p(z,",",4)
 .set add3=$p(z,",",5)
 .set add4=$p(z,",",6)
 .set county=$p(z,",",7)
 .set postcode=$p(z,",",8)
 .set adrec=add1_","_add2_","_add3_","_add4_","_county_","_postcode
 .;set adrec=add1_","_add2_","_add3_","_add4_","_county_","_orgpost
 .set adrec=$tr(adrec,$c(13),"")
 .set orgpost=$tr(orgpost,$c(13),"")
 .d GETUPRN^UPRNMGR(adrec,"",orgpost)
 .;
 .;U 0 W !,orgpost,!,adrec,!,^temp($j,1),! r *y
 .s json=^temp($j,1)
 .kill b,err
 .do DECODE^VPRJSON($name(json),$name(b),$name(err))
 .;u 0 w ! zwr b w !
 .I G#1000=0 U 0 w !,orgpost,!,adrec,!,$get(b("UPRN")),!
 .S G=G+1
 .I $G(b("UPRN"))="" S ^G(G)=adrec_"~"_orgpost,T=T+1
 .quit
 
 close file
 
 W !,"T = ",T
 W !,"G = ",G
 
 quit
