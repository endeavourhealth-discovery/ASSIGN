UPRNTEST(vold,vnew,from,to) ;Command line for processing a batch of adresses [ 07/28/2023  11:17 AM ]
	;	
	K ^UPRNI("stats")
	K ^UPRNI("M",vnew)
	K ^TPARAMS($J)
	K ^TUPRN($J)
	S from=$g(from)
	s to=$g(to,1000000000)
	d match(vold,vnew,from,to)
	d out(vold,vnew,from,to)
	q
stat(total,matched,oldmatched,same,nomatch,nownot,diff,nowmatch)          ;
	n var
	f var="total","matched","oldmatched","same","nomatch","nownot","diff","nowmatch" d
	. i $g(@var) d
	. . s ^UPRNI("stats",var)=$G(^UPRNI("stats",var))+1
	q
	;		
stats ;End of run stats
	U 0 W !!
	N total,matched
	s stat=""
	for  s stat=$O(^UPRNI("stats",stat)) q:stat=""  d
	. w !,stat,"= ",^(stat)
	S total=^UPRNI("stats","total")
	s matched=^UPRNI("stats","matched")
	w !,$j(matched/total*100,1,2)_" %"
	;	
	q
	;
out(vold,vnew,from,to)   ;Processes a batch of addresses for a list of areas
	N diff,file,d,i,adno,bestuprn,bestalg,bestmatch,bestclass,olduprn,same,nownot,nowmatch,nomatch,adrec
	n bestaddr,oldaddr,oldalg,oldmatch,oldclass,total,matched,oldmatched,export
	S diff=$tr(vold,".","_")_"-"_$tr(vnew,".","_")_"-diff.txt"
	s file=^UPRNF("assurancepath")_"/"_"Diff-"_$TR(vold,".","_")_"-"_$TR(vnew,".","_")_".txt"
	O file:newversion
	;Set File delimiter
	set d="~"
	;	
	K ^UPRNI("stats")
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
	U file W d,vnew_" best algorithm",d,vnew_" best quality"
	f i=1:1:3 w d,vnew_" best abp addrress "_i
	w !
	;
	s total=0,matched=0,export=0
	s adno=$g(from)
	u 0 w !,"Exporting .."
	s to=$g(to,1000000000)
	for  set adno=$O(^UPRNI("D",adno)) q:adno=""  q:(adno>to)  d
	. s adrec=$tr(^UPRNI("D",adno),"~",",")
	. s (bestuprn,bestclass,bestalg,bestmatch)=""
	. s (olduprn,oldclass,oldalg,oldmatch,oldmatched)=""
	. k bestaddr,oldaddr
	. s matched=0
	. s bestuprn=$G(^UPRNI("M",vnew,adno))
	. i bestuprn'="" s matched=1
	. s olduprn=$G(^UPRNI("M",vold,adno))
	. i olduprn'="" s oldmatched=1
	. s same=0,nomatch=0,nownot=0,diff=0,nowmatch=0
	. i olduprn="",bestuprn="" d
	. . s nomatch=1
	. i olduprn'="",bestuprn="" d
	. . s nownot=1
	. i olduprn'="",bestuprn'="",olduprn'=bestuprn d
	. . s diff=1
	. i olduprn="",bestuprn'="" d
	. . s nowmatch=1
	. i olduprn'="",bestuprn'="",olduprn=bestuprn d
	. . s same=1
	. d stat(1,matched,oldmatched,same,nomatch,nownot,diff,nowmatch)
	. I same!(nomatch) q
	. i bestuprn'="" d alg(vnew,adno,bestuprn,.bestalg,.bestmatch,.bestclass)
	. i bestuprn'="" d addr(bestuprn,.bestaddr)
	. i olduprn'="" d addr(olduprn,.oldaddr)
	. i olduprn'="" d alg(vold,adno,olduprn,.oldalg,.oldmatch,.oldclass)
	. u file w adno,d,adrec,d,same,d,nomatch,d,nownot,d,diff,d,nowmatch,d
	. w olduprn,d,oldclass,d,oldalg,d,oldmatch
	. f i=1:1:3 w d,$g(oldaddr(i))
	. W d,bestuprn,d,bestclass,d,bestalg,d,bestmatch
	. f i=1:1:3 w d,$g(bestaddr(i))
	. w !
	. s export=export+1
	. i '(export#500) d
	. . u 0 w !,export," differences exported"
	c file
	d stats
	q
match(vold,vnew,from,to)	;Runs the batch match
	;	
	n xh,start,d,adno,begin,total,end,uprn,matched
	s xh=$p($H,",",2)
	set adno=from
	set total=0
	set begin=$p($h,",",2)
	s d=$c(9)
	s matched=0
	for  set adno=$O(^UPRNI("D",adno)) q:adno=""  q:adno>to  d
	. S ^ADNO=adno
	. ;u 0 w !,adno
	. s start=$p($h,",",2)
	. d tomatch^UPRN(adno,vnew) ;Match 1 address
	. s total=total+1
	. S matched=0
	. s end=$p($h,",",2)
	. i $D(^TUPRN($J,"MATCHED")) D
	. . s matched=1
	. . s uprn=$o(^TUPRN($J,"MATCHED",""))
	. . S ^UPRNI("M",vnew,adno)=uprn
	. . m ^UPRNI("M",vnew,adno)=^TUPRN($J,"MATCHED",uprn)
	. d stat(total,matched)
	. i '(total#200) d
	. . d stats
	. i $D(^TUPRN($J,"INVALID")) d  q
	. . S ^UPRNI("stats","invalid")=$G(^UPRNI("stats","invalid"))+1
	;	
	q
	;
alg(version,adno,uprn,matchrec,alg,class)  ;
	n table,key
	s alg="",matchrec="",class=""
	i uprn="" q
	s class=$G(^UPRN("CLASS",uprn))
	s table=$O(^UPRNI("M",version,adno,""))
	i table'="" d
	. s key=$O(^UPRNI("M",version,adno,table,""))
	. s matchrec=^UPRNI("M",version,adno,table,key)
	. s alg=^UPRNI("M",version,adno,table,key,"A")
	q
addr(uprn,matches)	;
	n i,adr,table,key
	k matches
	s i=0
	i uprn="" q
	s table=""
	for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d
	. s key=""
	. for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d
	. . s adr=^UPRN("U",uprn,table,key)
	. . s adr=$tr(adr,"~",",")
	. . s i=i+1
	. . s matches(i)=adr
	q
	;
	Q
UNMATCHED(file) ;Exports unmatched data
			n adno
		O file:newversion	
		s adno=""
		for  s adno=$O(^UPRNI("UM",adno))  q:adno=""  d
		. U file w adno_$c(9)_^UPRNI("D",adno),!
		c file
		q
	;		
	;