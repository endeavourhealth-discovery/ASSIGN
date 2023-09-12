UPRNTEST ;Command line for processing a batch of adresses [ 07/28/2023  11:17 AM ]
		n
	s vold=^UPRNF("oldversion")
	s vnew=^UPRNF("newversion")
	i '$d(^UPRNI("Prev",vold)) d  q
	. W !,"Old version matches not present. Merge from ^UPRNI(M) if required"
	S diff=$tr(vold,".","_")_"-"_$tr(vnew,".","_")_"-diff.txt"
	s file=^UPRNF("assurancepath")_"/"_"Diff-"_vold_vnew_".txt"
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
setarea d batch("D","",from,to,ui,country,vold,vnew,file)
	q
stat(same,nomatch,nownot,diff,nowmatch,adno)          ;
	n var
	f var="same","nomatch","nownot","diff","nowmatch" d
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
reenter ;
	d batch(1,"D","",^ADNO,10000000,0,"e")
	q
batch(mkey,qpost,from,to,ui,country,vold,vnew,file)   ;Processes a batch of addresses for a list of areas
	;mkey is the node for the address list
	;qpost is the , delimited list of addresses
	;
	n (mkey,qpost,from,to,ui,country,vold,vnew,file)
	;	
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
	. s (olduprn,oclass,oalg,oldmatch)=""
	. K oaddr,bestaddr,resaddr
	. s adrec=$tr(^UPRNI("D",adno),"~",",")
	. i $D(^TUPRN($J,"MATCHED")) D
	. . s bestuprn=$O(^TUPRN($J,"MATCHED",""))
	. . s bestuprn=$O(^TUPRN($J,"MATCHED",""))
	. . s bestalg=$$algnow(bestuprn)
	. . s bestclass=^UPRN("CLASS",bestuprn)
	. . d addrnow(bestuprn,.bestaddr)
	. . s bestmatch=$$recnow(bestuprn)
	. s olduprn=$O(^UPRNI("Prev",vold,adno,""))
	. i olduprn'="" d
	. . d addrthen(vold,adno,olduprn,.oaddr)
	. . s oclass=^UPRN("CLASS",olduprn)
	. . s oalg=$$algthen(vold,adno,olduprn)
	. . s oldmatch=$$recthen(vold,adno,olduprn)
	. s same=0,nomatch=0,nownot=0,diff=0,nowmatch=0
	. i olduprn="",bestuprn="" d
	. . s nomatch=1,same=1
	. i olduprn'="",bestuprn="" d
	. . s nownot=1
	. i olduprn'="",bestuprn'="",olduprn'=bestuprn d
	. . s diff=1
	. i olduprn="",bestuprn'="" d
	. . s nowmatch=1
	. i olduprn'="",bestuprn'="",olduprn=bestuprn d
	. . s same=1
	. S buguprn=""
	. d stat(same,nomatch,nownot,diff,nowmatch,adno)
	. I same q
	. u file w adno,d,adrec,d,same,d,nomatch,d,nownot,d,diff,d,nowmatch,d
	. w olduprn,d,oclass,d,oalg,d,oldmatch
	. f i=1:1:3 w d,$g(oaddr(i))
	. W d,bestuprn,d,bestclass,d,bestalg,d,bestmatch
	. f i=1:1:3 w d,$g(bestaddr(i))
	. w !
	c file
	q
recnow(newuprn)  ;
		n table,key,matchrec
	i newuprn="" q ""
	s table=$O(^TUPRN($J,"MATCHED",newuprn,""))
	s key=$O(^TUPRN($J,"MATCHED",newuprn,table,""))
	s matchrec=^(key)
	q matchrec
algnow(newuprn)  ;
	n alg,table,key
	s table=$O(^TUPRN($J,"MATCHED",newuprn,""))
	s key=$O(^TUPRN($J,"MATCHED",newuprn,table,""))
	s alg=^(key,"A")
	q alg
recthen(vold,adno,uprn)  ;
		n table,key,matchrec
	i uprn="" q ""
	s table=$O(^UPRNI("Prev",vold,adno,uprn,""))
	s key=$O(^UPRNI("Prev",vold,adno,uprn,table,""))
	s matchrec=^(key)
	q matchrec
algthen(vold,adno,uprn)  ;
	n alg,table,key
	s table=$O(^UPRNI("Prev",vold,adno,uprn,""))
	s key=$O(^UPRNI("Prev",vold,adno,uprn,table,""))
	s alg=^(key,"A")
	q alg
	;
addrnow(uprn,matches)    ;
	n i,adr,table,key
	k matches
	s i=0
	s table=""
	for  s table=$O(^TUPRN($J,"MATCHED",uprn,table)) q:table=""  d
	. s key=""
	. for  s key=$O(^TUPRN($j,"MATCHED",uprn,table,key)) q:key=""  d
	. . s adr=^UPRN("U",uprn,table,key)
	. . s adr=$tr(adr,"~",",")
	. . s i=i+1
	. . s matches(i)=adr
	Q
addrthen(vold,adno,uprn,matches)	;
	n i,adr,table,key
	k matches
	s i=0
	s table=""
	for  s table=$O(^UPRNI("Prev",vold,adno,uprn,table)) q:table=""  d
	. s key=""
	. for  s key=$O(^UPRNI("Prev",vold,adno,uprn,table,key)) q:key=""  d
	. . s adr=^UPRN("U",uprn,table,key)
	. . s adr=$tr(adr,"~",",")
	. . s i=i+1
	. . s matches(i)=adr
	q
IMPORT(file,sourceType) ;
	n (file,sourceType)
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
UNMATCHED(file) ;Exports unmatched data
			n adno
		O file:newversion	
		s adno=""
		for  s adno=$O(^UPRNI("M",adno))  q:adno=""  d
		. w adno_$c(9)_^UPRNI("D",adno),!
		c file
		q
	;		
	;