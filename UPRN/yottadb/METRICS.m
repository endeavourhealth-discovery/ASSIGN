METRICS ; ; 4/25/24 2:53pm
 quit

NEXTQ(zid) ;
 new h
 set (h,qf)=""
 f  s h=$o(^ZQZ(zid,h)) q:h=""  do  q:qf'=""
 .I '$data(^ZQZ1(zid,h)) s qf=h
 .quit
 if qf="" s qf=$order(^ZQZ(zid,""),-1)
 quit qf

STT ;
 kill
 s token=$$GETTOKEN^ABPAPI()
 S cmd="curl -s -H ""Authorization: Bearer "_token_""" ""https://api.os.uk/downloads/v1/dataPackages"""
 D RUN^ABPAPI(cmd)
 set json=$$JSON^ABPAPI()
 set J=json
 D DECODE^VPRJSON($name(J),$name(b),$name(err))
 s (l,cegutil)=""
 f  s l=$o(b(l)) q:l=""  do
 .i b(l,"name")=^ICONFIG("COU-NAME") s cegutil=l
 .quit
 
 set l="",(count,processed)=0
 k not
 f  s l=$o(b(cegutil,"versions",l)) q:l=""  do
 .set supplytype=b(cegutil,"versions",l,"supplyType")
 .i supplytype'="Change Only Update" quit
 .set id=b(cegutil,"versions",l,"id")
 .set count=count+1
 .I $data(^DSYSTEM("COU",id)) set processed=processed+1
 .if '$d(^DSYSTEM("COU",id)) s not(id)=b(cegutil,"versions",l,"createdOn")
 .quit
 
 w !,"data package: ",^ICONFIG("COU-NAME")
 w !,"number of available osdatahub updates: ",count
 w !,"processed: ",processed
 if $data(not) do
 .w !,"not processed:"
 .set id=""
 .f  s id=$o(not(id)) q:id=""  do
 ..w !,"id: ",id," created on: ",not(id)
 ..quit
 .quit
 
 set nextdown=$$NEXTQ(1)
 set t1=$get(^ZQZ(1,nextdown))
 S status1="QUEUED"
 if $d(^ZQZ1(1,nextdown)) set status1="COMPLETED"
 
 set nextupdate=$$NEXTQ(2)
 set t2=$get(^ZQZ(2,nextupdate))
 set status2="QUEUED"
 if $d(^ZQZ1(2,nextupdate)) set status2="COMPLETED"
 
 W !,"next scheduled download run: ",$$HD^STDDATE(nextdown)," at ",$$HT^STDDATE(t1)," ",status1
 write !,"next scheduled database update run: ",$$HD^STDDATE(nextupdate)," at ",$$HT^STDDATE(t2)," ",status2
 
 w !,"last index run:"
 set start=$get(^STATS("START"))
 set end=$get(^STATS("END"))
 s s1=$p(start,","),t1=$p(start,",",2)
 s e1=$p(end,","),t2=$p(end,",",2)
 w !,"started: ",$$HD^STDDATE(s1)," at ",$$HT^STDDATE(t1)
 w !,"finished: ",$$HD^STDDATE(e1)," at ",$$HT^STDDATE(t2)
 quit
