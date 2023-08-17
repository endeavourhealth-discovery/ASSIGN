UPRND ;Import delta routine [ 06/12/2020  10:45 AM ]
 
 ;
 d files
SURE ;
 W !!,"Are you sure you wish to proceeed !!?"
 r *yn s yn=$$lc^UPRNL($C(yn))
 i yn="n" q
 i yn'="y" G SURE
 ;K ^UPRN
 s del=$c(9)
 s abp=^UPRNF("abpdeltafolder")
 s folder=abp
 F key="U","DPA","LPI","X5","X3","X5A","X1","X.STR","STR","LPSTR" D
 .K ^UPRN(key)
 D IMPORT(folder)
 q
IMPORT(folder)     ;
 LOCK ^IMPORT:1 I '$T Q
 s abp=folder
 S $ZT="ERROR^UPRN1"
 i $e(abp,$l(abp))="\" s abp=$e(abp,1,$l(abp)-1)
 K ^IMPORT
 S ^IMPORT("START")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 s ^IMPORT("FOLDER")=$$ESCAPE(abp)
 D IMPSTR
 D IMPBLP
 D IMPDPA
 D IMPLPI
 D IMPCLASS
 D AREAS
 D SETSWAPS^UPRNU
 K ^IMPORT("LOAD")
 S ^IMPORT("END")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 LOCK
 Q
ERROR ;
 S ze=$ZE
 S ^IMPORT("STATUS")="ERROR"
 S ^IMPORT("ERROR")=ze
 s error=""
 I $ZE["MODER" D
 .s error="Unable to read "_^IMPORT("LOAD")_"- "_file
 S ^IMPORT("ERRORTEXT")=error
 H
 q
ESCAPE(string)     ;
 n i,output
 s output=""
 f i=1:1:$l(string) d
 .i $e(string,i)="\" s output=output_"\\" q
 .s output=output_$e(string,i)
 q output
 
 d IMPCOUNT
 s del=","
 w !,"Importing street descriptors..."
 D IMPSTR
 w !,"Importing uprns...."
 D IMPBLP
DPA w !,"Importing DPA file..."
 D IMPDPA
 w !,"Importing LPI file...."
LPI D IMPLPI
 w !,"Importing class records...."
 D IMPCLASS
 q
IMPDISC ;
 w !,"Importing discovery addresses..."
ADN d IMPADNO
 W !,"Post code areas"
POST D AREAS
 w !,"Cross referencing wrongly spelled streets..."
 D LEVENSTR
 w !,"Done."
 W !
 Q
AREAS ;
 K ^UPRN("AREAS")
 s post=""
 for  s post=$O(^UPRNX("X1",post)) q:post=""  d
 .s area=$$area^UPRN(post)
 .S ^UPRN("AREAS",area)=""
 q
IMPCLASS ;
 S ^IMPORT("LOAD")="Class file"
 s file=abp_"\ID32_Class_Records.CSV"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 o 51:(abp_"\ID32_Class_Records.csv")
 u 51 r rec
 for  u 51 r rec q:rec=""  d
 .S uprn=$p(rec,",",4)
 .s code=$tr($p(rec,",",6),"""")
 .;DS-start classfication scheme added
 .s scheme=$p(rec,",",7)
 .i scheme'["AddressBase" q
 .s newrec=code
 .s ^UPRN("CLASS",uprn)=newrec
 c 51
 
DS3 ;
RESIDE ;Imports residential codes
 S ^IMPORT("LOAD")="Residential code file"
 s file=abp_"\Residential_codes.txt"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 o 51:(file)
 u 51 r rec
 for  u 51 r rec q:rec=""  d
 .S include=$p(rec,$c(9),1)
 .s code=$p(rec,$c(9),2)
 .s term=$p(rec,$c(9),3)
 .S ^UPRN("CLASSIFICATION",code,"term")=term
 .S ^UPRN("CLASSIFICATION",code,"residential")=include
DS4 C 51
 q
LEVENSTR ;
 ;K ^UPRNW("SFIX")
 K ^UPRNW("Done")
 s count=0
 s adno=$g(dls)
 f count=1:1 s adno=$O(^UPRNI("D",adno),-1) q:adno=""  d
 .s adrec=^(adno)
 .s (build,street,dep,loc)=""
 .S build=$p(adrec,"~",1)
 .s street=$p(adrec,"~",2)
 .i $l(adrec,"~")>3 d
 ..s dep=$p(adrec,"~",3)
 .i $l(adrec,"~")>4 d
 ..s loc=$p(adrec,"~",4)
 .f var="build","street","dep","loc" do
 ..q:@var=""
 ..S word=$p(@var," ",1)
 ..q:word?1n.n.e
 ..s word=$tr(word,".,;")
 ..Q:word=""
 ..q:$D(^UPRNX("X.W",word))
 ..q:$D(^UPRNW("Done",word))
 ..s st=$e(word,1,2)
 ..s match=st
 ..for  s match=$O(^UPRNX("X.W",match)) q:($e(match,1,2)'=st)  d
 ...I $$levensh^UPRNU(word,match,5,2) d
 ....s ^UPRNW("SFIX",word,match)=""
 ....s ^UPRNW("Done",word)=""
 q
IMPADNO ;
 w !,"Importing discovery addresses..."
 i country="w" d Wales
 i country="e" d England
 q
Wales ;Imports welsh addressses
 s adno=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRNI("M")
 K ^UPRNI("D")
 s del=$c(9)
 o 51:(abp_"\addresses.txt")
 u 51 r rec
 f lno=1:1:764000 u 51  d
 .u 51 r rec
 .i rec="" Q
 .s adno=$p(rec,del,1)
 .s line1=$p(rec,del,2)
 .s line2=$p(rec,del,3)_" "_$p(rec,del,4)
 .S line3=$p(rec,del,5)
 .s line4=$p(rec,del,6)
 .s post=$tr($p(rec,del,7)," ")
 .s ^UPRNI("D",adno)=$$lt^UPRNL($$lc^UPRNL(line1_"~"_line2_"~"_line3_"~"_$p(line4,",")_"~"_post))
 c 51
 q
England s adno=0
 s count=0
 S fin=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRNI("M")
 K ^UPRNI("D")
 s del=","
 o 51:(adrfile)
 u 51 r header
 for  u 51 r rec q:rec=""  d
 .S rec=$tr(rec,$C(9),",")
 .s adno=adno+1
 .s adlines=$p(rec,del,3,100)
 .F i=20:-1:1 I $P(adlines,del,i)'="" Q
 .s adlines=$p(adlines,del,1,i)
 .s address=$$lc^UPRNL($tr(adlines,",","~"))
 .s address=$tr(address,"""","")
 .s ^UPRNI("D",adno)=address
 .s line1=$p(rec,del,3)
 .s line2=$p(rec,del,4)
 .s line3=$p(rec,del,5)
 .s line4=$p(rec,del,6)
 .S post=$p(rec,del,8)
 .s prac=$p(rec,del,1)
 .s pat=$p(rec,del,2)
 .s adno=adno+1
 .s ^UPRNI("D",adno)=$tr($$lt^UPRNL($$lc^UPRNL(line1_"~"_line2_"~"_line3_"~"_$p(line4,",")_"~"_post)),"""")
 .s ^UPRNI("D",adno,"P")=prac_"~"_pat
 .q
 c 51
 q
 f lno=1:1:1000000 u 51  d
 .u 51 r rec
 .i rec="" Q
 .s lno=lno+1
 .s adrec=$p(rec,",",2,200)
 .I adrec="" q
 .s line="",text=""
 .s type=$p(adrec,":",1)
 .s count=count+1
 .i $e(type,1,6)="""text""" d  q
 ..d TXTADNO($p(adrec,":",2,200))
 .i $e(type,1,6)="""line""" d  q
 ..s line=$p(adrec,"""line"":",2,200)
 ..D LINEADNO(line)
 .i adrec["""line""" d  q
 ..s line=$p(adrec,"""line"":",2,20)
 ..D LINEADNO(line)
 .B
 .q
 c 51
 s adno=0
 s rec=""
 for  s rec=$O(^TUPRN($J,"ITX",rec)) q:rec=""  d
 .s adno=adno+1
 .s ^UPRNI("D",adno)=rec
 .s line=""
 .for  s line=$O(^TUPRN($J,"ITX",rec,line)) q:line=""  d
 ..s ^UPRNI("D",adno,line)=""
 K ^TUPRN($J,"ITX")
EEng q
TXTADNO(adrec)       ;
 s text=adrec
 i rec["""line"":" d
 .s line=$p(adrec,"""line"":",2,200)
 .S text=$p(adrec,"""line"":",1)
 S text=$tr(text,"""")
 I $P(text,",",$l(text,","))="" d
 .s text=$p(text,",",1,$l(text,",")-1)
 .i $p(text,",",$l(text,","))=" " d
 ..s text=$p(text,",",1,$l(text,",")-1)
 i $L(text,",")<2 q
 s text=$tr(text,",","~")
 s text=$$tr^UPRNL(text,"~ ","~")
 S text=$$lc^UPRNL(text)
 s ^TUPRN($J,"ITX",text,lno)=""
 s fin=fin+1
 q
LINEADNO(line)     ;
 s line=$tr(line,"""")
 s addline=""
 s house="",street="",locality="",loc2="",town="",post="",county=""
 s add12=$p($p(line,"]",1),"[",2)
 f i=1:1:$l(add12,",") d
 .s var=$p(add12,",",i)
 .i i=1 s house=var q
 .i i=2 s street=var q
 .i i=3 s locality=var Q
 .i i>3 s loc2=$S(loc2="":var,1:loc2_","_var)
 s rest=$p($p(line,"],",2,200),"{")
 f i=1:1:$l(rest,",") d 
 .s attval=$p(rest,",",i)
 .s att=$p(attval,":")
 .s value=$p($p(attval,":",2),"{")
 .i att="postalCode" s post=value q
 .i att="district" s county=value q
 .i att="city" s town=value q
 .i att="" q
 .i att="state" q
 .s value=county_" "_value
 s struct=""
 s post=$tr(post," ")
 f var="house","street","locality","loc2","town","county","post" d
 .i @var'="" d
 ..s struct=$s(struct="":@var,1:struct_"~"_@var)
 s struct=$tr(struct,",","~")
 s ^TUPRN($J,"ITX",struct,lno)=""
 
 s fin=fin+1
 Q
ATTVAL(attribut,data)       ;
 n value
 s value=$p(data,attribute,":",2)
 s value=$tr(value,"""","")
 q value
 
 ;
IMPDPA ;Imports and indexes the DPA file.
 S ^IMPORT("LOAD")="DPA file"
 s file=abp_"\ID28_DPA_Records.CSV"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 D SETSWAPS^UPRNU
 s del=","
 s d="~"
 o 51:(abp_"\ID28_DPA_Records.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),""".'")
 .s rec=$$tr^UPRNL(rec,", ,",",,")
 .s rec=$tr(rec,"""","")
 .s uprn=$p(rec,del,4)
 .I uprn="46009991" b
 .I '$D(^UPRN("U",uprn)) q
 .s post=$tr($p(rec,del,16)," ")
 .S key=$p(rec,del,5)
 .set org=$p(rec,del,6)
 .set dep=$p(rec,del,7)
 .s flat=$p(rec,del,8)
 .s build=$$lt^UPRNL($p(rec,del,9))
 .s bno=$p(rec,del,10)
 .s depth=$$lt^UPRNL($p(rec,del,11))
 .i depth?1n.n1" ".1l.e,bno="" d
 ..s bno=$p(depth," ")
 ..s depth=$p(depth," ",2,20)
 .s street=$$lt^UPRNL($p(rec,del,12))
 .I street?1n.n1" "1l.e,bno="" d
 ..s bno=$p(street," ")
 ..s street=$p(street," ",2,20)
 .;s ddeploc=$p(rec,del,13)
 .s deploc=$$lt^UPRNL($p(rec,del,13))
 .s loc=$p(rec,del,14)
 .S town=$p(rec,del,15)
 .S ptype=$p(rec,del,17)
 .s suff=$p(rec,del,18)
 .i build?1n.n1l d
 ..I flat="" d  q
 ...s flat=build,build=""
 ..i bno="" d  q
 ...s bno=build,build=""
 .i build?1n.n.l1"-"1n.n.l d
 ..I flat="" d  q
 ...s flat=build,build=""
 ..i bno="" d  q
 ...s bno=build,build=""
 .i build?1n.n.l1"-"1n.n1" "1e.e,flat="" d
 ..s flat=$p(build," ")
 ..s build=$p(build," ",2,20)
 .i build?1n.n.l1" "1e.e,flat="" d
 ..s flat=$p(build," ")
 ..s build=$p(build," ",2,10)
 .S newrec=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .i newrec'=$G(^UPRN("DPA",uprn,key)) d
 ..S ^UPRN("DPA",uprn,key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .if depth'="" s depth=$$correct^UPRNU(depth)
 .if deploc'="" s deploc=$$correct^UPRNU(deploc)
e .set newrec=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .i newrec=$G(^UPRN("U",uprn,"D",key)) q
e .set ^UPRN("U",uprn,"D",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .s table="D"
 .d setind
 .q
 c 51
 q
 
setind ;Sets indexes
welsh ;
 i street[" y " s street=$p(street," y ",1)_"-y-"_$p(street," y ",2,10)
 i build[" y " s build=$p(build," y ",1)_"-y-"_$p(build," y ",2,10)
 i town'="" S ^UPRNS("TOWN",town)=""
 i loc'="" S ^UPRNS("TOWN",loc)=""
 i $l(street," ")>6 q
 i $l(build," ")>6 q
 s pstreet=$$plural^UPRNU(street)
 s pbuild=$$plural^UPRNU(build)
 s pdepth=$$plural^UPRNU(depth)
 s indrec=post_" "_flat_" "_build_" "_bno_" "_depth_" "_street_" "_deploc_" "_loc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 S ^UPRNX("X",indrec,uprn,table,key)=""
 s indrec=post_" "_flat_" "_pbuild_" "_bno_" "_pdepth_" "_pstreet_" "_deploc_" "_loc
 for  q:(indrec'["  ")  s indrec=$$tr^UPRNL(indrec,"  "," ")
 s indrec=$$lt^UPRNL(indrec)
 S ^UPRNX("X",indrec,uprn,table,key)=""
 i deploc'="" d
 .s ^UPRNX("X5",post,street_" "_deploc,bno,build,flat,uprn,table,key)=""
 i depth'="" d
 .s ^UPRNX("X5",post,depth_" "_street,bno,build,flat,uprn,table,key)=""
 .s ^UPRNX("X5",post,street,bno,depth,flat_" "_build,uprn,table,key)=""
 .s ^UPRNX("X5",post,pstreet,bno,pdepth,flat_" "_pbuild,uprn,table,key)=""
 s ^UPRNX("X5",post,street,bno,build,flat,uprn,table,key)=""
 s ^UPRNX("X5",post,pstreet,bno,pbuild,flat,uprn,table,key)=""
 i depth'="" d
 .set ^UPRNX("X3",depth,bno,post,uprn,table,key)=""
 .set ^UPRNX("X3",pdepth,bno,post,uprn,table,key)=""
 .D indexstr("STR",depth)
 .D indexstr("STR",pdepth)
 i deploc'="",street="" d
 .S ^UPRNX("X5",post,deploc,bno,build,flat,uprn,table,key)=""
 i depth'="",street="" d
 .S ^UPRNX("X5",depth,bno,build,flat,uprn,table,key)=""
 .S ^UPRNX("X5",pdepth,bno,pbuild,flat,uprn,table,key)=""
 i street'="" d
 .set ^UPRNX("X3",street,bno,post,uprn,table,key)=""
 .set ^UPRNX("X3",pstreet,bno,post,uprn,table,key)=""
 .set ^UPRNX("X3",$tr(street," "),bno,post,uprn,table,key)=""
 .I depth'="" d
 ..set ^UPRNX("X3",depth_" "_street,bno,post,uprn,table,key)=""
 ..set ^UPRNX("X3",pdepth_" "_pstreet,bno,post,uprn,table,key)=""
 .do indexstr("STR",street)
 .do indexstr("STR",pstreet)
 i build'="" d
 .set ^UPRNX("X3",build,flat,post,uprn,table,key)=""
 .set ^UPRNX("X3",pbuild,flat,post,uprn,table,key)=""
 .do indexstr("BLD",build)
 .do indexstr("BLD",pbuild)
 i build'="",flat'="",street'="" d
 .set ^UPRNX("X2",build,street,flat,post,bno,uprn,table,key)=""
 I flat'="",bno'="",street'="",build'="" d
 .S ^UPRNX("X4",post,street,bno,flat,build,uprn,table,key)=""
 if build="",org'="" d
 .set ^UPRNX("X5",post,street,bno,org,flat,uprn,table,key)=""
 .set ^UPRNX("X5",post,pstreet,bno,org,flat,uprn,table,key)=""
 .if flat'="" d
 ..set ^UPRNX("X3",org,flat,post,uprn,table,key)=""
 ..do indexstr("BLD",org)
 I street'="",bno'="",build'="",flat'="" d
 .S ^UPRNX("X5A",post,street,build,flat,bno,uprn,table,key)=""
 .S ^UPRNX("X5A",post,pstreet,pbuild,flat,bno,uprn,table,key)=""
 I pstreet'=street!(pbuild'=build) d
 .I deploc'="" d
 ..s ^UPRNX("X5",post,pstreet_" "_deploc,bno,pbuild,flat,uprn,table,key)=""
 .I pdepth'="" d
 ..s ^UPRNX("X5",post,pdepth_" "_pstreet,bno,pbuild,flat,uprn,table,key)=""
eind q
 
indexstr(index,term)         ;Indexes street or building etc
 n strno,i,word
 if '$d(^UPRNX("X."_index,term)) d
 .S ^UPRNX("X."_index)=$G(^UPRNX("X."_index))+1
 .S strno=^UPRNX("X."_index)
 .S ^UPRNX("X."_index,term)=strno
 .s ^UPRNX(index,strno)=term
 s strno=^UPRNX("X."_index,term)
 f i=1:1:$l(term," ") d
 .s word=$p(term," ",1)
 .q:word=""
 .i $D(^UPRNS("CORRECT",word)) d
 ..s word=^UPRNS("CORRECT",word)
 .I $D(^UPRNS("ROAD",word)) q
 .I $D(^UPRNX("X."_index,word)) q
 .s ^UPRNX("X.W",word,index,strno)=""
 q
 
 
IMPLPI ;Imports and indexes LPI file
 S ^IMPORT("LOAD")="LPI file"
 s file=abp_"\ID24_LPI_Records.CSV"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 s del=","
 s d="~"
 o 51:(abp_"\ID24_LPI_Records.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$$lc^UPRNL(rec)
 .s rec=$tr(rec,"""")
 .s uprn=$p(rec,del,4)
 .I '$D(^UPRN("U",uprn)) q
 .s key=$p(rec,del,5)
LPIREC .s saos=$p(rec,del,12)
 .s saosf=$p(rec,del,13)
 .s saoe=$p(rec,del,14)
 .s saoef=$p(rec,del,15)
 .s saot=$p(rec,del,16)
 .s status=$p(rec,del,7)
 .s end=$p(rec,del,9)
 .s paos=$p(rec,del,17)
 .s paosf=$p(rec,del,18)
 .s paoe=$p(rec,del,19)
 .s paoef=$p(rec,del,20)
 .s paot=$p(rec,del,21)
 .s str=$p(rec,del,22)_"-"_$P(rec,del,6)
 .s org=""
 .;i status=8 D  q
 ..;U 0 w rec r t
 .i status=1,end'="" d
 ..u 0 w rec r t
 .S nrec=saos_"~"_saosf_"~"_saoe_"~"_saoef_"~"_saot
 .s nrec=nrec_"~"_paos_"~"_paosf_"~"_paoe_"~"_paoef_"~"_paot
 .s nrec=nrec_"~"_str_"~"_status
 .i nrec'=$g(^UPRN("LPI",uprn,key)) d
 ..S ^UPRN("LPI",uprn,key)=nrec
 .k dpadd
EREC .d GETLPI^UPRNU(saos,saosf,saoe,saoef,saot,paos,paosf,paoe,paoef,paot,str,uprn,.dpadd)
 .s flat=dpadd("flat")
 .s build=$$lt^UPRNL(dpadd("building"))
 .s depth=""
 .s street=$$lt^UPRNL(dpadd("street"))
 .s bno=dpadd("number")
 .s deploc=$$lt^UPRNL(dpadd("deploc"))
 .s loc=$$lt^UPRNL(dpadd("locality"))
 .s post=dpadd("postcode")
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .set town=dpadd("town")
 .i $l(street," ")>5 q
 .i $l(build," ")>5 q
L .set newrec=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post
 .I newrec=$G(^UPRN("U",uprn,"L",key)) q
L .set ^UPRN("U",uprn,"L",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post
 .s table="L"
 .do setind
 c 51
 Q
IMPCOUNT ;
 S ^IMPORT("LOAD")="Counties"
 s del=$C(9)
 ;K ^UPRN("COUNTY")
 s file=abp_"\Counties.txt"
 S ^IMPORT("FILE")=$$ESCAPE(file)
 o 51:(file)
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s county=$p(rec,del,2)
 .s pop=$p(rec,del,5)
 .s region=$p(rec,del,4)
 .s opop=$G(^UPRNS("COUNTY",county,"population"))
 .i opop'=pop d
 ..S ^UPRNS("COUNTY",county,"population")=pop
 .s oreg=$G(^UPRNS("COUNTY",county,"region"))
 .i oreg'=region d
 ..S ^UPRNS("COUNTY",county,"region")=region
 C 51
 Q
 ;
IMPSTR ;
 S ^IMPORT("LOAD")="Street descriptors"
 s del=","
 S file=abp_"\ID15_StreetDesc_Records.CSV"
 S ^IMPORT("FILE")=$$ESCAPE(file)
 o 51:(abp_"\ID15_StreetDesc_Records.CSV")
 u 51 r rec
 for  u 51  d  q:rec=""
 .u 51 r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s usrn=$p(rec,del,4)
 .s name=$p(rec,del,5)
 .s locality=$p(rec,del,6)
 .S town=$p(rec,del,7)
 .s admin=$p(rec,del,8)
 .S lang=$p(rec,del,9)
 .s newrec=name_"~"_locality_"~"_admin_"~"_town
 .i newrec'=$G(^UPRN("LPSTR",usrn_"-"_lang)) d
 ..S ^UPRN("LPSTR",usrn_"-"_lang)=name_"~"_locality_"~"_admin_"~"_town
 C 51
 Q
IMPBLP ;
 S ^IMPORT("LOAD")="UPRN file"
 s file=abp_"\ID21_BLPU_Records.CSV"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 s recno=0
 s del=","
 o 51:(file)
 u 51 r rec
 for  u 51  d  q:rec=""
 .U 51 r rec
 .Q:rec=""
 .s recno=recno+1
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s post=$tr($p(rec,del,21)," ")
 .s uprn=$p(rec,del,4)
 .s status=$p(rec,del,5)
 .;i status=8 q
 .s bpstat=$p(rec,del,6)
 .s insdate=$p(rec,del,16)
 .s update=$p(rec,del,18)
 .s parent=$p(rec,del,8)
DS1 .s coord1=$p(rec,del,9)_","_$P(rec,del,10)_","_$p(rec,del,11)_","_$p(rec,del,12)_","_$p(rec,del,13)
 .s local=$p(rec,del,14)
 .s adpost=$p(rec,del,20)
 .S newrec=$tr(adpost_"~"_post_"~"_status_"~"_bpstat_"~"_insdate_"~"_update_"~"_coord1_"~"_local,"""")
DS2 .S ^UPRN("U",uprn)=$tr(adpost_"~"_post_"~"_status_"~"_bpstat_"~"_insdate_"~"_update_"~"_coord1_"~"_local,"""")
 .i parent'="" d
 ..i '$D(^UPRN("UPC",parent,uprn)) d
 ...S ^UPRN("UPC",parent,uprn)=""
 ..i '$d(^UPRN("UCP",uprn,parent)) d
 ...S ^UPRN("UCP",uprn,parent)=""
 .if post'="" d
 ..I '$D(^UPRNX("X1",post,uprn)) d
 ...S ^UPRNX("X1",post,uprn)=""
 c 51
 q
files ;
 s country=""
 W !,"England or Wales : " r *c
 i c=13 q
 s country=$c(c)
 s folder=""
 s folder=$G(^UPRNF("abpdeltafolder"))
 w !,"ABP delta folder ("_folder_") :" r folder
 i folder="" s folder=$g(^UPRNF("abpdeltafolder"))
 s att=$ZOS(10,folder)
 i att<2 W *7,"Error no folder " H 2 G files
 s ^UPRNF("abpdeltafolder")=folder
 s country=$$lc^UPRNL(country)
 i country="" q
 i country'="e"&(country'="w") G files
 i country="e" s folder="Shared"
 i country="w" s folder="Wales"
 q
