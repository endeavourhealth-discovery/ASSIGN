UPRN1 ;Import routine [ 06/10/2019  4:58 PM ] ; 6/22/20 12:20pm
 
 ;
 d files
SURE ;
 w !,"Full or delta upload ? :" r fulldelta
 s fulldelta=$$UC^LIB(fulldelta)
 i fulldelta="F" d
 .W !!,"You are about to delete the ABP data and replace it"
 .W !!,"Are you sure you wish to proceeed !!?"
 .r *yn s yn=$$lc^UPRNL($C(yn))
 .i yn="n" q
 .i yn'="y" G SURE
 .W !!,"Deleting data......"
 s del=$c(9)
 s abp=^UPRNF("abpfolder")
 s folder=abp
 W !,"Importing data please wait ...."
 D IMPORT(folder)
 q
IMPORT(folder)     ;
 ;Deals with bulk and deltas assuming that bulk inserts may be updates
 ;or new inserts
 ;Type="F" is a full bulk replace. Deletes all
 ;Type="D" is delta
 ;Type="A" means you are adding new addresses  does not delete
 ;Make sure you set the variable right
 ;I $ZV["IRIS" d $system.Process.SetZEOF(1)
 LOCK ^IMPORT:1 I '$T Q
 s abp=folder
 
 I $ZV'["IRIS" do
 .set $ECODE=""
 .set $ETRAP="GOTO ET^UTILS"
 .quit
 
 i $e(abp,$l(abp))="/" s abp=$e(abp,1,$l(abp)-1)
 K ^IMPORT
 S ^IMPORT("START")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 s ^IMPORT("FOLDER")=$$ESCAPE(abp)
 D RESIDE
 D IMPCLASS
 d IMPCOUNT
 D IMPSTR
 D IMPBLP
RDPA D IMPDPA
 D IMPLPI
 ;D AREAS
 D ^UPRNIND
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
 
 set file=abp_"/ID32_Class_Records.csv"
 close file
 set ^IMPORT("FILE")=$$ESCAPE(file)
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 if $zv["IRIS" o file:"R"
 use file read rec
 for  use file read rec q:rec=""  do
 .S uprn=$p(rec,",",4)
 .s code=$tr($p(rec,",",6),"""")
 .;DS-start classfication scheme added
 .s scheme=$p(rec,",",7)
 .i scheme'["AddressBase" q
 .s newrec=code
 .s ^UPRN("CLASS",uprn)=newrec
 .quit
 close file
 quit
 
RESIDE ;Imports residential codes
 S ^IMPORT("LOAD")="Residential code file"
 s file=abp_"/Residential_codes.txt"
 close file
 s ^IMPORT("FILE")=$$ESCAPE(file)
 I $ZV'["IRIS" DO
 .i $$10^ZOS(file)'=1 q
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 I $ZV["IRIS" DO
 .d $system.Process.SetZEOF(1)
 .O file:"R"
 .Q
 use file read rec
 for  use file read rec q:rec=""!($zeof)  do
 .S include=$p(rec,$c(9),1)
 .s code=$p(rec,$c(9),2)
 .s term=$p(rec,$c(9),3)
 .S ^UPRN("CLASSIFICATION",code,"term")=term
 .S ^UPRN("CLASSIFICATION",code,"residential")=include
 close file
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
 d files
 D ADRFILES
 w !,"England or Wales (e/w) : " r country
 w !,"Importing discovery addresses..."
 i country="w" d Wales
 i country="e" d England
 q
Wales ;Imports welsh addressses
 s adno=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRN("M")
 K ^UPRN("D")
 s del=$c(9)
 
 set file=abp_"\addresses.txt"
 close file
 open file:(readonly:exception="do BADOPEN")
 use file:exception="goto EOF"
 use file read rec
 f lno=1:1:764000 u file  do
 .use file read rec
 .if rec="" quit
 .set adno=$p(rec,del,1)
 .set line1=$p(rec,del,2)
 .set line2=$p(rec,del,3)_" "_$p(rec,del,4)
 .set line3=$p(rec,del,5)
 .set line4=$p(rec,del,6)
 .set post=$tr($p(rec,del,7)," ")
 .set ^UPRN("D",adno)=$$lt^UPRNL($$lc^UPRNL(line1_"~"_line2_"~"_line3_"~"_$p(line4,",")_"~"_post))
 .quit
 q
 
England s adno=0
 s count=0
 S fin=0
 s lno=0
 K ^TUPRN($J,"ITX")
 K ^UPRN("M")
 K ^UPRN("D")
 s del=","
 
 set file=adrfile
 close file
 open file:(readonly:exception="do BADOPEN")
 use file:exception="goto EOF"
 use file read header
 for  use file read rec q:rec=""  do
 .S rec=$tr(rec,$C(9),",")
 .s adno=adno+1
 .s adlines=$p(rec,del,3,100)
 .F i=20:-1:1 I $P(adlines,del,i)'="" Q
 .s adlines=$p(adlines,del,1,i)
 .s address=$$lc^UPRNL($tr(adlines,",","~"))
 .s address=$tr(address,"""","")
 .s ^UPRN("D",adno)=address
 .s line1=$p(rec,del,3)
 .s line2=$p(rec,del,4)
 .s line3=$p(rec,del,5)
 .s line4=$p(rec,del,6)
 .S post=$p(rec,del,8)
 .s prac=$p(rec,del,1)
 .s pat=$p(rec,del,2)
 .s adno=adno+1
 .s ^UPRN("D",adno)=$tr($$lt^UPRNL($$lc^UPRNL(line1_"~"_line2_"~"_line3_"~"_$p(line4,",")_"~"_post)),"""")
 .s ^UPRN("D",adno,"P")=prac_"~"_pat 
 .quit
 close file
 quit
 
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
 s file=abp_"/ID28_DPA_Records.csv"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 D SETSWAPS^UPRNU
 s del=","
 s d="~"
 
 set file=abp_"/ID28_DPA_Records.csv"
 close file
 
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 
 if $zv["IRIS" o file:"R"
 
 use file read rec
 
 for  d  q:rec=""
 .use file r rec
 .q:rec=""
 .s rec=$tr(rec,""".'")
 .s rec=$$tr^UPRNL(rec,", ,",",,")
 .s rec=$tr(rec,"""","")
 .s uprn=$p(rec,del,4)
 .S ^LASTREC=$GET(uprn)
ds7 .s ukey="U"
 .s post=$tr($p(rec,del,16)," ")
 .S key=$p(rec,del,5)
 .S change=$p(rec,del,2)
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
ds9 .S ^UPRN(ukey,uprn,"D",key,"O")=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .f var="flat","build","bno","depth","street","deploc","loc","town","post","org","dep","ptype" d
 ..s @var=$$LC^LIB(@var)
yrep .F var="flat","build","depth","street","deploc","loc" d
 ..s @var=$$welsh(@var)
 .S newrec=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 .set street=$$correct^UPRNU(street)
 .set bno=$$correct^UPRNU(bno)
 .set build=$$correct^UPRNU(build)
 .set flat=$$flat^UPRNU($$correct^UPRNU(flat))
 .set loc=$$correct^UPRNU(loc)
 .if depth'="" s depth=$$correct^UPRNU(depth)
 .if deploc'="" s deploc=$$correct^UPRNU(deploc)
ds10 .set ^UPRN(ukey,uprn,"D",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_org_d_dep_d_ptype
 c file
 q
 
IMPLPI ;Imports and indexes LPI file
 S ^IMPORT("LOAD")="LPI file"
 s file=abp_"/ID24_LPI_Records.csv"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 s del=","
 s d="~"
 
 close file
 
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 
 i $zv["IRIS" o file:"R"
 
 use file read rec
 
 for  d  quit:rec=""
 .use file read rec
 .q:rec=""
 .s rec=$$lc^UPRNL(rec)
 .s rec=$tr(rec,"""")
 .s change=$p(rec,del,2)
 .s uprn=$p(rec,del,4)
ds20 .s ukey="U"
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
L1 .S level=$p(rec,del,25)
 .s org=""
 .;i status=8 D  q
 .;.U 0 w rec r t
 .i status=1,end'="" d
 ..u 0 w rec r t
 .S nrec=saos_"~"_saosf_"~"_saoe_"~"_saoef_"~"_saot
 .s nrec=nrec_"~"_paos_"~"_paosf_"~"_paoe_"~"_paoef_"~"_paot
 .s nrec=nrec_"~"_str_"~"_status
 .S ^LASTREC=$get(uprn)_"|"_$get(key)_"|"_$get(nrec)
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
ds22 .set ^UPRN(ukey,uprn,"L",key,"O")=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post_d_level
 .f var="flat","build","bno","depth","street","deploc","loc","town","post","org","dep","ptype" d
 ..s @var=$$LC^LIB(@var)
yrep2 .F var="flat","build","depth","street","deploc","loc" d
 ..i @var="" q
 ..s @var=$$welsh(@var)
L .set newrec=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post
 .set ^UPRN(ukey,uprn,"L",key)=flat_d_build_d_bno_d_depth_d_street_d_deploc_d_loc_d_town_d_post
 .i level'="" S ^UPRN("L",uprn)=level
 close file
 Q
 
IMPCOUNT ;
 S ^IMPORT("LOAD")="Counties"
 s del=$C(9)
 ;K ^UPRN("COUNTY")
 s file=abp_"/Counties.txt"
 S ^IMPORT("FILE")=$$ESCAPE(file)
 
 close file
 
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 
 if $zv["IRIS" open file:"R"
 
 use file read rec
 
 for  d  q:rec=""
 .use file read rec
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
 
 close file
 Q
 ;
IMPSTR ;
 S ^IMPORT("LOAD")="Street descriptors"
 s del=","
 S file=abp_"/ID15_StreetDesc_Records.csv"
 S ^IMPORT("FILE")=$$ESCAPE(file)
 
 close file
 
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 
 if $zv["IRIS" o file:"R"
 
 use file read rec
 
 for  do  q:rec=""
 .u file r rec
 .q:rec=""
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s usrn=$p(rec,del,4)
 .s name=$p(rec,del,5)
 .s locality=$p(rec,del,6)
 .s town=$p(rec,del,7)
 .s admin=$p(rec,del,8)
 .S lang=$p(rec,del,9)
 .s newrec=name_"~"_locality_"~"_admin_"~"_town
 .i newrec'=$G(^UPRN("LPSTR",usrn_"-"_lang)) d
 ..S ^UPRN("LPSTR",usrn_"-"_lang)=name_"~"_locality_"~"_admin_"~"_town
 close file
 
 Q
 
welsh(string)      ;Welsh yr y problem
 s string=$$TR^LIB(string," yr ","yr")
 s string=$$TR^LIB(string,"-yr-","yr")
 s string=$$TR^LIB(string," y ","y")
 s string=$$TR^LIB(string,"-y-","y")
 i $e(string,1,2)="y " s string="y"_$e(string,3,100)
 i $e(string,1,2)="y-" s string="y"_$e(string,3,100)
 q string
 
IMPBLP ;
 S ^IMPORT("LOAD")="UPRN file"
 s file=abp_"/ID21_BLPU_Records.csv"
 s ^IMPORT("FILE")=$$ESCAPE(file)
 s recno=0
 s del=","
 
 close file
 
 if $zv'["IRIS" do
 .open file:(readonly:exception="do BADOPEN")
 .use file:exception="goto EOF"
 .quit
 
 i $zv["IRIS" o file:"R"
 
 use file read rec
 
 for  do  q:rec=""
 .use file r rec
 .Q:rec=""
 .;U 0 W !,rec
 .s recno=recno+1
 .s rec=$tr($$lc^UPRNL(rec),"""")
 .s post=$tr($p(rec,del,21)," ")
 .s uprn=$p(rec,del,4)
 .s status=$p(rec,del,5)
 .s change=$p(rec,del,2)
 .;i status=8 q
 .s bpstat=$p(rec,del,6)
 .s insdate=$p(rec,del,16)
 .s update=$p(rec,del,18)
 .s parent=$p(rec,del,8)
 .i change="d" Q
 .s coord1=$p(rec,del,9)_","_$P(rec,del,10)_","_$p(rec,del,11)_","_$p(rec,del,12)_","_$p(rec,del,13)
 .s local=$p(rec,del,14)
 .s adpost=$p(rec,del,20)
 .S newrec=$tr(adpost_"~"_post_"~"_status_"~"_bpstat_"~"_insdate_"~"_update_"~"_coord1_"~"_local,"""")
 .s ukey="U"
dsu6 .S ^UPRN(ukey,uprn)=$tr(adpost_"~"_post_"~"_status_"~"_bpstat_"~"_insdate_"~"_update_"~"_coord1_"~"_local,"""")
 .i parent'="" d
 ..i '$D(^UPRN("UPC",parent,uprn)) d
 ...S ^UPRN("UPC",parent,uprn)=""
 close file
 q
 
files ;
 s folder=""
 s folder=$G(^UPRNF("abpfolder"))
 w !,"ABP folder ("_folder_") :" r folder
 i folder="" s folder=$g(^UPRNF("abpfolder"))
 set att=$$8^ZOS(folder)
 if 'att write *7,"Error no folder" H 2 G files
 s ^UPRNF("abpfolder")=folder
 q
ADRFILES ;
 w !,"Address file ("_$G(^UPRNF("adrfile"))_") : " r adrfile
 i adrfile="" s adrfile=^UPRNF("adrfile")
 s ^UPRNF("adrfile")=adrfile
 s resdir=$p(adrfile,"\",1,$l(adrfile,"\")-1)_"\Results"
 
 s att=$$8^ZOS(resdir)
 s err=""
 i 'att do 6^ZOS(resdir) s err=$$8^ZOS(resdir)
 i 'err W !,*7,"Error creating results directory" h 2 G files
 
 s ^UPRNF("Results")=resdir
 q
 
EOF; 
 if '$zeof zmessage +$zstatus
 close file
 quit
