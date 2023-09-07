YOTTA    ;NEW PROGRAM [ 08/14/2023  2:35 PM ]
AUTOUPD      ;
	s rtn=""
	for  s rtn=$O(^YOTTA(rtn)) q:rtn=""  d
	. s f1=^UPRNF("git")_"/"_rtn_".m"
		 . k ^TEMP($J)
		 . o f1:(readonly)
		 . f i=1:1 u f1 r str q:$zeof  s ^TEMP($j,i)=str
		 . c f1
		 . u 0 w rtn," from, spource to yotta",!
		 . s f2=$p($p($zro," "),"(",2)_"/"_rtn_".m"
		 . o f2:newversion
		 . f i=1:1:$o(^TEMP($j,""),-1) use f2 w ^TEMP($j,i),!
		 . c f2
		 . ZLINK rtn
		 . q
		 q
	;