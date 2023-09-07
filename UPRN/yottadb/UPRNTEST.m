UPRNTEST ;Command line for processing a batch of adresses [ 07/28/2023  11:17 AM ]
	s vold=^UPRNF("oldversion")
	s vnew=^UPRNF("newversion")
	s debug=$G(^UPRNF("debugversion"))
	i debug="" s debug="DEB"
	I '$D(^UPRNI(debug)) d
	. M ^UPRNI(debug,"M")=^UPRNI("M")
	. M ^UPRNI(debug,"UM")=^UPRNI("UM")
	S diff=$tr(vold,".","_")_"-"_$tr(vnew,".","_")_"-diff.txt"
	s file=^UPRNF("assurancepath")_"/"_"Diff-"_vold_vnew_debug
	O file:newversion
	K ^UPRN("MX") ;[ 05/11/2023  12:26 PM ]
	K ^UPRN("UX")
	K ^UPRNI("UM")
	K ^UPRNI("stats")
	K ^UPRNI("M")
	k ^UPRNI("Prev",vnew)
	K ^TPARAMS($J)
	K ^TUPRN($J)
	S ^TPARAMS($J,"commercials")=$g(commerce)
	W !,"Start from " r from
	w !,"End at " r to
	w !
	i to="" s to=100000000000
	s ui=0,country="e"
setarea d batch("D","",from,to,ui,country,vold,vnew,debug)
	q
stat(same,nomatch,nownot,diff,nowmatch,bugfix,adno)          ;
	f var="same","nomatch","nownot","diff","nowmatch","bugfix" d
	. s ^UPRNI("stats",var)=$G(^UPRNI("stats",var))+@var
	. i var="bugfix",@var=1 s ^UPRNI("stats",var,"adno",adno)=""
	q
stat1(var)         ;
	s ^UPRNI("stats",var)=$G(^UPRNI("stats",var))+1
	q
	;	
	;
	;	
stats ;End of run stats
	U 0 W !!
	s stat=""
	for  s stat=$O(^UPRNI("stats",stat)) q:stat=""  d
	. w !,stat,"= ",^(stat)
	q
	;
	q
	;	
	;
reenter ;
	d batch(1,"D","",^ADNO,10000000,0,"e")
	q
batch(mkey,qpost,from,to,ui,country,vold,vnew,debug)   ;Processes a batch of addresses for a list of areas
	;mkey is the node for the address list
	;qpost is the , delimited list of addresses
	;
	n total
	s xh=$p($H,",",2)
	;lower case the post code filter
	set qpost=$$lc^UPRNL(qpost)
	;	
	;Initiate the spelling swap  and corrections
	;	
	d SETSWAPS^UPRNU
	;Loop through the table of addresses, 
	;	
	;Set File delimiter
	set d="~"
	;	
	;Initiate the counts
	s d=$c(9)
	u file w "Number",d
	w "Candidate",d
	w "Same match",d
	w "Unmatched both",d
	W vnew_" unmatched",d
	w "Different match",d
	w vnew_" match",d
	w vold_" uprn",d
	w vold_" class",d
	w vold_" algorithm",d
	w vold_" quality"
	f i=1:1:3 w d,vold_" abp address "_i
	w d,vnew_" best uprn",d
	w vnew_" best class"
	U file W d,vnew_" nest algorithm",d,vnew_" best quality"
	f i=1:1:3 w d,vnew_" best abp addrress "_i
	w d,"Different from "_debug
	w d,debug_" uprn"
	w d,debug_" class"
	w d,debug_" address"
	w !
	;	
	set adno=from
	set total=0
	set begin=$p($h,",",2)
	s d=$c(9)
	for  set adno=$O(^UPRNI(mkey,adno)) q:adno=""  q:adno>to  d
	. S ^ADNO=adno
	. ;u 0 w !,adno
	. s start=$p($h,",",2)
	. b
	. d tomatch^UPRN(adno,qpost,ui,country) ;Match 1 address
	. d stat1("total")
	. s total=total+1
	. s end=$p($h,",",2)
	. i '(total#200) d
	. . d stats
	. . U 0 w !,total," number=",$O(^UPRNI("D",adno),-1)," time=",(end-start)," seconds, total time=",((end-begin)\60)," minutes"
	. i $D(^TUPRN($J,"OUTOFAREA")) D  Q
	. . d stat1("out of area")
	. i $D(^TUPRN($J,"INVALID")) d  q
	. . d stat1("invalid address")
	. s d=$c(9)
	. s (bestuprn,bestclass,bestalg,bestmatch)=""
	. s (resuprn,resclass,resalg,resmatch)=""
	. s (olduprn,oclass,oalg,oldmatch)=""
	. K oaddr,bestaddr,resaddr
	. s resglob="^TUPRN"
	. s adrec=$tr(^UPRNI("D",adno),"~",",")
	. i $D(^TUPRN($J,"MATCHED")) D
	. . s bestuprn=$O(^TUPRN($J,"MATCHED",""))
	. . S bestglob="^TUPRN"
	. . ;s resuprn=$O(^TUPRN($J,"MATCHED",""))
	. ;e  d
	. . s bestuprn=$O(^TUPRN($J,"MATCHED",""))
	. . s bestglob="^TUPRN"
	. . s resuprn=bestuprn
	. S olduprn=$G(^UPRNI("Prev",vold,adno))
	. i bestuprn'="" d
	. . s bestalg=$$alg(bestglob,bestuprn)
	. . s bestclass=^UPRN("CLASS",bestuprn)
	. . d matches2(bestglob,bestuprn,.bestaddr)
	. . s bestmatch=$$matchrec(bestglob,bestuprn)
	. ;i resuprn'="" d
	. . s resalg=$$alg(resglob,resuprn)
	. . s resclass=^UPRN("CLASS",resuprn)
	. . d matches2(resglob,resuprn,.resaddr)
	. . s resmatch=$$matchrec(resglob,resuprn)
	. i olduprn'="" d
	. . d matches(olduprn,.oaddr)
	. . s oclass=^UPRN("CLASS",olduprn)
	. . S oalg=$G(^UPRNI("Prev",vold,adno,"alg"))
	. . s oldmatch=$tr(^UPRNI("Prev",vold,adno,"matchrec"),$c(13),"")
	. s same=0,nomatch=0,nownot=0,diff=0,nowmatch=0
	. i olduprn="",bestuprn="" d
	. . s nomatch=1
	. i olduprn'="",bestuprn="" d
	. . s nownot=1
	. i olduprn'="",bestuprn'="",olduprn'=bestuprn d
	. . s diff=1
	. i olduprn="",bestuprn'="" d
	. . s nowmatched=1
	. i olduprn'="",bestuprn'="",olduprn=bestuprn d
	. . s same=1
	. s difbug=""
	. S buguprn=""
	. k bugaddr
	. i $D(^UPRNI(debug,"M",adno)) D
	. . s buguprn=$O(^UPRNI(debug,"M",adno,""))
	. . d matches(olduprn,.oaddr)
	. . I bestuprn'=buguprn d
	. . . s difbug=1
	. . . d matches(buguprn,.bugaddr)
	. . e  s buguprn=""
	. e  I $D(^UPRNI(debug,"UM",adno)) d
	. . i bestuprn'="" s difbug=1
	. d stat(same,nomatch,nownot,diff,nowmatched,difbug,adno)
	. i 'difbug q
	. u file w adno,d,adrec,d,same,d,nomatch,d,nownot,d,diff,d,nowmatched,d
	. w olduprn,d,oclass,d,oalg,d,oldmatch
	. f i=1:1:3 w d,$g(oaddr(i))
	. W d,bestuprn,d,bestclass,d,bestalg,d,bestmatch
	. f i=1:1:3 w d,$g(bestaddr(i))
	. ;W d,resuprn,d,resclass,d,resalg,d,resmatch
	. ;f i=1:1:3 w d,$g(resaddr(i))
	. s debugc=""
	. i buguprn'="" s debugc=^UPRN("CLASS",buguprn)
	. w d,difbug,d,buguprn,d,debugc,d,$g(bugaddr(1))
	. w !
	c file
	q
matchrec(glob,newuprn)  ;
	i newuprn="" q ""
	s table=$O(@glob@($J,"MATCHED",newuprn,""))
	s key=$O(@glob@($J,"MATCHED",newuprn,table,""))
	s matchrec=^(key)
	;	
	q matchrec
alg(glob,newuprn)  ;
	n alg
	s table=$O(@glob@($J,"MATCHED",newuprn,""))
	s key=$O(@glob@($J,"MATCHED",newuprn,table,""))
	s alg=^(key,"A")
	i alg["match53" b
	;
	q alg
matches(uprn,matches)    ;
	k matches
	s i=0
	s table=""
	for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d
	. s key=""
	. for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d
	. . s adr=$tr(^(key),"~",",")
	. . s i=i+1
	. . s matches(i)=adr
	q
matches2(glob,uprn,matches)    ;
	k matches
	s i=0
	s table=""
	for  s table=$O(@glob@($J,"MATCHED",uprn,table)) q:table=""  d
	. s key=""
	. for  s key=$O(@glob@($j,"MATCHED",uprn,table,key)) q:key=""  d
	. . s adr=^UPRN("U",uprn,table,key)
	. . s adr=$tr(adr,"~",",")
	. . s i=i+1
	. . s matches(i)=adr
	q
IMPORT(file,sourceType) ;
	u 0 w !,"Importing "_file_"..."
	K ^UPRNI(sourceType)
	s del=$c(9)
	o file
	s adno=0
	u file r header
	for  u file r rec  q:$zeof  d
	. s adno=adno+1
	. S ^UPRNI(sourceType,adno)=rec
	c file
	Q
	Q