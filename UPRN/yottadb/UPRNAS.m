UPRNAS ;Scotland formatting pin load
format(rec) ;
		s d=$c(9)
		s saon=$p(rec,d,4)
		s paon=$p(rec,d,5)
		s street=$p(rec,d,6)
		s locality=$p(rec,d,7)
		s town=$p(rec,d,8)
		s county=$p(rec,d,9)
		s post=$p(rec,d,11)_" "_$p(rec,d,12)
		s rec=saon_","_paon_","_street_","_locality_","_town_","_county_","_post
		q rec