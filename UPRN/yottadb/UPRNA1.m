UPRNA1(adflat,adbuild,adbno,adstreet,adloc,adeploc) ;Additional preformatting routine [ 05/14/2023  12:45 PM ]
 ;Repeated flat number
 i adbno=adflat,adbuild="",$D(^UPRNS("BUILDING",$p(adstreet," ",$l(adstreet," ")))) d
 .s adbno=""
 .s adbuild=adstreet
 .s adstreet=""
 I adbno="",adflat?1n.n.l1" "1l.e d
 .i adbuild?1n.n1" "1l.e d
 ..i $D(^UPRNS("ROAD",adstreet)) d
 ...s adbno=$p(adbuild," ")
 ...s adstreet=$p(adbuild," ",2,10)_" "_adstreet
 ...s adbuild=$p(adflat," ",2,20)
 ;unformed street
 ;Dependent location is street
 i adeploc'="",adbno="",adflat="" d
 .i adeploc?1n.n.e1" "1l.e d
 ..I $D(^UPRNX("X.STR",$p(adeploc," ",2,20))) d
 ...s adbno=$p(adeploc," ")
 ...s adflat=adbuild,adbuild=adstreet,adstreet=$p(adeploc," ",2,20)
 ...s adeploc=""
 ;is there a name and number or range in the street
 i adbuild'="",adbuild=adstreet,$D(^UPRNX("X.STR",adbuild)) d
 .i $p(adflat," ",$l(adflat," "))?1n.n.l d
 ..s adbno=$p(adflat," ",$l(adflat," "))
 ..s adbuild=$p(adflat," ",1,$l(adflat," ")-1)
 ..s adflat=""
 i adbno="",adbuild="" d
 f i=$l(adstreet," ")-1:-1:2 d
 .s tstr=$p(adstreet," ",i,$l(adstreet," "))
 .i $D(^UPRNX("X.STR",tstr)) d
 ..s tstno=$p(adstreet," ",i-1)
 ..i tstno?1n.n.l!(tstno?1n.n1"-"1n.n) d
 ...s adbno=$p(adstreet," ",i-1)
 ...i i=2 d
 ....s adstreet=$p(adstreet," ",i,$l(adstreet," "))
 ...e  d
 ....s adbuild=$p(adstreet," ",1,i-2)
 ....s adstreet=$p(adstreet," ",i,$l(adstreet," "))
 I adstreet'="",'$D(^UPRNX("X.STR",adstreet)),adbno="" d
 f i=$l(adbuild," ")-1:-1:2 d
 .s tstr=$p(adbuild," ",i,$l(adbuild," "))
 .i $D(^UPRNX("X.STR",tstr)) d
 ..s tstno=$p(adbuild," ",i-1)
 ..i tstno?1n.n.l!(tstno?1n.n1"-"1n.n) d
 ...s adbno=$p(adbuild," ",i-1)
 ...i i>2 d
 ....s adstreet=$p(adbuild," ",i,$l(adbuild," "))
 ....s adbuild=$p(adstreet," ",1,i-2)
 Q
change(glob,node,from,to)    ;
 n nodes
 s nodes=glob_"("_node_")"
 for  s nodes=$q(@nodes) q:(nodes'[(glob_"("_node))  d
 .s @nodes=$$tr^UPRNL(@nodes,from,to)
 q
        
