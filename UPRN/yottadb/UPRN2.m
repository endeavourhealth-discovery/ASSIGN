UPRN2 ;NEW PROGRAM [ 06/10/2019  2:35 PM ]
 ;D COLLECT
 ;D EXPORT
 d GETDIR
 i '$d(folder) d
 .w !,"England or Wales : " r country s country=$$lc^UPRNL(country)
 .s folder=$s(country="e":"shared",country="w":"Wales")
 ;D ALL
 s start=""
 K ^UPRNO
 W !,"Version ("_$O(^UPRN3(""),-1)_"): " r version i version="" d
 .s version=$O(^UPRN3(""),-1)
 s ver=$tr(version,".","-")
 W !,"Start from : " r start
 W !,"End : " r end i end="" s end=10000000
 W !,"Exporting matches"
 D ADDRESS
 w !,"Algorithms"
 d ALGOUT
 W !,"Various unmatched files"
 D UNMATCH("OutOfArea")
 
 D UNMATCH("UnmatchedMissingPost")
 D UNMATCH("Unmatched")
 W !,"Diff file"
 D DIFF
 w !,"Correction file"
CORR D CORRECT
 ;D EXAMPLE
 Q
DIFF ;
 new out51,out52
 
 s adno=$o(^UPRN("M",start))-1
 s d=$c(9)
 s old=$O(^UPRN3(version),-1)
 i old="" q
 
 set out51=resdir_"/UPRN_changes "_$tr(version,".","-")_".txt"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "ID"_d_"Discovery address"_d_"Version "_old_d_"Version "_version
 
 f adno=1:1:10000000 q:(adno>end)  d  
 .i '$D(^UPRN3(old,adno)),'$D(^UPRN3(version,adno)) q
 .s disco=$tr(^UPRN("D",adno),"~",",")
 .s ouprn=$G(^UPRN3(old,adno))
 .s nuprn=$G(^UPRN3(version,adno))
 .I ouprn=nuprn q
 .use out51 w !,adno_d_disco_d_ouprn_d_nuprn
 close out51
 
 set out51=resdir_"/UPRN_match_changes "_$tr(version,".","-")_".txt"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "ID"_d_"Discovery address"_d_"UPRN"_d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"_d_"Status"
 
 f adno=1:1:10000000 q:(adno>end)  d  
 .i '$D(^UPRN3(old,adno)),'$D(^UPRN3(version,adno)) q
 .s ouprn=$G(^UPRN3(old,adno))
 .s nuprn=$G(^UPRN3(version,adno))
 .I ouprn=nuprn q
 .i $D(^UPRN("M",adno,nuprn,"L")) D OUT(adno,nuprn,"L") Q
 .i $D(^UPRN("M",adno,nuprn,"D")) D OUT(adno,nuprn,"D") Q
 close out51
 
 set out51=resdir_"/UPRN_unmatch_changes "_$tr(version,".","-")_".txt"
 open out51:(newversion:stream:nowrap:chset="M") 
 use out51 write "id"_d_"Address"
 
 f adno=1:1:10000000 q:(adno>end)  d  
 .i $d(^UPRN3(version,adno)) q
 .i '$D(^UPRN3(old,adno)) q
 .i $D(^UPRN("Stats","UnmatchedMissingPost",adno)) s skip=1 q
 .i $D(^UPRN("Stats","OutOfArea",adno)) s skip=1 q
 .s adrec=$tr(^UPRN("D",adno),"~",",")
 .w !,adno_d_adrec
 .quit
 close out51
 q
 
RETURN ;
 new out51,out52
 s d=$c(9)
 
 set out51=resdir_"/UPRN_Return.txt"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "ID"_d_"Org post"_d_"UPRN"_d_"Qualifier"_d_"Algorithm"_d_"Match"_d_"No address"_d_"Invalid address"_d_"Missing post code"_d_"Invalid post code"
 
 s adno=""
 for  s adno=$O(^UPRN("D",adno)) q:adno=""  d
 .S pat=$p(^UPRN("D",adno,"P"),"~",2)
 .s orgpost=$TR($P(^UPRN("D",adno,"P"),"~",1),"""")
 .s (table,key,matchrec,alg,qual,abadd)=""
 .s uprn=$O(^UPRN("M",adno,""))
 .i uprn'="" d
 ..s table=$O(^UPRN("M",adno,uprn,""))
 ..s key=$O(^UPRN("M",adno,uprn,table,""))
 ..s matchrec=^UPRN("M",adno,uprn,table,key)
 ..S alg=^UPRN("M",adno,uprn,table,key,"A")
 .S qual=^UPRN("Q",adno)
 .s missing=$p(qual,"~")
 .s invalid=$p(qual,"~",2)
 .s nopost=$p(qual,"~",3)
 .s invpost=$p(qual,"~",4)
 .k address
 .i uprn'="" d
 ..i table="L" D
 ...D ADLPI^UPRNU(uprn,key,.address)
 ..i table="D" D
 ...D ADDPA^UPRNU(uprn,key,.address)
 ..s abadd=address("flat")_" "_address("building")
 ..s abadd=$s(abadd'=" ":abadd_", ",1:"")
 ..s abadd=abadd_address("number")_" "_address("depth")_" "_address("street")_", "
 ..s abadd=abadd_address("deploc")_" "_address("locality")_" "_address("town")_", "
 ..s abadd=abadd_address("postcode")
 ..i $G(address("org"))'="" s abadd=abadd_", "_$g(address("org"))
 ..for  q:(abadd'["  ")  s abadd=$$tr^UPRNL(abadd,"  "," ")
 ..s abadd=$$lt^UPRNL(abadd)
 .s out=pat_d_orgpost_d_uprn_d_$$qual(matchrec)_d_abadd
 .s out=out_d_alg_d_matchrec_d_missing_d_invalid_d_nopost_d_invpost
 .use out51 w !,out
 close out51
 q
 
IMP ;
 new out51,out52
 
 s d=$c(9)
 
 set out51="/MSM/"_folder_"/Ranked.txt"
 close out51
 open out51:(readonly:exception="do BADOPEN")
 use out51:exception="goto EOF"
 
 for  use file read rec q:rec=""  d
 .S rank=$p(rec,d,1)
 .s alg=$p(rec,d,2)
 .s desc=$tr($p(rec,d,3),"""","")
 .s num=0
 .f i=1:80 q:$e(desc,i)=""  d
 ..s num=num+1
 ..s ^UPRND("ALG",alg,"desc",num)=$e(desc,i,i+79)
 .s ^UPRND("ALG",alg,"Rank")=rank
 
 close out51
 q
 
EXAMPLE ;  
 new out51,out52
 
 s d=$c(9)
 
 set out51="/MSM/"_folder_"/Examples.TXT"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "Rank"_d_"Algorithm"_d_"Count"_d_"Description"_d_"Discovery"_d_"ABP"_d_"Match pattern"
 
 s rank=0
 f i=1:1:5000 d
 .s alg=i_"-"
 .for  s alg=$O(^UPRNL("ALG",alg)) q:alg=""  q:($p(alg,"-")'=i)  d
 ..s rank=rank+1
 ..S count=$G(^UPRNL("ALG",alg,"Count")) q:count=""
 ..use out51 W !,rank_d_alg_d_count
 ..s desc=""
 ..f q=1:1 Q:('$d(^UPRND("ALG",alg,"desc",q)))  d
 ...s desc=desc_^(q)
 ..use out51 W d_desc
 ..W d_$tr(^UPRNL("ALG",alg,"from"),"~",",")
 ..W d_^UPRNL("ALG",alg,"to")
 ..w d_^UPRNL("ALG",alg,"matchrec")
 close out51
 q
 
CORRECT ;
 s d=$c(9)
 
 set out51="/MSM/"_folder_"/Corrections.TXT"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "Type"_d_"Word"_d_"Correction",!
 
 s correct=""
 for  s correct=$o(^UPRNS(correct)) q:correct=""  d
 .s word=""
 .for  s word=$O(^UPRNS(correct,word)) q:word=""  d
 ..s to=$g(^(word))
 ..for  s to=$O(^UPRNS(correct,word,to)) q:to=""  d
 ...s t=^(to)
 ...use out51 w correct_d_word_d_to,!
 ..use out51 w correct_d_word_d_to,!
 close out51
 q
 
INALG ;
 new out51,out52
 
 s d=$c(9)
 
 set out51="/MSM/"_folder_"/ALGS.TXT"
 close out51
 open out51:(readonly:exception="do BADOPEN")
 use out51:exception="goto EOF"
 
 for  use out51 r rec q:rec=""  d
 .s rank=$p(rec,d,1)
 .s alg=$p(rec,d,2)
 .i rank=1 s rank=0
 .S ^UPRNR("Rank",rank,alg)=""
 .s ^UPRNR("Alg",alg)=rank
 close out51
 q
 
ALGOUT ;
 new out51
 
 set out51="/msm/"_folder_"/Algorithms.txt"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "Algorithm"_d_"Count"_d_"Description"
 
 s d=$c(9)
 s rank=0
 f i=1:1:5000 d
 .s alg=$O(^UPRNL("ALG",i_"-"))
 .i $p(alg,"-")'=i q
 .s count=^UPRNL("ALG",alg)
 .s desc=""
 .f q=1:80 q:'$d(^UPRNL("ALG",alg,"Desc",q))  s desc=desc_^(q)
 .use out51 w !,rank_d_alg_d_count_d_desc
 .quit
 close out51
 q
 
ALL ;
 K ^UPRNL("POST")
 s adno=""
 for  s adno=$O(^UPRN("D",adno)) q:adno=""  d
 .s rec=^(adno)
 .s post=$p(rec,"~",$l(rec,"~"))
 .q:post=""
 .f i=$l(post)-2:-1:0 q:(qpost[("/"_$e(post,1,i)_"/"))
 .I i=0 q
 .s area=$e(post,1,i)
 .I $D(^UPRN("M",adno)) d
 ..s ^UPRNL("POST",area,"M")=$G(^UPRNL("POST",area,"M"))+1
 .I $D(^UPRN("UM",adno)) d
 ..s ^UPRNL("POST",area,"UM")=$G(^UPRNL("POST",area,"UM"))+1
 Q
 
UNMATCH(stat)
 new out51,out52
 
 s d=$c(9)
 n skip
 
 set out51=resdir_"/UPRN_"_stat_" "_ver_".txt"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "id"_d_"Address"
 
 s adno=start
 for  s adno=$O(^UPRN("Stats",stat,adno)) q:adno=""  d  q:(adno>end)
 .s skip=0
 .i stat="Unmatched" d  q:skip
U ..i $D(^UPRN("Stats","UnmatchedMissingPost",adno)) s skip=1 q
U1 ..i $D(^UPRN("Stats","OutOfArea",adno)) s skip=1 q
 .s adrec=$tr(^UPRN("D",adno),"~",",")
 .w !,adno_d_adrec
 close out51
 q
 
ADDRESS          ;
 new out51,out52
 
 s d=$c(9)
 
 set out51=resdir_"/UPRN_Matched "_ver_".txt"
 open out51:(newversion:stream:nowrap:chset="M")
 
 set out52=resdir_"/UPRN_Matched "_ver_"-tocheck.txt"
 open out52:(newversion:stream:nowrap:chset="M")
 
 use out51 w "ID"_d_"Discovery address"_d_"UPRN"_d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"_d_"Status"
 
 use out51 w d_"Missing"_d_"Invalid"_d_"No post code"_d_"invalid post code"
 
 use out52 w "ID"_d_"Discovery address"_d_"APB address"_d_"Algorithm"_d_"Qualifier"_d_"Match"_d_"Table"_d_"Key"_d_"Status"
 
 s d=$c(9)
 s adno=$o(^UPRN("M",start))-1
 s row=0
 for  s adno=$O(^UPRN("M",adno)) q:adno=""  d  q:(adno>end)
 .s uprn=$O(^UPRN("M",adno,""))
 .S ^UPRN3(version,adno)=uprn
 .i $D(^UPRN("M",adno,uprn,"L")) D OUT(adno,uprn,"L") Q
 .i $D(^UPRN("M",adno,uprn,"D")) D OUT(adno,uprn,"D") Q
 .Q
 close out51,out52
 Q
 
 ;
 
OUT(adno,uprn,table) 
 s disco=^UPRN("D",adno)
 s key=""
 for  s key=$O(^UPRN("M",adno,uprn,table,key)) q:key=""  d
 .s matchrec=^(key)
 .S alg=^UPRN("M",adno,uprn,table,key,"A")
 .S qual=^UPRN("Q",adno)
 .s missing=$p(qual,"~")
 .s invalid=$p(qual,"~",2)
 .s nopost=$p(qual,"~",3)
 .s invpost=$p(qual,"~",4)
 .k address
 .s ^UPRNL("ALG",alg)=$g(^UPRN("ALG",alg))+1
 .s status=$P(^UPRN("U",uprn),"~",3)
 .i table="L" s status=$P(^UPRN("LPI",uprn,key),"~",12)
 .D GETADR^UPRNU(uprn,table,key,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 .s abp=org_" "_flat_" "_build_","_bno_" "_depth_" "_street_","_deploc_" "_loc_","_town_","_post
 .S abp=$$tr^UPRNL($$tr^UPRNL(abp,"  "," "),",,",",")
 .;s out=adno_d_$tr(disco,"~",",")_d_abp
 .s out=adno_d_$tr(disco,"~",",")
 .s out=out_d_uprn_d_alg_d_$$qual(matchrec)_d_matchrec_d_table_d_key_d_status
 .s out=out_d_missing_d_invalid_d_nopost_d_invpost
 .use out51 w !,out
 .if $g(out52) use out52 W !,adno_d_$tr(disco,"~",",")_d_abp_d_alg_d_matchrec_d_uprn_d_table_d_key
 q
qual(matchrec)     ;
 N (matchrec)
 i matchrec="" q ""
 i matchrec["c" q "Child"
 i matchrec["a" q "Parent"
 i matchrec["s" q "Sibling"
 s qual="Best "_$s('$D(^TPARAMS($J,"commercials")):"(residential)",1:"(+commercial)")_" match"
 Q qual
 q
EXPORT ;
 set out51="/MSM/"_folder_"/UPRN_Summary.txt"
 open out51:(newversion:stream:nowrap:chset="M")
 
 use out51 w "Variable,Number of entries"
 
 w !,"Total"_","_^UPRN("STATS","TOTAL")
 W !,"Matched"_","_^UPRN("STATS","MATCHED")
 W !,"Unmatched"_","_^UPRN("STATS","UNMATCHED")
 s parent=^UPRN("STATS","VAR","SUPRA")
 s child=^UPRN("STATS","VAR","SUB")
 s sibling=^UPRN("STATS","VAR","SIBLING")
 s equal=^UPRN("STATS","MATCHED")-(parent+child+sibling)
 w !,"Matched as Equvalent"_","_equal
 w !,"Matched as Parent"_","_parent
 w !,"Matched as child (sub)"_","_child
 w !,"Matched as sibling"_","_sibling
 w !,"Matched with wrong post code"_","_^UPRN("STATS","VAR","WRONGPOST")
 f var="LEVENOK","PARTIAL","FIRSTPART","SUFFDROP","SIFFIGNORE","CORRECT","PLURAL" D
 W !,"Levenshtein used"_","_^UPRN("STATS","VAR","LEVENOK")
 W !,"Partial match on address line"_","_^UPRN("STATS","VAR","PARTIAL")
 W !,"First part match on address line"_","_^UPRN("STATS","VAR","FIRSTPART")
 W !,"Dropped flat/number suffix in candidate"_","_^UPRN("STATS","VAR","SUFFDROP")
 W !,"Ignored suffix in ABP files"_","_^UPRN("STATS","VAR","SUFFIGNORE")
 W !,"Spelling correction needed"_","_^UPRN("STATS","VAR","CORRECT")
 W !,"Trailing S removed"_","_^UPRN("STATS","VAR","PLURAL")
 W !,"Matched on LPI"_","_^UPRN("STATS","VAR","LPI")
 W !,"Matched on DPA"_","_^UPRN("STATS","VAR","DPA")
 ;W !,"Matched with combined DPA-LPI"_","_^UPRN("STATS","VAR","DPA-LPI")
 w !,"Matched on first pass"_","_^UPRN("STATS","VAR","PASS1")
 w !,"Matched on second pass"_","_^UPRN("STATS","VAR","PASS2")
 w !,"Matched on third pass"_","_^UPRN("STATS","VAR","PASS3")
 w !,"Matched on fourth pass"_","_$G(^UPRN("STATS","VAR","PASS4"),0)
 w !,"Matched on fifth pass"_","_$G(^UPRN("STATS","VAR","PASS5"),0)
 
 close out51
 
 set out51="/MSM/"_folder_"/UPRN_stats.csv"
 open out51:(newversion:stream:nowrap:chset="M")
 use out51 w "Total,Percentage,Algorithm,Description"
 
 W ",Wrong post code,Sub address,Spelling,Plural,Dropped"
 w ",Swapped words,Partial phrase,DPA,LPI,DPA-LPI"
 W ",Levenshtein,Ignore suffix,Suffix dropped,Flat letter problem"
 w ",First part,Subflat ignored,Subflat dropped"
 k order
 s total=^UPRN("STATS","TOTAL")
 s matched=^UPRN("STATS","MATCHED")
 s alg=""
 for  s alg=$O(^UPRN("STATS","ALG",alg)) q:alg=""  d
 .s num=^(alg)
 .s order(num,alg)=""
 s num=""
 for  s num=$o(order(num),-1)  q:num=""  d
 .s alg=""
 .for  s alg=$o(order(num,alg)) q:alg=""  d
 ..use out51 w !,num_","_$j(num/total*100,1,2)
 ..W ","_alg
 ..s desc=^UPRN("ALGORITHMS",alg)
 ..use out51 w ","_$tr(desc,",",";")
 ..f var="WRONGPOST","SUB","CORRECT","PLURAL","DROP","SWAP","PARTIAL","DPA","LPI" D
 ...w ","_($G(^UPRN("STATS","ALG",alg,var))*1)
 ..f var="DPA-LPI","LEVENOK","SUFFIGNORE","SUFFDROP","FLATNC","FIRSTPART" D
 ...w ","_($G(^UPRN("STATS","ALG",alg,var))*1)
 ..f var="SUBFLATI","SUBFLATD" D
 ...w ","_($G(^UPRN("STATS","ALG",alg,var))*1)
 use out51 w !
 W !,"Count,Total,Percentage"
 w !,"Total processed"_","_total
 w !,"Matched"_","_matched_","_(matched/total*100)
 W !,"Unmatched"_","_(total-matched)_","_((total-matched)/total*100)
 close out51
 q
GETDIR ;
 w !,"Enter results directory "
 w $s($D(^UPRNF("Results")):"("_^UPRNF("Results")_")",1:"")
 w ": "
 r resdir
 i resdir="",$D(^UPRNF("Results")) s resdir=^UPRNF("Results")
 i resdir="" w !,"No results generated ..." H 2 Q
 
 set attr=$$8^ZOS(resdir)
 if +attr set ^UPRNF("Results")=resdir q
 
 write *7,"dir does not exist"
 H 2
 
 do 6^ZOS(resdir)
 set err=$$8^ZOS(resdir)
 i 'err W !,*7,"Error creating results directory" h 2 G GETDIR
 s ^UPRNF("Results")=resdir
 
 q
repost(post)       ;reforms a post code
 s post=$$uc^UPRNL(post)
 s post=$e(post,1,$l(post)-3)_" "_$e(post,$l(post)-2,$l(post))
 q post
part(part)      ;Returns the name of the matched part of the address
 s part=$$lc^UPRNL(part)
 i part="p" q "Postcode"
 i part="s" q "Street"
 i part="n" q "Number"
 i part="b" q "Building"
 i part="f" q "Flat"
 q ""
degree(degree)     ;Returns the text of the degree to which it matches
 n result
 s result=""
 i degree["&" d
 .s result="mapped also to "_$$part($p(degree,"&",2))_" "
 i degree[">" d
 .s result="moved to "_$$part($p(degree,">",2))_" "
 i degree["<" d
 .s result="moved from "_$$part($p(degree,"<",2))_" "
 i degree["f" d
 .s result=$s(result="":"",1:" ")_"field merged"
 
 i degree["i" d
 .s result="ABP field ignored"
 i degree["d" d
 .I degree["xd" d  q
 ..s result=$s(result'="":result_" ",1:"")_"candidate prefix dropped to match"
 .s result="candidate field dropped"
 i degree["e" s result="equivalent"
 i degree["l" s result=result_"possible spelling error"
 i degree["a" s result=$s(result'="":result_" ",1:"")_"matched as parent"
 i degree["c" s result=$s(result'="":result_" ",1:"")_"matched as child"
 i degree["s" s result=$s(result'="":result_" ",1:"")_"matched as sibling"
 i degree["p" s result=$s(result'="":result_" ",1:"")_"partial match"
 I degree["v" s result=$s(result'="":result_" ",1:"")_"level based match"
 I degree["xd" s result=$s(result'="":result_" ",1:"")_"level based match"
 Q result

EOF;
 if '$zeof zmessage +$zstatus
 close file
 quit