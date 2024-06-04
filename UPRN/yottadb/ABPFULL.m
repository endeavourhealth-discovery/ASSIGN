ABPFULL ; ; 5/31/24 12:39pm
 ;
 quit
 
PATCH() ; patch all the UPRN routines
 s cmd="curl -H ""Accept: application/vnd.github.v3+json"" -o /tmp/git.json https://api.github.com/repos/endeavourhealth-discovery/ASSIGN/contents/UPRN/yottadb"
 zsystem cmd
 s f="/tmp/git.json"
 c f
 o f:(readonly)
 set j=""
 f  u f r str q:$zeof  s j=j_str
 c f
 D DECODE^VPRJSON($name(j),$name(b),$name(err))
 s l="",q=0
 K ^TRTN($J)
 f  s l=$o(b(l)) q:l=""  do  q:q=1
 .s rtn=b(l,"name")
 .s z=$length(rtn,".")
 .set e=$p(rtn,".",z)
 .I e'="m" quit
 .if $extract(rtn,1,4)'="UPRN" quit
 .set cmd="wget -q -P /tmp ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
 .w !,rtn
 .zsystem cmd
 .i $zsystem'=0 s q=1
 .S ^TRTN($J,rtn)=""
 .quit
 if q=0 do
 .s ro=$p($p($p($zro,"(",2)," "),")")
 .set cmd="cp /tmp/UPRN*.m "_ro
 .zsystem cmd
 .i $zsystem'=0 w !,"Something went wrong copying the UPRN routines" set q=1 quit
 .set rtn=""
 .f  s rtn=$o(^TRTN($j,rtn)) q:rtn=""  do
 ..ZLINK rtn
 ..quit
 .quit
 quit q
 
INTRUPT ; get a partition dump to find out how far the code is progressing.
 new job
 set job=$get(^KRUNNING("ABPFULL"))
 if job="" w !,"abpfull not running" quit
 s cmd="mupip intrpt "_job
 zsystem cmd
 quit
 
ZQZ ;
 set ^ZQZ(3)="FULL GB ABP import"
 set zh=+$h+1
 set z=$$TH^STDDATE("01:00"),^ZQZ(3,zh)=z,^ZQZ(3,zh,"RTN")="GB^ABPFULL"
 kill ^ZQZ1(3,zh)
 quit
 
GB ;
 do STT^ABPFULL("/tmp/","/opt/all/6471504/pawk.7z")
 quit
 
STT(folder,zip) 
 set $ZINT="I $$JOBEXAM^ABPFULL($ZPOS)"
 set ^KRUNNING("ABPFULL")=$JOB
 
 write !,"getting code lists from github.com"
 set cmd="rm /tmp/Counties.txt; rm /tmp/Residential_codes.txt; rm /tmp/Saints.txt"
 zsystem cmd
 ;if $zsystem'=0 w !,"unable to delete code lists" quit
 
 set cmd="wget -q -P /tmp ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/codelists/Counties.txt"""
 zsystem cmd
 if $zsystem'=0 w !,"unable to download counties" quit
 
 set cmd="wget -q -P /tmp ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/codelists/Residential_codes.txt"""
 zsystem cmd
 if $zsystem'=0 w !,"unable to download residential codes" quit
 
 set cmd="wget -q -P /tmp ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/codelists/Saints.txt"""
 zsystem cmd
 if $zsystem'=0 w !,"unable to download saints" quit
 
 s abp=folder
 i $e(abp,$l(abp))="/" s abp=$e(abp,1,$l(abp)-1)
 
 write !,"checking zip contents"
 ; /opt/all/6471504/pawk.7z <- GB.
 set cmd="7z l -ba "_zip_" > /tmp/pawk.txt"
 zsystem cmd
 ; check that the file contains all the files?
 s f="/tmp/pawk.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .set l=$l(str," ")
 .s csv=$p(str," ",l)
 .set csv(csv)=""
 .quit
 close f
 
 if '$data(csv("ID15_StreetDesc_Records.csv")) w !,"missing street_desc" quit
 if '$d(csv("ID21_BLPU_Records.csv")) w !,"missing blpu" quit
 if '$d(csv("ID24_LPI_Records.csv")) w !,"missing lpi" quit
 if '$d(csv("ID28_DPA_Records.csv")) w !,"missing dpa" quit
 if '$d(csv("ID32_Class_Records.csv")) w !,"missing class" quit
 
 w !,"patching the routines"
 s z=$$PATCH()
 i z'=0 w !,"Something went wrong whilst patching the UPRN routines" quit
 
 write !,"killing main UPRN globals"
 K ^UPRN,^UPRNS,^UPRNS
 
 K ^IMPORT
 S ^IMPORT("START")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 
 w !,"importing saint.txt"
 D IMPSAINT^UPRN1A
 w !,"importing residential.txt"
 D RESIDE^UPRN1A
 w !,"importing counties.txt"
 D IMPCOUNT^UPRN1A
 
 w !,"class"
 set zs=$$UNZIP("ID32_Class_Records.csv",zip)
 if zs'=0 w !,"unable to unzip ID32_Class_Records.csv" quit
 do IMPCLASS^UPRN1A
 set zs=$$DELETE("ID32_Class_Records.csv")
 if zs'=0 w !,"unable to delete ID32_Class_Records.csv" quit
 
 w !,"street desc"
 set zs=$$UNZIP("ID15_StreetDesc_Records.csv",zip)
 if zs'=0 w !,"unable to unzip ID15_StreetDesc_Records.csv" quit
 do IMPSTR^UPRN1A
 set zs=$$DELETE("ID15_StreetDesc_Records.csv")
 if zs'=0 w !,"unable to delete ID15_StreetDesc_Records.csv" quit
 
 w !,"blpu"
 set zs=$$UNZIP("ID21_BLPU_Records.csv",zip)
 if zs'=0 w !,"unable to unzip ID21_BLPU_Records.csv" quit
 do IMPBLP^UPRN1A
 set zs=$$DELETE("ID21_BLPU_Records.csv")
 if zs'=0 w !,"unable to delete ID21_BLPU_Records.csv" quit
 
 w !,"dpa"
 set zs=$$UNZIP("ID28_DPA_Records.csv",zip)
 if zs'=0 w !,"unable to unzip ID28_DPA_Records.csv" quit
 do IMPDPA^UPRN1A
 set zs=$$DELETE("ID28_DPA_Records.csv")
 if zs'=0 w !,"unable to delete ID28_DPA_Records.csv" quit
 
 w !,"lpi"
 set zs=$$UNZIP("ID24_LPI_Records.csv",zip)
 if zs'=0 w !,"unable to unzip ID24_LPI_Records.csv" quit
 do IMPLPI^UPRN1A
 set zs=$$DELETE("ID24_LPI_Records.csv")
 if zs'=0 w !,"unable to delete ID24_LPI_Records.csv" quit
 
 ;do ^UPRNIND
 
 ; change only updates
 K ^DSYSTEM("COU")
 ; JUST DONE FULL
 set ^DSYSTEM("COU",6471504)=""
 ; PROCESS ALL THE CHANGE ONLY UPDATES
 ; UPRNIND WILL GET CALLED FROM PROCESS^ABPAPI2
 D PROCESS^ABPAPI2
 
 D AREAS^UPRN1A
 D SETSWAPS^UPRNU
 
 K ^IMPORT("LOAD")
 S ^IMPORT("END")=$$DH^UPRNL1($H)_"T"_$$TH^UPRNL1($P($H,",",2))
 
 set hostname=$get(^ICONFIG("HOSTNAME"))
 do SLACK^POURC("FULL GB import completed OK ("_hostname_")")
 quit
 
DELETE(file) ;
 s file="/tmp/"_file
 s cmd="rm "_file
 zsystem cmd
 quit $zsystem
 
UNZIP(file,zip) ;
 new cmd
 set cmd="7z e "_zip_" "_file_" -aoa -o/tmp/"
 zsystem cmd
 quit $zsystem
 
JOBEXAM(%ZPOS) 
 s idx=$o(^interupt(""),-1)+1
 S ^interupt(idx)=$get(%ZPOS)
 D LOG
 QUIT
 
LOG ;
 S %D=$H,%I="exam"
 S %TOP=$STACK(-1),%N=0
 L ^LOG:10
 I '$T QUIT
 S ID=$I(^LOG)
 F %LVL=0:1:%TOP S %N=%N+1,^LOG("log",ID,%D,$J,%I,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 S %X="^LOG(""log"",ID,%D,$J,%I,""error"",""symbols"","
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 L -^LOG
 QUIT
