UPRNASRT ; ; 3/1/21 9:27am
 ; S A("uprn")="10034510842"
 ; D API^UPRNASRT("10034510842")
 ;
SET ;
 S X="Newham Dockside,1000,,Dockside Road,,,London,E162QU"
 S L=$$TR^LIB($$LC^LIB(X)," ","")
 S ^ASSERT(L)="10034510842"
 S ^ASSERT(X,"O")=L
 QUIT
 
SET2 ;
 ;S X="Newham Dockside,1000,,Dockside Road,,,London,E162QU"
 ;S L=$$TR^LIB($$LC^LIB(X)," ","")
 ;S ^ASSERT2(L)="Car Park At,Newham Dockside,1000,,Dockside Road,,West Beckton,Newham,E162QU"
 ;
 S ^ASSERT2("10downingst,westminster,london,sw1a2aa")="H M Prison Wormwood Scrubs,,,Du Cane Road,,,Hammersmith And Fulham,W120AE"
 S ^ASSERT2("10downingst,westminster,london,sw1a2aa","O")="10 Downing St,Westminster,London,SW1A2AA"
 QUIT
 
 ; *** REDUNDANT
API2(zuprn,oadrec) ;
 ;
 ;
 ;
 quit
 
SPELL(zadrec) 
 n i,line,corr,out
 s out=""
 F i=1:1:$L(zadrec,",") DO
 .S line=$P(zadrec,",",i)
 .F zq=1:1:$L(line," ") DO
 ..S word=$P(line," ",zq)
 ..S corr=$$C(word)
 ..s out=out_corr
 ..quit
 .quit
 QUIT out
 
C(var) ; correct
 n out
 S var=$$LC^LIB(var)
 s out=var
 i $data(^UPRNS("CORRECT",var)) s out=^(var)
 quit out
 
API(zuprn,oadrec,asserted) 
 ;
 ;S ^ZI(1)=asserted
 
 K ^TMP($J),^TADR($J)
 
 I $D(^ZASSERT2(asserted)) do  quit
 .;s ^bob="!!here!!"
 .S adrec=^ZASSERT2(asserted)
 .S alguprn="""?"""
 .set ^TMP($J,1)="[{""address_string"":"""_adrec_""",""uprn"":"_zuprn_",""alguprn"":"_alguprn_"}]"
 .;S ^bob=^TMP($J,1)
 .;
 .quit
 
 ;set uprn=$g(arguments("uprn"))
 set (n1,n2)=""
 ;S C=2,j=""
 ;S ^TMP($J,1)="{""uprn"":"""_uprn_""",""addresses"":["
 S C=1,j=""
 ;
 ;
 D GETUPRN^UPRNMGR(oadrec,"","","",0,0)
 set alguprn=$order(^TUPRN($J,"MATCHED",""))
 ;
 ;
 for  set n1=$o(^UPRN("U",zuprn,n1)) quit:n1=""  do
 .for  set n2=$o(^UPRN("U",zuprn,n1,n2)) q:n2=""  do
 ..s adr=$get(^UPRN("U",zuprn,n1,n2))
 ..if adr="" quit
 ..set flat=$$IN^LIB($p(adr,"~",1))
 ..s build=$$IN^LIB($p(adr,"~",2))
 ..s bno=$$IN^LIB($p(adr,"~",3))
 ..s depth=$$IN^LIB($p(adr,"~",4))
 ..s street=$$IN^LIB($P(adr,"~",5))
 ..s deploc=$$IN^LIB($P(adr,"~",6))
 ..s loc=$$IN^LIB($P(adr,"~",7))
 ..s town=$$IN^LIB($P(adr,"~",8))
 ..s post=$$UC^LIB($P(adr,"~",9))
 ..s level=$$IN^LIB($P(adr,"~",10))
 ..S adrec=flat_","_build_","_bno_","_depth_","_street_","_deploc_","_loc_","_town_","_post
 ..; remove any leading commas
 ..f zi=1:1:$length(adrec) q:$e(adrec,zi)'=","
 ..i zi>1 s adrec=$e(adrec,zi,$l(adrec))
 ..S adrec=$$ESC^VPRJSON(adrec)
 ..;s j=j_"{""address_string"":"""_adrec_"""},"
 ..set ^TMP($J,C)="{""address_string"":"""_adrec_""",""uprn"":"_zuprn_",""alguprn"":"_alguprn_"},"
 ..set C=C+1
 ..quit
 .quit
 ;set result=$na(^TMP($j))
 ;quit
 ;
 ;
 ;
 ;
 S ^TMP($J,1)="["_^TMP($J,1)
 S C=$O(^TMP($J,""),-1)
 S j=^TMP($J,C)
 ;s j=$e(j,1,$l(j)-1)_"]}"
 s j=$e(j,1,$l(j)-1)_"]"
 S ^TMP($J,C)=j
 ;
 quit
 
STT(adrec,uprn) ;
 n dkey,lkey,json
 i '$d(^UPRN("U",uprn)) quit
 s adrec=$$LC^LIB(adrec)
 s adrec=$$TR^LIB(adrec," ","")
 S ^ASSERT(adrec)=uprn
 
 S dkey=$O(^UPRN("U",uprn,"D",""))
 S lkey=$O(^UPRN("U",uprn,"L",""))
 
 ;I key="" quit
 ;D GETADR^UPRNU(uprn,"D",key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.lpost,.org)
 ;s classcode=$tr($p(^UPRN("CLASS",uprn),"~"),"""")
 
 K ^TUPRN($J)
 S ^TUPRN($J,"MATCHED")=1
 S ^TUPRN($J,"MATCHED",uprn,"D",dkey)="Pe,Se,Ne,Be,Fe"
 S ^TUPRN($J,"MATCHED",uprn,"D",dkey,"A")="asserted"
 S ^TUPRN($J,"MATCHED",uprn,"L",lkey)="Pe,Se,Ne,Be,Fe"
 S ^TUPRN($J,"MATCHED",uprn,"L",lkey,"A")="asserted"
 S json="{"
 D MATCHK^UPRNMGR(.json,0)
 S json=json_"}"
 ;W !,json
 S ^ASSERT(adrec,"J")=json
 S ^ASSERT(adrec,"D")=$H
 QUIT
