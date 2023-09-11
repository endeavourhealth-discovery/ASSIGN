WGET ; ; 9/11/23 10:45am
	;
	quit
	;	
STT ;
	new cmd,str,j,f,l,e
	s cmd="mkdir /tmp/dev ; cd /tmp/dev; rm /tmp/dev/*.*"
	zsystem cmd
	s cmd="wget -q -r -np -nH --cut-dirs=1 --no-check-certificate -P /tmp/dev ""https://github.com/endeavourhealth-discovery/ASSIGN/tree/master/UPRN/yottadb"""
	zsystem cmd
	s f="/tmp/ASSIGN/tree/master/UPRN/yottadb"
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
	s ro=$p($p($zro,"(",2)," ")
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