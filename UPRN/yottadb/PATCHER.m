PATCHER ; ; 5/9/24 11:29am
 quit
 
STT() ;
 new cmd,ro
 set cmd="mkdir /tmp/git/"
 zsystem cmd
 set ro=$p($p($p($zro,"(",2)," "),")")
 w !,"the system will copy the routines to ",ro
 W !,"copy? (y/n): "
YN read yn#1
 set yn=$$LC^LIB(yn)
 if "\y\n\"'[("\"_yn_"\") G YN
 quit yn

D ; SCOT INSTANCE (5.5.2)
 new yn,rtn,d
 set yn=$$STT()
 i yn="n" quit

 ; copy all code lists to /tmp/
 ;
 ; because UPRN1A has been changed
 ; this is a full import & index
 ;
 kill d
 s d("UPRN.m")=""
 s d("UPRN1A.m")=""
 s d("UPRNA.m")=""
 s d("UPRNA1.m")=""
 s d("UPRNACT.m")=""
 s d("UPRNB.m")=""
 s d("UPRNC.m")=""
 s d("UPRNDIFF.m")=""
 s d("UPRNIND.m")=""
 s d("UPRNMGR.m")=""
 s d("UPRNTEST.m")=""
 s d("UPRNU.m")=""
 D GO(.d)
 W !,"KILLING."
 k ^UPRN,^UPRNS,^UPRNX
 W !,"IMPORTING."
 D IMPORT^UPRN1A("/tmp/")
 quit
 
C ; RAN IN LIVE 9.5.2024
 ; ABP AUTO DOWNLOADS
 new yn,rtn,d
 set yn=$$STT()
 i yn="n" quit
 kill d
 set d("ABPAPI2.m")=""
 set d("ASSURE.m")=""
 set d("METRICS.m")=""
 set d("NEL.m")=""
 ; check if POURC is running in the background?
 set d("POURC.m")=""
 set d("RALF.m")=""
 set d("SCOTDPA.m")=""
 set d("VUE.m")=""
 do GO(.d)
 quit
 
DEV0355 ; deploy 5.5.0 to DEV03
 new yn,rtn,d
 set yn=$$STT()
 i yn="n" quit
 
 ; load a new version of /tmp/Residential_codes.txt
 s cmd="rm /tmp/Residential_codes.txt"
 zsystem cmd
 
 set cmd="wget -q -P /tmp/ ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/codelists/Residential_codes.txt"""
 zsystem cmd
 if $zsystem'=0 w !,"something went wrong downloading the Residential_codes.txt file" quit
 
 s abp="/tmp"
 D RESIDE^UPRN1A
 W !,"Successfully imported new Residential file."
 ;quit
 
 kill d
 s d("ASSURE.m")=""
 s d("GITDIFF.m")=""
 s d("METRICS.m")=""
 s d("POURC.m")=""
 s d("SCOTDPA.m")=""
 s d("UPRN.m")=""
 s d("UPRN1B.m")=""
 s d("UPRNA.m")=""
 s d("UPRNA1.m")=""
 s d("UPRNB.m")=""
 s d("UPRNC.m")=""
 s d("UPRNDIFF.m")=""
 s d("UPRNIND.m")=""
 s d("UPRNMGR.m")=""
 s d("UPRNTEST.m")=""
 s d("UPRNU.m")=""
 
 D GO(.d)
 w !,"restored routines"
 w !,"press a key to start a re-index"
 read *y
 
 job ^UPRNIND:(out="/dev/null")
 w !,"kicked off a re-index"
 
 quit
 
SCOT ;
 new yn,rtn,d
 set yn=$$STT()
 i yn="n" quit
 kill d
 s d("ABPAPI.m")=""
 s d("ABPAPI2.m")=""
 s d("ASSURE.m")=""
 s d("LIB.m")=""
 s d("POURC.m")=""
 s d("SCOTOUT.m")=""
 s d("UPRN.m")=""
 s d("UPRN1B.m")=""
 s d("UPRNA.m")=""
 s d("UPRNA1.m")=""
 s d("UPRNB.m")=""
 s d("UPRNC.m")=""
 s d("UPRNDIFF.m")=""
 s d("UPRNIND.m")=""
 s d("UPRNMGR.m")=""
 s d("UPRNTEST.m")=""
 s d("UPRNU.m")=""
 s d("WGET.m")=""
 s d("ZLINK.m")=""
 do GO(.d)
 quit
 
B ; RAN IN LIVE 1.5.2024
 quit
 
 new yn,rtn,d
 
 if '$data(^ICONFIG("COGNITO-CHK")) W !,"^ICONFIG(""COGNITO-CHK"") is not set" quit
 
 set yn=$$STT()
 i yn="n" quit
 kill d
 s d("CURL3.m")=""
 s d("UPRN.m")=""
 s d("UPRN1A.m")=""
 s d("UPRNA1.m")=""
 s d("UPRNC.m")=""
 s d("UPRNDIFF.m")=""
 s d("UPRNIND.m")=""
 s d("UPRNMGR.m")=""
 s d("UPRNUI.m")=""
 s d("VPRJRSP.m")=""
 
 do GO(.d)
 
 quit
 
A ; RAN IN LIVE 1.5.2024
 quit
 
 new yn,rtn,d
 set yn=$$STT()
 i yn="n" quit
 kill d
 ;set d("ABPAPI.crap")=""
 set d("ABPAPI2.m")=""
 set d("GITDIFF.m")=""
 set d("METRICS.m")=""
 set d("POURC.m")=""
 set d("SCOTDPA.m")=""
 set d("SCOTOUT.m")=""
 set d("UPRN1B.m")=""
 set d("WGET.m")=""
 set d("ZLINK.m")=""
 
 do GO(.d)
 
 quit
 
GO(d) new rtn,qf,cmd
 
 set rtn="",qf=0
 f  s rtn=$o(d(rtn)) q:rtn=""  do  q:qf
 .w !,"downloading: ",rtn
 .S qf=$$DOWN(rtn)
 .quit
 if qf'=0 quit
 
 ; copy to routine directory & compile.
 set ro=$p($p($p($zro,"(",2)," "),")")
 set rtn=""
 f  s rtn=$o(d(rtn)) q:rtn=""  do  q:qf
 .;set cmd="cp /tmp/git/"_rtn_" "_ro_"/"_rtn
 .w !,"copying ",rtn," rtn directory"
 .S qf=$$COPY(rtn)
 .ZLINK $piece(rtn,".")
 .quit
 quit
 
COPY(rtn) ;
 new cmd
 set cmd="cp /tmp/git/"_rtn_" "_ro_"/"_rtn
 zsystem cmd
 if $zsystem'=0 w !,"unable to copy ",rtn q 1
 quit $zsystem
 
DOWN(rtn) ;
 new cmd
 set cmd="rm /tmp/git/"_rtn
 zsystem cmd
 set cmd="wget -q -P /tmp/git ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
 zsystem cmd
 if $zsystem'=0 w !,"unable to download ",rtn," from github.com" quit 1
 quit $zsystem
