FX2 ; ; 12/19/22 3:35pm
 ;
 quit
 
LOG(text) ;
 new line
 S line=$order(^TLOG($job,""),-1)+1
 S ^TLOG($job,line)=text
 quit
 
PLACEATEVT(nor,eventdate,debug,ignoregms) ;
 new gms,id,adrid,matchid,start,end,ret,lsoa,msoa
 
 if eventdate["-" s eventdate=$$F(eventdate)
 if '$data(^VPROP) do
 .for z="R","RD","RD01","RD02","RD03","RD04","RD06","RD07","RD10","RH02","U","UC","UP","X" S ^VPROP(z)=""
 .quit
 
 kill ^TLOG($job)
 set debug=+$get(debug)
 
 set eventdate=$$DH^STDDATE(eventdate)
 
 ;W !,eventdate,!
 
 set gms=1
 set:'+$get(ignoregms) gms=$$GMS(nor,eventdate)
 
 ;W !,gms,!
 
 
 d:debug LOG("trace started")
 
 if gms=2 do  quit ret
 .D:debug LOG(nor_" not registered on "_$$HD^STDDATE(eventdate))
 .set ret=nor_"~"_eventdate_"~2"
 .quit
 
 K ^TFX($job)
 
 S cnt=0
 set adrid=""
 f  s adrid=$o(^ADR(nor,adrid)) q:adrid=""  s cnt=cnt+1
 D:debug LOG("patient has "_cnt_" address record(s)"),LOG("Step-1 (temp?, class prop, best match checks)")
 
 f  s adrid=$o(^ADR(nor,adrid)) q:adrid=""  do
 .s rec=^ADR(nor,adrid)
 .S use=$piece(rec,"~",5)
 .S lsoa=$p(rec,"~",6)
 .S msoa=$p(rec,"~",7)
 .if use="1335360" do  quit ; Temps
 ..do:debug LOG("adrid: "_adrid_" temp address (skip address)")
 ..quit
 .s start=$$F($piece(rec,"~",2)),end=$$F($piece(rec,"~",3))
 .i start'="" s start=$$DH^STDDATE(start)
 .i end'="" s end=$$DH^STDDATE(end)
 .s:start="" start=0
 .s:end="" end=0
 .S matchid=$$X(adrid)
 .i debug,matchid="" D LOG("adrid: "_adrid_" does not have an ASSIGN record")
 .i matchid="" quit
 .s rec=^MATCH(adrid,matchid)
 .s classprop=$p(rec,"~",4)
 .i debug D LOG("Checking adrid: "_adrid_" class prop? "_classprop_" "_$GET(^RESCODE(classprop))_" "_$S($D(^VPROP(classprop)):"true",1:"false"))
 .if '$d(^VPROP(classprop)) quit
 .s qualifier=$p(rec,"~",9)
 .if debug D LOG("Checking adrid: "_adrid_" Best (residential) match?: "_qualifier_" "_$s(qualifier'="Best (residential) match":"false",1:"true"))
 .if qualifier'="Best (residential) match" quit
 .set ^TFX($job,start,matchid)=rec
 .s ^TFX($j,start,matchid,"e")=end
 .s ^TFX($J,start,matchid,"adrid")=adrid
 .s ^TFX($J,start,matchid,"use")=use
 .s ^TFX($J,start,matchid,"lsoa")=lsoa
 .s ^TFX($J,start,matchid,"msoa")=msoa
 .quit
 
 D:debug LOG("Step-2 (date logic)")
 D:debug LOG("(address.start_date <= @event_date or address.start_date is null) AND (address.end_date >= @event_date or address.end_date is null)")
 
 set (start,matchid,qf)=""
 ; -1 originally on $o
 f  s start=$o(^TFX($J,start),-1) q:start=""  do  q:qf'=""
 .f  s matchid=$o(^TFX($J,start,matchid),-1) q:matchid=""  do  q:qf'=""
 ..s end=^TFX($j,start,matchid,"e")
 ..s use=^TFX($j,start,matchid,"use")
 ..s adrid=^TFX($J,start,matchid,"adrid")
 ..s lsoa=^TFX($J,start,matchid,"lsoa")
 ..s msoa=^TFX($J,start,matchid,"msoa")
 ..s rec=^TFX($j,start,matchid)_"|"_matchid_"~"_$S(start>0:$$HD^STDDATE(start),1:0)_"~"_$s(end>0:$$HD^STDDATE(end),1:0)_"~"_adrid
 ..s s=nor_"~"_$$HD^STDDATE(eventdate)_"~"
 ..i debug D LOG("processing "_adrid_" start:"_$S(start=0:"null",1:$$HD^STDDATE(start))_" end: "_$s(end=0:"null",1:$$HD^STDDATE(end))_" event_date: "_$$HD^STDDATE(eventdate))
 ..if (($$LQ(start,eventdate)!(start=0))&($$GQ(end,eventdate)!(end=0))) S qf=s_rec_"|"_lsoa_"~"_msoa D LOG("going with: "_adrid) quit
 ..D LOG("skipping: "_adrid)
 ..quit
 if debug,qf'="" D LOG("Found RALF:"_$P(qf,"~",4)),LOG("SKID01: "_$get(^SKID(nor,$p(qf,"~",4))))
 quit qf
 
X(adrid) ; get latest match record for address id
 new matchid
 set matchid=""
 s matchid=$o(^MATCH(adrid,""),-1)
 ;
 ;
 quit matchid
 
GMS(nor,eventdate) 
 new start,end,dates,b,dod
 kill dates
 
 ;s dod=+$get(^ASUM(nor,"dod"))
 ;i dod'=0,$$GQ($$DH^STDDATE($$F(dod)),eventdate) q 2
 
 s dod=$get(^ASUM(nor,"dod"))
 i dod'="",$$GQ(eventdate,$$DH^STDDATE($$F(dod))) q 2
 
 D DATES(nor,.dates)
 
 ;W !
 ;ZWR dates
 ;W !
 
 s (start,end)=""
 s b=2
 
 f  s start=$o(dates(start),-1) q:start=""  do  quit:b'=2
 .f  s end=$o(dates(start,end),-1) q:end=""  do  quit:b'=2
 ..;
 ..;S start=$o(dates(start),-1)
 ..;S end=$o(dates(start,end),-1)
 ..;if start'=0,$$GQ(start,eventdate) quit
 ..if start'=0,start>eventdate quit
 ..if $$LQ(start,eventdate),end=0 set b=1 q
 ..if $$GQ(end,eventdate),$$GQ(end,start) s b=1 q
 ..if start<eventdate,end<start s b=3
 ..quit
 .quit
 quit b
 
 ; <=
LQ(var1,var2) 
 if var1=var2 q 1
 if var1<var2 q 1
 quit 0
 
 ; >=
GQ(var1,var2) 
 if var1=var2 q 1
 if var1>var2 q 1
 quit 0
 
DATES(nor,dates) 
 new id,start,end,rec
 s id=""
 f  s id=$o(^EOC(nor,id)) q:id=""  do
 .s rec=^(id)
 .S type=$p(rec,"~",2)
 .; Regular?
 .i type'=1335267 quit
 .s start=$$F($p(rec,"~",3)),end=$$F($p(rec,"~",4))
 .i start'="" s start=$$DH^STDDATE(start)
 .i end'="" s end=$$DH^STDDATE(end)
 .s:start="" start=0
 .s:end="" end=0
 .s dates(start,end)=""
 .quit
 quit
 
F(d) ;
 if d="" q ""
 s d=$p(d,"-",3)_"."_$p(d,"-",2)_"."_$p(d,"-")
 quit d
