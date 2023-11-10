WGET ; ; 11/7/23 2:38pm
	;
	quit
TST ;
	f i=1:1 s rtn=$text(RTNS+i^WGET),rtn=$p(rtn," ; ",2,99) W !,rtn s ^R(rtn)="" r *y q:rtn="*EOR"
	quit
	;		
RTNS ;
	; ASSURE.m
	; ZLINK.m
	; VPRJSONE.m
	; VPRJSOND.m
	; VPRJSON.m
	; LIB.m
	; DAT.m
	; G.m
	; LIBDAT.m
	; STDDATE.m
	; VPRJREQ.m
	; VPRJRSP.m
	; VPRJRUT.m
	; XLFUTL.m
	; _WHOME.m
	; *EOR
	;	
STT ;
	new cmd,str,j,f,l,e,status
	s cmd="mkdir /tmp/dev ; cd /tmp/dev; rm /tmp/dev/*.*"
	zsystem cmd
	; PRE-REQUISITES
	set qf=0
	f i=1:1 s rtn=$text(RTNS+i^WGET),rtn=$p(rtn," ; ",2,99) q:rtn="*EOR"  do  q:qf
	. S status=$$PREREQ(rtn)
	. i status'=0 w !,"unable to get ",rtn s qf=1 quit
	. quit
	if qf quit
	;	
	s cmd="wget -q -r -np -nH --cut-dirs=1 --no-check-certificate -P /tmp/dev ""https://github.com/endeavourhealth-discovery/ASSIGN/tree/master/UPRN/yottadb"""
	zsystem cmd
	s f="/tmp/dev/ASSIGN/tree/master/UPRN/yottadb"
	close f
	o f:(readonly)
	set j=""
	f  u f r str q:$zeof  s j=j_str
	c f
	D DECODE^VPRJSON($name(j),$name(b),$name(err))
	s l="",q=0
	f  s l=$o(b("payload","tree","items",l)) q:l=""  do  q:q=1
	. s rtn=b("payload","tree","items",l,"name")
	. s z=$length(rtn,".")
	. set e=$p(rtn,".",z)
	. I e'="m" quit
	. set cmd="wget -q -P /tmp/dev ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
	. W !,rtn
	. zsystem cmd
	. if $zsystem'=0 S q=1
	. quit
	if q=1 W !,"Something went wrong!" quit
	s ro=$p($p($p($zro,"(",2)," "),")")
	W !,"The routines have been downloaded from github.com"
	W !,"Do you want to copy the routines to: "
YN W !,ro," (y/n)?"
	read yn#1
	set yn=$$LC^LIB(yn)
	if "\y\n\"'[("\"_yn_"\") G YN
	if yn="n" quit
	s cmd="cp /tmp/dev/UPRN*.m "_ro
	zsystem cmd
	i $zsystem'=0 w !,"Something went wrong copying the files" quit
	D ^ZLINK
	quit
	;
PREREQ(rtn) 
	new cmd,ro
	set cmd="wget -q -P /tmp/dev ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
	zsystem cmd
	if $zsystem'=0 q 1
	s ro=$p($p($p($zro,"(",2)," "),")")
	s cmd="cp /tmp/dev/"_rtn_" "_ro
	w !,cmd
	zsystem cmd
	if $zsystem'=0 ZLINK rtn
	quit $zsystem
	;
	;
	;