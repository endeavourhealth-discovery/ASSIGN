PATCHER ; ; 5/1/24 10:50am
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
 
B ; RAN IN LIVE 1.5.2024
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
