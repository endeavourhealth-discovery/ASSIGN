UPRNTEST(vold,vnew,from,count,diffonly,NODE) ;Command line for processing a batch of adresses [ 07/28/2023  11:17 AM ]
	;vold= old version,vnew= current version, from = from adno, to= to adno 
	;diffonly = different matches only in result file
	K ^UPRNI("stats")
	K ^UPRNI("M",vnew)
	K ^TPARAMS($J)
	K ^TUPRN($J)
	S from=$g(from)
	s count=$g(count)
	i count="" s to=1000000000
	S NODE=$G(NODE,"D")
	s ^start=$h
	d match(vold,vnew,from,count)
	d out(vold,vnew,from,count,$g(diffonly),NODE)
	s ^TIME=$$DIFDISP^UPRNL1(^start,$h)
	U 0 w !,^TIME
	;	
	;		
stats ;End of run stats
	U 0 W !!
	N total,matched
	S total=^UPRNI("stats","total")
	s stat=""
	for  s stat=$O(^UPRNI("stats",stat)) q:stat=""  d
	. w !,stat,"= ",^(stat)," ",$j(^(stat)/total*100,1,2)_"%"
	S total=^UPRNI("stats","total")
	s matched=^UPRNI("stats","matched")
	S invalid=$G(^UPRNI("stats","invalid"))
	w !,$j(matched/(total-invalid)*100,1,2)_" %"
	;	
	q
	;
out(vold,vnew,from,matchcount,diffonly,NODE)   ;Processes a batch of addresses for a list of areas
	N file,d,i,adno,bestuprn,bestalg,bestmatch,bestclass,olduprn,same,nownot,nowmatch,nomatch,adrec
	n diff,bestaddr,oldaddr,oldalg,oldmatch,oldclass,total,matched,oldmatched,export,txt,score,uarn,row
	n unfile
	;
	s d=$c(9)
	s unfile=^UPRNF("assurancepath")_"/"_"unmatched-"_from_"-"_$TR(vnew,".","_")_".txt"
	o unfile:newversion
	d
	. i diffonly d
	. . s file=^UPRNF("assurancepath")_"/"_"Diff"_$TR(vold,".","_")_"-"_$TR(vnew,".","_")_".txt"
	. e  d
	. . s file=^UPRNF("assurancepath")_"/"_"Results"_$TR(vold,".","_")_"-"_$TR(vnew,".","_")_".txt"
	. o file:(newversion:stream:nowrap:chset="M")
	. u file
	. w "Number or UARN",d
	. w "Candidate",d
	. w vnew_" uprn",d
	. I vold'="" d
	. . w vold_" uprn",d
	. w vnew_" class",d
	. w vnew_" algorithm",d
	. w vnew_" quality",d
	. f i=1:1:3 w vnew_" abp addrress "_i,d
	. I vold'="" d
	. . w vold_" class",d
	. . w vold_" algorithm",d
	. . w vold_" quality",d
	. . f i=1:1:3 w vold_" abp address "_i,d
	. . w "Same match",d
	. . w "Unmatched both",d
	. W vnew_" unmatched",d
	. w "Different match",d
	. w vnew_" match"
	. i vold="FLAP" w d,"score"
	. w $c(10)
	. u 0 w !,"Exporting .."
	;
	K ^UPRNI("stats")
	;Initiate the counts
	;	
	;
	s total=0,matched=0,export=0,txt=""
	s adno=$g(from)
	;	
	s row=0
	for  set adno=$O(^UPRNI(NODE,adno)) q:adno=""  q:(row>matchcount)  d
	. s row=row+1
	. I '(row#100) I txt'="" d
	. . U 0 W !,row
	. . u file w txt s txt=""
	. S uarn=$g(^UPRNI("UARN",adno))
	. s adrec=$tr(^UPRNI("D",adno),"~",",")
	. s (bestuprn,bestclass,bestalg,bestmatch)=""
	. s (olduprn,oldclass,oldalg,oldmatch,oldmatched)=""
	. k bestaddr,oldaddr
	. s matched=0
	. s bestuprn=$G(^UPRNI("M",vnew,adno))
	. i bestuprn'="" s matched=1
	. i vold'="" s olduprn=$G(^UPRNI("M",vold,adno))
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
	. i bestuprn'="" d alg(vnew,adno,bestuprn,.bestalg,.bestmatch,.bestclass)
	. i bestalg'="" s ^MATCHES(bestalg)=$g(^MATCHES(bestalg))+1,^MATCHES1(bestalg,adno)=""
	. d stat(1,matched,same,nomatch,nownot,diff,nowmatch)
	. i bestuprn="" d
	. . u unfile w adno,$c(9),^UPRNI("D",adno),!      
	. S score=$G(^UPRNI("SCORE",vold,adno))
	. i bestuprn'="" d addr(bestuprn,.bestaddr)
	. i olduprn'="" d addr(olduprn,.oldaddr)
	. i olduprn'="" d alg(vold,adno,olduprn,.oldalg,.oldmatch,.oldclass)
	. i $g(diffonly),bestuprn=olduprn q
	. i uarn="" d
	. . s txt=txt_adno_d_$tr(adrec,"""")_d
	. e  d
	. . s txt=txt_uarn_d_$tr(adrec,"")_d
	. s txt=txt_bestuprn_d_$s(vold="":"",1:olduprn_d)_bestclass_d_bestalg_d_bestmatch_d
	. f i=1:1:3 d
	. . s txt=txt_$g(bestaddr(i))_d
	. i vold'="" d
	. . s txt=txt_oldclass_d_oldalg_d_oldmatch_d
	. . f i=1:1:3 d
	. . . s txt=txt_$g(oldaddr(i))_d
	. . s txt=txt_same_d_nomatch_d
	. s txt=txt_nownot_d_diff_d_nowmatch_d
	. i vold="FLAP"	 s txt=txt_score
	. s txt=txt_$c(10)
	. s export=export+1
	i txt'="" u file w $e(txt,1,$l(txt)-1)
	c file
	c unfile
	d stats
	q
stat(total,matched,same,nomatch,nownot,diff,nowmatch)          ;
	n var
	f var="total","matched","same","nomatch","nownot","diff","nowmatch" d
	. i $g(@var) d
	. . s ^UPRNI("stats",var)=$G(^UPRNI("stats",var))+1
	i $d(^TUPRN($J,"OUTOFAREA")) d
	. s ^UPRNI("stats","out of area")=$g(^UPRNI("stats","out of area"))+1
	Q
match(vold,vnew,from,matchcount)	;Runs the batch match
	K ^UPRNI("stats")
	n xh,start,d,adno,begin,total,end,uprn,matched,row,olduprn,diff
	n batch,batchmatch,batchstart,nownot,nomatch,same,nowmatch
	s xh=$p($H,",",2)
	set adno=from
	set batchstart=from
	set total=0
	set begin=$p($h,",",2)
	s d=$c(9)
	s row=0
	s matched=0,batch=1,batchmatch=0
	for  set adno=$O(^UPRNI(NODE,adno)) q:adno=""  q:(row>matchcount)  d
	. s row=row+1
	. S ^ADNO=adno
	. S diff="",olduprn="",uprn="",nownot="",nomatch="",same="",matched="",nowmatch=""
	. s start=$p($h,",",2)
	. ;w !,adno
	. d tomatch^UPRN(adno,vnew) ;Match 1 address
	. s total=total+1
	. i '(total#10000) d
	. . S ^UPRNI("batch",batch)=(batchmatch/10000*100)_"~"_batchstart
	. . s batch=batch+1
	. . s batchmatch=0
	. . s batchstart=adno+1
	. S matched=0
	. s end=$p($h,",",2)
	. ;i (end-start>0) u 0 w !,adno," ",end-start," ",^UPRNI("D",adno)
	. i $D(^TUPRN($J,"MATCHED")) D
	. . s matched=1
	. . s batchmatch=batchmatch+1
	. . s uprn=$o(^TUPRN($J,"MATCHED",""))
	. . s matched=1
	. i vold'="" d
	. . s olduprn=$G(^UPRNI("M",vold,adno))
	. i olduprn'=uprn,uprn'="",olduprn'="" s diff=1
	. i uprn'="" s matched=1
	. i uprn="",olduprn'="" s nownot=1
	. i uprn="" s nomatch=1
	. i uprn'="",olduprn="" s nowmatch=1
	. i uprn'="",uprn=olduprn s same=1
	. i uprn'="" d
	. . S ^UPRNI("M",vnew,adno)=uprn
	. . m ^UPRNI("M",vnew,adno)=^TUPRN($J,"MATCHED",uprn)
	. d stat(1,matched,same,nomatch,nownot,diff,nowmatch)
	. i '(total#200) d
	. . d stats
	. i $D(^TUPRN($J,"INVALID")) d  q
	. . S ^UPRNI("stats","invalid")=$G(^UPRNI("stats","invalid"))+1
	;d stats
	;	
	q
	;
alg(version,adno,uprn,alg,matchrec,class)  ;
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