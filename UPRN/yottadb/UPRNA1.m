UPRNA1(adflat,adbuild,adbno,adstreet,adloc,adeploc) ;Additional preformatting routine [ 08/02/2023  11:55 AM ]
 ;
f153A ;Flat in location
 i adloc'="",adstreet'="",adbno="",adbuild'="" d
 .i $$isflat^UPRNU(adloc) d
 ..I adloc?1l.l1" "1n.n.l d
 ...i $d(^UPRNX("X.BLD",adstreet)) d
 ...i '$D(^UPRNX("X.BLD",adbuild)) d
 ....s adbno=adflat
 ....s adflat=$$flat^UPRNU(adloc)
 ....s xbuild=adbuild
 ....s adbuild=adstreet
 ....s adstreet=xbuild
  ; 
F154 ;Building is number flat range
 i adflat="",adbno="",adstreet'="",adbuild?1n.n.1"-"1l1"-"1l d
 .s adbno=$p(adbuild,"-",1)_$p(adbuild,"-",2,3)
 .s adbuild=""
 ;
f155 ;
 i adflat="",adbno="",adstreet'="",adbuild?1n.n1"-"1l d
 .s adbno=$p(adbuild,"-")_$p(adbuild,"-",2)
 .s adbuild=""
 ;
f156 ;
 n lpart
 i adflat="",adbno'="",adstreet'="",adbuild[" " d
 .I '$D(^UPRNX("X3",adbuild)) d
 ..I $D(^UPRNX("X3",$p(adbuild," ",1,$l(adbuild," ")-1))) d
 ...s lpart=$p(adbuild," ",$l(adbuild," "))
 ...i lpart?1"-"1n.n d
 ....s adflat=$p(lpart,"-",2)
 ....s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 ...i lpart?1n.n d
 ....s adflat=lpart
 ....s adbuild=$p(adbuild," ",1,$l(adbuild," ")-1)
 ;
 
 i adflat="",adbuild'="",'$D(^UPRNX("X3",adbuild)) d
 .i adbuild'[" ",$e(adbuild,$l(adbuild))?1n d
 ..s done=0
 ..f i=$l(adbuild):-1:1 d  q:done
 ...i $e(adbuild,i)'?1n d
 ....s adflat=$e(adbuild,i+1,$l(adbuild))
 ....s adbuild=$e(adbuild,1,i)
 ....s done=1
 ....I $d(^UPRNS("FLAT",adbuild)) s adbuild=""
 i adflat?1"g-"1n.n.l d
 .s adflat="g"_$p(adflat,"g-",2)
 I adstreet'[" ",$D(^UPRNX("X.STR",adloc)) d
 .n tbld,tadbuild,done
 .s tbld="",done=0
 .for  s tbld=$O(^UPRNS("BUILDING",tbld)) q:tbld=""  d
 ..s tadbuild=adstreet_" "_tbld
 ..I $D(^UPRNX("X.BLD",tadbuild)) d  s done=1
 ...s adflat=adflat_" "_adbuild
 ...s adbuild=tadbuild
 ...s adstreet=adloc
 ...s adloc=""
 ;i adstreet'="",adstreet'[" " d
 .s adstreet=$$delcity^UPRNA(adstreet)
 .I $g(^UPRNX("X.STR",adstreet))?1l.e d
 ..s adstreet=^(adstreet)
 i adflat?1n.n.l1" "1l.l d
 .I '$D(^UPRNX("X.BLD",adbuild)) d
 ..i $D(^UPRNX("X.BLD",$p(adflat," ",$l(adflat," "))_" "_adbuild)) d
 ...s adbuild=$p(adflat," ",$l(adflat," "))_" "_adbuild
 ...s adflat=$p(adflat," ",1,$l(adflat," ")-1)
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
 .i $p(adflat," ",$l(adflat," "))?1n.n.l,adbno="" d
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
 .i adbuild="" d
 ..i $D(^UPRNX("X.BLD",adstreet)) d
 ...S adbuild=adstreet
 ...s adstreet=""
 Q
change(glob,node,from,to)    ;
 n nodes
 s nodes=glob_"("_node_")"
 for  s nodes=$q(@nodes) q:(nodes'[(glob_"("_node))  d
 .s @nodes=$$tr^UPRNL(@nodes,from,to)
 q
        
