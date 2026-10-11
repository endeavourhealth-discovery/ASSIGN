XINDONLY ;Rebuilds all the UPRN indexes [ 05/22/2023  11:42 AM ]
	;5.5.2
	K ^UPRNX("X")
	w !,"Start"
	n d,rec,table,key,uprn,town,post,flat,build,bno,depth,street,deploc,loc,ZONE
	s d="~"
	s i=0
	s uprn=""
	for  s uprn=$O(^UPRN("U",uprn)) q:uprn=""  d
	. s table=""
	. for  s table=$O(^UPRN("U",uprn,table)) q:table=""  d
	. . S key=""
	. . for  s key=$O(^UPRN("U",uprn,table,key)) q:key=""  d
	. . . s rec=^UPRN("U",uprn,table,key)
	. . . q:rec=""
	. . . s flat=$p(rec,d,1)
	. . . s build=$p(rec,d,2)
	. . . s bno=$p(rec,d,3)
	. . . s depth=$p(rec,d,4)
	. . . s street=$p(rec,d,5)
	. . . s deploc=$p(rec,d,6)
	. . . s loc=$p(rec,d,7)
	. . . s town=$p(rec,d,8)
	. . . s post=$p(rec,d,9)
	. . . D setind1
	. . . s i=i+1
	. . . I '(i#250000) w i," " set ^I=i
	q
setind1 ;Sets indexes
	n i
	s ZONE=$e(post,1)
	s pstreet=$$plural^UPRNU(street)
	s pbuild=$$plural^UPRNU(build)
	s pdepth=$$plural^UPRNU(depth)
	s same=0
	i pstreet=street,pbuild=build,pdepth=depth s same=1
	s indrec=post_" "_flat_" "_build_" "_bno_" "_depth_" "_street_" "_deploc_" "_loc
	s indrec=$$concat^UPRN(indrec)
	S ^UPRNX("X",indrec,uprn,table,key)=""
	i 'same d
	. s indrec=post_" "_flat_" "_pbuild_" "_bno_" "_pdepth_" "_pstreet_" "_deploc_" "_loc
	. s indrec=$$concat^UPRN(indrec)
	. S ^UPRNX("X",indrec,uprn,table,key)=""
eind q
	;