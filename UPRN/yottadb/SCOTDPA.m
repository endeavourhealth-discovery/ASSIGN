SCOTDPA ; ; 4/17/24 11:40am
 quit
 
QUEUE ;
 new f
 s f="/tmp/Residuals_for_Endeavour.csv"
 close f
 o f:(readonly)
 u f r str
 k ^Q
 set t=0
 f  u f r str q:$zeof  do
 .s t=t+1
 .quit
 close f
 w !,t
 set mod=t\10
 w !,"creating the q"
 set (t,q)=1
 s f="/tmp/Residuals_for_Endeavour.csv"
 close f
 o f:(readonly)
 use f r str ; header
 f  u f r str q:$zeof  do
 .i t#mod=0 d
 ..s q=q+1
 ..quit
 .s id=$p(str,",",1)
 .s address=$p(str,",",2,99)
 .s ^Q(q,id)=address
 .s t=t+1
 .quit
 close f
 quit
 
THREAD ;
 new i
 K ^GO
 ;K ^OUT
 ;K ^ZI
 ;K ^UQUAL
 f i=1:1:$o(^Q(""),-1) do
 . job GO(i):(out="/dev/null")
 . quit
 quit
 
TOTQS ;
 K ^TOTQ
 
 f q=1:1:$o(^Q(""),-1) do
 .set id="",t=0
 .f  s id=$o(^Q(q,id)) q:id=""  do
 ..s t=t+1
 ..quit
 .s ^TOTQ(q)=t
 .quit
 quit
 
PROGRESS ;
 new q
 kill q
 I $DATA(^TERROR) W !,"CRASHED"
 set g=0,t=0
 f q=1:1:$o(^Q(""),-1) do
 .;s id="",t=0
 .;f  s id=$o(^Q(q,id)) q:id=""  do
 .w !,q," ",+$get(^ZI(q))," of ",$GET(^TOTQ(q))," ",$get(^ZI(q,1))
 .set g=g+$GET(^TOTQ(q))
 .set t=t+$get(^ZI(q))
 .;w !,q," ",$get(^ZI(q,1))
 .quit
 w !,t," of ",g," ",$j(t/g*100,0,2),"%"
 SET T=0 F I=1:1:$O(^OUT(""),-1) S A="" F  S A=$O(^OUT(I,A)) Q:A=""  S T=T+1
 ;set t=T-t
 set t=T
 w !,t," of ",g," ",$j(t/g*100,0,2),"%"
 quit
 
ERROR ;
 set Zid=$o(^TERROR(""),-1)+1
 S %TOP=$STACK(-1),%N=0
 F %LVL=0:1:%TOP S %N=%N+1,^TERROR(Zid,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 set %X="^TERROR(Zid,""error"",""symbols"","
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 ;
 quit
 
GO(q) ;
 new a
 set $et="G ERROR^SCOTDPA"
 ;k ^OUT(q)
 set ^GO(q)=$job
 ; add this line back in if starting from fresh
 ;set ^ZI(q,2)=$$HT^STDDATE($P($H,",",2))
 set id="",t=1
 f  s id=$order(^Q(q,id)) q:id=""  do
 .i t#100=0 w !,t
 .; if starting a fresh - remember to remove this line
 .I $data(^OUT(q,id)) quit
 .set ^ZI(q)=t
 .set address=^Q(q,id)
 .set naddress=$$TR^LIB(address,"$",",")
 .set ^ZI(q,1)=naddress
 .k a
 .set a("adrec")=naddress
 .set a("delim")="~"
 .do GETCSV2^UPRNDDS(.r,.a)
 .s ^OUT(q,id,1)=$get(^TMP($J,1))
 .s ^OUT(q,id,2)=$get(^TMP($J,2))
 .I $data(^TUPRN($J,"NOMATCH")) merge ^UQUAL(q,id)=^TUPRN($job)
 .s t=t+1
 .quit
 set ^ZI(q,3)=$$HT^STDDATE($P($H,",",2))
 quit
 
STOP ;
 set q=""
 f  s q=$o(^GO(q)) q:q=""  do
 . s cmd="mupip stop "_^GO(q)
 . zsystem cmd
 . quit
 quit
 
STT ;
 new f,d,str,id
 set d=","
 s f="/tmp/Residuals_for_Endeavour.csv"
 close f
 o f:(readonly)
 u f r str ; header
 set zt=0
 f  u f r str q:$zeof  do
 .k a
 .i zt#100=0 use 0 w !,zt
 .set id=$p(str,d,1)
 .set address=$piece(str,d,2,99)
 .set naddress=$$TR^LIB(address,"$",",")
 .set a("adrec")=naddress
 .set a("delim")="~"
 .do GETCSV2^UPRNDDS(.r,.a)
 .d OUTPUT(id,address,naddress)
 .;use 0 w !,^TMP($j,1)
 .set zt=zt+1
 .quit
 close f
 quit
 
OUTPUT(id,address,naddress) ; unpack all the pieces, even though output is only:
 ; UPRN
 ; Address Base Premium matched Address;
 ; Classification Code of the Property;
 ; Field Matching Quality;
 ; Address Quality.
 
 new rec
 set rec=^TMP($j,1)
 set abp=^TMP($j,2)
 ;use 0
 ;w !,id
 ;w !,address
 ;w !,naddress
 ;w !,rec
 ;w !,abp,!
 ;r *y
 quit
