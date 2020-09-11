THOU ; ; 7/3/20 9:04am
 K
 K ^CSV
 S T=0,C=1
 ;S F="/tmp/UPRN-TH 3-9.txt"
 ;S F1="/tmp/yotta-TH 3-9.txt"
 ;S F="/tmp/UPRN-100K 3-9 Residential only.txt"
 ;S F1="/tmp/yotta-UPRN-100K 3-9 Residential only"
 ;S F="/tmp/V4-1 residential.txt"
 ;S F1="/tmp/yotta-V4-1 residential.txt"
 S F="/tmp/v4-2.txt"
 S F1="/tmp/yotta-v4-2.txt"
 C F,F1
 O F:(readonly)
 O F1:(newversion)
 U F R STR
 F  U F R STR Q:$ZEOF  DO
 .;U 0 W !,STR
 .S ID=$P(STR,$C(9))
 .S CADR=$$TR^LIB($P(STR,$C(9),7),"""","")
 .S MSMUPRN=$P(STR,$C(9),2)
 .I MSMUPRN=0 QUIT
 .D GETUPRN^UPRNMGR(CADR,"","","",0,0)
 .K b
 .D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 .S YUPRN=$get(b("UPRN"))
 .I YUPRN'=MSMUPRN DO
 ..U 0 W !,ID," * ",CADR," * YOTTA=",YUPRN," * MSM=",MSMUPRN S T=T+1
 ..S ALG=$get(b("Algorithm"))
 ..S CLASS=$get(b("Classification"))
 ..S MATCH="",NODE="D"
 ..I YUPRN="" S YUPRN="ZZZZ"
 ..S KEY=$O(^TUPRN($J,"MATCHED",YUPRN,"D",""))
 ..S:KEY="" KEY=$O(^TUPRN($J,"MATCHED",YUPRN,"L","")),NODE="L"
 ..I KEY'="" S MATCH=$GET(^TUPRN($J,"MATCHED",YUPRN,NODE,KEY))
 ..S ^CSV(C)=ID_$C(9)_MSMUPRN_$C(9)_YUPRN_$C(9)_ALG_$C(9)_CLASS_$C(9)_MATCH_$C(9)_CADR
 ..S C=C+1
 ..QUIT
 .;U 0 W !,"TEST: " R *Y
 .QUIT
 C F
 U F1 W "id",$c(9),"Discovery UPRN",$c(9),"Yotta UPRN",$c(9),"Y Algorithm",$c(9),"Y Classification",$c(9),"Y Match",$c(9),"Candidate address",!
 S C="" F  S C=$O(^CSV(C)) Q:C=""  U F1 W ^(C),!
 C F1
 QUIT
LOAD ;
 K ^UPRNI
 S F="/tmp/10000_EAST_LONDON.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .S ADNO=$P(STR,",")
 .S ADR=$$TR^LIB($P(STR,",",2,99),$C(13),"")
 .;S ADR=$$TR^LIB(ADR,",","~")
 .U 0 W !,ADNO,"~",ADR
 .S ^UPRNI("D",ADNO)=ADR
 .QUIT
 C F
 QUIT
 
ADD ; * CORRECT VERSION
 s d=$c(9),dset="X"
 s vglob="^UPRN5"
 s ver=1.1,version=1.1
 s resdir="/tmp"
 s old="1.0"
 S f=resdir_"/UPRN_"_dset_"_Address Matching "_ver_".txt"
 close f
 o f:(newversion)
 u f w "id"_d_"Discovery UPRN"_d_"Manual uprn"
 u f w d_"Mismatch"
 u f w d_"Correct"_d_old_d_"Candidate address"
 u f w d_"Discovery ABP match"_d_"Manual ABP match"_d_"Discovery status"_d_"Discovery class"_d_"Manual status"_d_"Manual class"
 
 u f w d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"
 S adno=""
 for  s adno=$o(^UPRNI("D",adno)) q:adno=""  d
 .S (uprn,orec,muprn,correct,addr,maddr,status,class,mstatus,mclass)=""
 .s (mtable,mkey,alg,match,table,key)=""
 .;s orec=^UPRNI("D",adno,"orig")
 .s uprn=$O(^UPRNI("M",adno,""))
 .S @vglob@(version,adno)=uprn
 .i uprn'="" d
 ..f table="L","D" q:$D(^UPRNI("M",adno,uprn,table))
 ..s key=$O(^UPRNI("M",adno,uprn,table,""))
 ..s match=^(key)
 ..S alg=^UPRNI("M",adno,uprn,table,key,"A")
 ..s ^UPRNI("ALG",alg)=$g(^UPRNI("ALG",alg))+1
 ..D GETDATA(uprn,table,key,.addr,.status,.class)
 .i dset="TH" s muprn=$G(^UPRNI("True",adno))
 .i muprn'="" d
 ..D GETDATA(muprn,.mtable,.mkey,.maddr,.mstatus,.mclass)
 .s ouprn=$G(@vglob@(old,adno))
 .i ouprn="" s ouprn=0
 .i uprn="" s uprn=0
 .i muprn="" s muprn=0
 .s guprn=$G(^UPRNI("agreedmismatch",adno))
 .S correct="ZZZZ"
 .i uprn=0 d
 ..s correct="X"
 .e  d
 ..i uprn=muprn d
 ...s correct="Y"
 ..e  d
 ...i uprn=guprn d
 ....s correct="A"
 ...e  d
 ....I uprn'=ouprn s correct="?" q
 ....I muprn'=0,uprn'=muprn s correct="N" q
 ....s correct="Y"
 .s mismatch=$s(uprn=muprn:"N",1:"Y")
 .s qual=$$qual^UPRN2(match)
 .s out=adno_d_uprn_d_muprn_d_mismatch_d_correct_d_ouprn_d_orec
 .s out=out_d_addr_d_maddr_d_status_d_class_d_mstatus_d_mclass
 .s out=out_d_alg_d_qual_d_match_d_table_d_key
 .;
 .U f w !,out
 .;w !,out
 .quit
 close f
 QUIT
 
GETDATA(uprn,table,key,address,status,class)   ;Returns data on uprn
 n (uprn,table,key,address,status,class)
 i '$d(^UPRN("U",uprn)) d
 .s status="NULL"
 .s class="NULL"
 E  D
 .s status=$P(^UPRN("U",uprn),"~",3)
 .s class=^UPRN("CLASS",uprn)
 I '$D(^UPRN("U",uprn)) d
 .s address=""
 e  d
 .i $g(table)="" f table="L","D" q:$d(^UPRN("U",uprn,table))
 .i $g(key)="" s key=$O(^UPRN("U",uprn,table,""))
 .D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 .s address=org_" "_flat_" "_build_","_bno_" "_depth_" "_street_","_deploc_" "_loc_","_town_","_post
 .S address=$$tr^UPRNL($$tr^UPRNL(address,"  "," "),",,",",")
 q
 
ADDRESS ;
 new out51,out52
 
 s d=$c(9)
 S resdir="/tmp"
 S (ver,version)=1
 
 set out51=resdir_"/UPRN_Matched "_ver_".txt"
 close out51
 open out51:(newversion)
  
 set out52=resdir_"/UPRN_Matched "_ver_"-tocheck.txt"
 close out52
 open out52:(newversion)
  
 use out51 w "ID"_d_"Discovery address"_d_"UPRN"_d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"_d_"Status"
 
 use out51 w d_"Missing"_d_"Invalid"_d_"No post code"_d_"invalid post code"
 
 use out52 w "ID"_d_"Discovery address"_d_"APB address"_d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"_d_"Status"
 
 s d=$c(9)
 S start=""
 S end=9999999999999
 s adno=$o(^UPRNI("M",start))-1
 s row=0
 K ^TDONE,^ZTUPRN
 S T=0
 for  s adno=$O(^UPRNI("M",adno)) q:adno=""  d  q:(adno>end)
 .s uprn=$O(^UPRNI("M",adno,""))
 .s adrec=^UPRNI("D",adno)
 .d adrqual(adno,adrec)
 .S ^UPRN3(version,adno)=uprn
 .i $D(^UPRNI("M",adno,uprn,"L")) D OUT(adno,uprn,"L") S T=T+1 Q
 .i $D(^UPRNI("M",adno,uprn,"D")) D OUT(adno,uprn,"D") S T=T+1 Q
 .Q
 close out51,out52
 Q
 
adrqual(adno,rec)         ;
 n missing,nopost,invadr,invpost
 s (missing,nopost,invadr,invpost)=0
 I $tr(rec,",")="" d
 .s missing=1
 i $l($tr(rec,","))<9 d
 .s invadr=1
 set rec=$tr(rec,"}{","")
 set length=$length(rec,",")
 set post=$$lc^UPRNL($p(rec,",",length))
 set post=$tr(post," ") ;Remove spaces
 i post="" s nopost=1
 i '$$validp^UPRN5(post) s invpost=1
 S ^UPRNI("Q",adno)=missing_"~"_invadr_"~"_nopost_"~"_invpost
 QUIT
 
 
OUT(adno,uprn,table) 
 I $D(^TDONE(adno)) u 0 w !,"done" r *y
 S ^TDONE(adno)=""
 s disco=^UPRNI("D",adno)
 s key=""
 for  s key=$O(^UPRNI("M",adno,uprn,table,key)) q:key=""  d
 .s matchrec=^(key)
 .S ^ZTUPRN(adno)=$g(^ZTUPRN(adno))+1
 .S alg=^UPRNI("M",adno,uprn,table,key,"A")
 .S qual=^UPRNI("Q",adno)
 .s missing=$p(qual,"~")
 .s invalid=$p(qual,"~",2)
 .s nopost=$p(qual,"~",3)
 .s invpost=$p(qual,"~",4)
 .k address
 .s ^UPRNI("ALG",alg)=$g(^UPRNI("ALG",alg))+1
 .s status=$P(^UPRN("U",uprn),"~",3)
 .;i table="L" s status=$P(^UPRN("LPI",uprn,key),"~",12)
 .D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 .s abp=org_" "_flat_" "_build_","_bno_" "_depth_" "_street_","_deploc_" "_loc_","_town_","_post
 .S abp=$$tr^UPRNL($$tr^UPRNL(abp,"  "," "),",,",",")
 .;s out=adno_d_$tr(disco,"~",",")_d_abp
 .s out=adno_d_$tr(disco,"~",",")
 .s out=out_d_uprn_d_alg_d_$$qual(matchrec)_d_matchrec_d_table_d_key_d_status
 .s out=out_d_missing_d_invalid_d_nopost_d_invpost
 .; ** remove
 .;W !,out
 .use out51 w !,out
 .if $g(out52) use out52 W !,adno_d_$tr(disco,"~",",")_d_abp_d_alg_d_matchrec_d_uprn_d_table_d_key
 q
qual(matchrec)     ;
 N (matchrec)
 i matchrec="" q ""
 i matchrec["c" q "Child"
 i matchrec["a" q "Parent"
 i matchrec["s" q "Sibling"
 s qual="Best match "_$s('$D(^TPARAMS($J,"commercials")):"(residential)",1:"(+commercial)")_"match"
 Q qual
UNMATCHED ;
 S A=""
 S F="/tmp/unmatched.txt"
 C F
 O F:(newversion)
 F  S A=$O(^UPRNI("UM",A)) Q:A=""  DO
 .S ADR=^UPRNI("D",A)
 .U F W A,"|",ADR,!
 .QUIT
 C F
 QUIT
