CQC2 ; ; 1/15/21 1:22pm
 ;
 ;
ZSETUP ;
 set ^%W(17.6001,"B","GET","api2/cqcaudit","UIAUDIT^CQC2",342)=""
 set ^%W(17.6001,342,0)="GET"
 set ^%W(17.6001,342,1)="api2/cqcaudit"
 set ^%W(17.6001,342,2)="UIAUDIT^CQC2"
 
 set ^%W(17.6001,"B","GET","api2/orgcsv","DOWNALL^CQC2",323)=""
 set ^%W(17.6001,323,0)="GET"
 set ^%W(17.6001,323,1)="api2/orgcsv"
 set ^%W(17.6001,323,2)="DOWNALL^CQC2"
 
 set ^%W(17.6001,"B","GET","api2/getconfigs","GETCONFIGS^CQC2",303)=""
 set ^%W(17.6001,303,0)="GET"
 set ^%W(17.6001,303,1)="api2/getconfigs"
 set ^%W(17.6001,303,2)="GETCONFIGS^CQC2"
 QUIT
 
GETCONFIGS(result,arguments) 
 k ^TMP($J)
 S userid=$get(arguments("userid"))
 set config=""
 set j="[",id=0
 f  s config=$order(^ICONFIG("SUB-CONFIG",config)) quit:config=""  do
 .s j=j_"{""value"": """_id_""",""display"": """_config_"""},"
 .s id=id+1
 .quit
 S j=$extract(j,1,$l(j)-1)
 set j=j_"]"
 S ^TMP($J,1)=j
 s result("mime")="text/plain, */*"
 s result=$na(^TMP($J))
 quit
 
UIAUDIT(result,arguments) 
 S str=$get(arguments("str"))
 S config=$get(arguments("config"))
 S ^PSHERE=config
 D web(str,config)
 s result("mime")="text/plain, */*"
 s result=$na(^TMP($J))
 quit
 
DOWNALL(result,arguments) 
 ;S ^HERE="DOWNLOAD ALL"
 S userid=$g(arguments("userid"))
 S disco=$g(arguments("disco"))
 S config=$g(arguments("config"))
 ; carehomes
 S ch=$g(arguments("ch"))
 S ^HERE="DOWNLOAD ALL~"_userid_"~"_disco_"~"_config_"~"_ch
 DO ALL(config,ch)
 set result("mime")="text/plain, */*"
 S result=$na(^TMP($J))
 ;
 QUIT
 
ALL(config,ch) ;
 K %zi,%zo
 if ch=1 S sql="select top 20000 A2.id, A2.date, A2.name, A2.value from audit_additional2 A2 where A2.id in (select A1.id from audit_additional2 A1 where name='cqc_carehome' and value='Y')"
 if ch=0 s sql="select id, date, name, value from audit_additional2 where subconfig='"_config_"'"
 s dbid=$$schema^%mgsql("")
 s line(1)=sql
 s %zi(0,"stmt")=0
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 s %zo("routine")=rou,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
 D GO
 quit
 
RUNSQL(sql) 
 K %zi,%zo
 K ^mgsqls($j)
 s dbid=$$schema^%mgsql("")
 s line(1)=sql
 s %zi(0,"stmt")=0
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 I rou="" ; return an error
 i rou'="" s %zo("routine")=rou,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
 QUIT
 
GETABP(UPRN,NODE) 
 ;S KEY=""
 
 S KEY=$O(^UPRN("U",UPRN,NODE,""))
 S ZADR=""
 I KEY'="" DO
 .D GETADR^UPRNU(UPRN,NODE,KEY,.flat,.build,.bno,.depth,.street,.deploc,.loc,.town,.post,.org)
 .S ZADR=flat_","_build_","_bno_","_depth_","_street_","_deploc_","_loc_","_town_","_post_","_org
 .QUIT
 
 ;S KEY=$O(^UPRN("U",UPRN,"D",""))
 ;I KEY'="" DO
 ;
 QUIT ZADR
 
TRIPLE(subid,zdate) ;
 k ^TRIPLE($J)
 s sql="SELECT * FROM audit_additional2 WHERE id = "_subid_" and date='"_zdate_"'"
 D RUNSQL(sql)
 ;zwr ^mgsqls($j,*)
 S r=""
 f  s r=$o(^mgsqls($j,0,0,r)) q:r=""  do
 .s value=^mgsqls($j,0,0,r,6)
 .s prop=^mgsqls($j,0,0,r,7)
 .S ^TRIPLE($J,prop,value)=""
 .quit
 quit
 
CHK2(config) ;
 S A=""
 S ZF="/tmp/cqc_v_disco_v2.csv"
 C ZF
 O ZF:(newversion)
 U ZF W "adr_candidate,disco,cqc,cqc_location,diff,disco_abp,cqc_abp,cqc_service_type,qualifier,cqc_carehome,cqc_dormancy,ods_code",!
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .S SUBID=^CQC(A,"SUB")
 .I ^CQC(A,"CONFIG")'=config quit
 .S h=^CQC(A,"H"),d=$$HD^STDDATE(+h),%TM=$P(h,",",2)
 .S zd=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
 .DO %CTS^%H
 .S zdate=zd_" "_%TIM
 .D TRIPLE(SUBID,zdate)
 .s CQCUPRN=$O(^TRIPLE($J,"cqc_uprn",""))
 .s locid=$o(^TRIPLE($J,"cqc_location",""))
 .s ch=$o(^TRIPLE($J,"cqc_carehome",""))
 .s stypes="",stype=""
 .f  s stype=$o(^TRIPLE($J,"service_type",stype)) q:stype=""  s stypes=stypes_stype_"~"
 .set dormant=$O(^TRIPLE($j,"cqc_dormancy",""))
 .set odscode=$o(^TRIPLE($J,"cqc_odscode",""))
 .; GET JSON FROM ^CQC global
 .S (J,I)=""
 .F  S I=$O(^CQC(A,I)) Q:I=""  DO
 ..I I'?1N.N QUIT
 ..S J=J_^(I)
 ..;
 ..QUIT
 .; FINALLY, GET THE ADDRESS CANDIDATE!
 .K b,err
 .D DECODE^VPRJSON($name(J),$name(b),$name(err))
 .;
 .S ADR=$get(b("address",1,"text"))
 .; call the algorithm
 .K ^TPARAMS($J),^TUPRN($J)
 .S ^TPARAMS($J,"commercials")=1
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .K b D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 .S UPRN=$get(b("UPRN"))
 .set star=""
 .I CQCUPRN'=UPRN s star="*"
 .; ABP ADDRESS
 .;
 .S DISCOABP=$$GETABP(UPRN,"L")
 .I DISCOABP="" S DISCOABP=$$GETABP(UPRN,"D")
 .S CQCABP=$$GETABP(CQCUPRN,"L")
 .I CQCABP="" S CQCABP=$$GETABP(CQCUPRN,"D")
 .s table=$O(^TUPRN($j,"MATCHED",uprn,""))
 .s key=$O(^TUPRN($J,"MATCHED",UPRN,table,""))
 .S matchrec=$get(^TUPRN($j,"MATCHED",uprn,table,key))
 .S QUAL=""
 .S:matchrec'="" QUAL=$$qual^UPRN2(matchrec)
 .I star="" S DISCOABP="",CQCABP=""
 .U ZF w """",ADR,""",",UPRN,",",CQCUPRN,",",locid,",",star,",""",DISCOABP,""",""",CQCABP,""",",stypes,",",QUAL,",",ch,",",dormant,",",odscode,!
 .QUIT
 CLOSE ZF
 QUIT
 
 ; redundant: use CHK2
UPRNCHK ;
 K ^mgsqls($j)
 S sql="select id, value, name, date from audit_additional2 where name='discovery_uprn' or name = 'cqc_uprn'"
 D RUNSQL(sql)
 K ^TEMP($J)
 S (row,col)=""
 F  S row=$o(^mgsqls($j,0,0,row)) q:row=""  do
 .F  s col=$o(^mgsqls($j,0,0,row,col)) q:col=""  do
 ..s id=^mgsqls($j,0,0,row,1)
 ..s uprn=^mgsqls($j,0,0,row,2)
 ..s source=^mgsqls($j,0,0,row,3)
 ..s date=^mgsqls($j,0,0,row,4)
 ..S ^TEMP($J,id,source)=uprn
 ..q
 .quit
 S T=0
 S (id,source)=""
 f  s id=$o(^TEMP($J,id)) q:id=""  do
 .s cqc=$get(^TEMP($J,id,"cqc_uprn"))
 .s disco=$get(^TEMP($J,id,"discovery_uprn"))
 .I cqc'=disco w !,id,"*",cqc,"*",disco S T=T+1
 .quit
 W !,T
 QUIT
 
web(STR,config) ;
 K %zi,%zo
 S STR=$$UC^LIB(STR)
 s sql="select top 20000 A2.id, A2.date, A2.name, A2.value from audit_additional2 A2 where A2.id in (select A1.id from audit_additional2 A1 where upper(A1.value) like '%"_STR_"%' and subconfig='"_config_"')"
 s dbid=$$schema^%mgsql("")
 s sql=$tr(sql,$c(13,10),"")
 s line(1)=sql
 s %zi(0,"stmt")=0
 s rou=$$main^%mgsqlx(dbid,.line,.info,.error)
 I rou="" ; return an error
 s qid=$g(info("qid"))
 
 K ^TMP($J)
 S l=1
 
 
 i rou'="" s %zo("routine")=rou,@("ok=$$exec^"_rou_"(.%zi,.%zo)")
 
GO K ^TEMP($J)
 S (row,col)=""
 f  s row=$o(^mgsqls($j,0,0,row)) q:row=""  do
 .S id=^mgsqls($j,0,0,row,1)
 .; yyyy-mm-dd
 .S date=^mgsqls($j,0,0,row,2)
 .S dat=$P(date," "),%TM=$P(date," ",2)
 .D %CTN^%H
 .S y=$p(dat,"-",1),m=$p(dat,"-",2),d=$p(dat,"-",3)
 .S hdate=$$DH^STDDATE((d_"."_m_"."_y))
 .S prop=^mgsqls($j,0,0,row,3)
 .S value=^mgsqls($j,0,0,row,4)
 .S D=""
 .I prop="specialisms/services"!(prop="service_type") set D="~"
 .S ^TEMP($J,id,prop,hdate,%TIM)=$G(^TEMP($J,id,prop,hdate,%TIM))_value_D
 .;
 .quit
 
 K ^TMP($J)
 S l=1
 S ^TMP($J,l)="[",l=l+1
 S (id,prop,h,t)=""
 S zid=$o(^TEMP($J,""))
 K ^TDONE($J)
 S COUNT=0
 F  S id=$o(^TEMP($J,id)) q:id=""  do
 .S q=1,COUNT=COUNT+1
 .F  S prop=$o(^TEMP($J,id,prop)) q:prop=""  do
 ..;S ^TMP($J,l)="{"
 ..F  S h=$o(^TEMP($J,id,prop,h)) q:h=""  do
 ...;S q1=1
 ...F  S t=$o(^TEMP($J,id,prop,h,t)) q:t=""  do
 ....S value=^(t)
 ....S qf=0
 ....set qf=$$COMPARE(id,prop,h,t,value)
 ....I qf quit
 ....;S ^TMP($J,l)=""""_prop_""""_": """_value_""","
 ....S zid=""
 ....if q s zid=id,q=0
 ....S zdate=""
 ....;S ^PS($O(^PS(""),-1)+1)=q1
 ....s zdate=$$HD^STDDATE(h)_" "_$$HT^STDDATE(t)
 ....;S od=zdate
 ....;S ^TDONE($J,id)=""
 ....S ^TMP($J,l)="{""id"":"""_zid_""",",l=l+1
 ....S ^TMP($J,l)="""name"":"""_prop_""",",l=l+1
 ....S ^TMP($J,l)="""date"":"""_zdate_""",",l=l+1
 ....;S ^TMP($J,l)="""name"":"""_prop_""",",l=l+1
 ....S ^TMP($J,l)="""value"":"""_value_"""},",l=l+1
 ....quit
 ...quit
 ..quit
 .;
 .QUIT
 S z=l-1
 S ^TMP($J,z)=$e(^TMP($J,z),1,$l(^TMP($J,z))-1)
 S ^TMP($J,l)="]"
 
 S ^COUNT=COUNT
 
 ;S F="/tmp/test.json"
 ;C F
 ;O F:(newversion)
 ;S l=""
 ;F  S l=$O(^TMP($J,l)) q:l=""  U F w ^(l),!
 ;C F
 
 QUIT
 
COMPARE(id,prop,h,t,value) ;
 N nt,quit,nh
 set quit=0
 S ^FRED($O(^FRED(""),-1)+1)=id_"~"_prop_"~"_h_"~"_t_"~"_value
 ; same day
 S nt=$order(^TEMP($J,id,prop,h,t))
 i nt'="" do  g exit
 .s nvalue=^TEMP($J,id,prop,h,nt)
 .S:value'=nvalue ^A(id,prop,h,nt)=nvalue_"~"_value
 .i nvalue=value s quit=1
 .quit
 ; different day
 S nh=$order(^TEMP($J,id,prop,h))
 i nh'="" do
 .s nt=$order(^TEMP($J,id,prop,nh,""))
 .s nvalue=^TEMP($J,id,prop,nh,nt)
 .S:value'=nvalue ^B(id,prop,h,nt)=nvalue_"~"_value
 .i nvalue=value s quit=1
 .quit
exit ;
 quit quit
 
run ;
 K %zi,%zo
 w !,"sql? "
 r sql
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 quit
 
sel4 ;
 W !,"String? "
 R STR
 k %zi,%zo
 S sql="select * from audit_additional A2 where A2.id in (select id from audit_additional A1 where upper(A1.value) like '%"_STR_"%') order by A2.date"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 quit
 
sel3 ;
 ; select * from users where upper(first_name) like '%AL%';
 W !,"String? "
 R STR
 k %zi,%zo
 ; distinct A1.id
 S sql="select distinct A1.id from audit_additional A1 where upper(A1.value) like '%"_STR_"%'"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 quit
 
sel2 ;
 k %zi,%zo
 S sql="select * from audit_additional order by date desc"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 quit
 
sel1 ;
 k %zi,%zo
 ;S sql="select * from audit_additional a1 where value='Y' and name='cqc_carehome'"
 S sql="select top 30 * from audit_additional A2 where A2.id in (select id from audit_additional A1 where A1.name='cqc_carehome' and A1.value = 'Y')"
 ;S sql="select a1.name from audit_additional a1 join audit_additional a2 on a1.id=a2.id where a1.name='cqc_carehome' and a1.value='Y'"
 ;s sql="select * from audit_additional a1 where value='Y' and name='cqc_carehome'"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 quit
 
INDEX ;
 k %zi,%zo
 ;s sql="create index index1 on audit_additional2 ('index1', name, id)"
 s sql="create index index1 on audit_additional2 ('index1', name, id, subconfig, date, propertyid, valueid)"
 s sql=sql_" /*! global=^cqcaudit2 */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 W !,ok
 
 k %zi,%zo
 ;s sql="create index index2 on audit_additional2 ('index2', value, id)"
 s sql="create index index2 on audit_additional2 ('index2', value, id, subconfig, date, propertyid, valueid)"
 s sql=sql_" /*! global=^cqcaudit2 */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 w !,ok
 QUIT
 
SQL ;
 k ^mgsqld(0,"mgsql","t","audit_additional2")
 s sql="create table audit_additional2 ("
 s sql=sql_" id int not null,"
 S sql=sql_" subconfig varchar(255),"
 s sql=sql_" date datetime,"
 s sql=sql_" propertyid int not null,"
 s sql=sql_" valueid int,"
 s sql=sql_" value varchar(255),"
 s sql=sql_" name varchar(255),"
 ;s sql=sql_" constraint pk_audit_additional2 primary key (id, subconfig, date, propertyid, valueid))"
 ;remove indexing for now
 s sql=sql_" constraint pk_audit_additional2 primary key ('index0', id, subconfig, date, propertyid, valueid))"
 s sql=sql_" /*! global=cqcaudit2, delimiter=# */"
 s ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 W !,ok
 QUIT
 
index ;
 s sql=""
 quit
 
Q ;
 K ^Q
 S A="",Q=1
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .I A#500=0 W !,Q S Q=Q+1
 .S ^Q(Q,A)=""
 .QUIT
 QUIT
 
BULK K ^ZRUN,^RUN F Q=1:1:29 DO  Q:$D(^STOP)
 .;S B=""
 .J RUN(Q)
 .;D RUN(Q)
 .Q:$D(^STOP)
 .QUIT
 QUIT
 
RUN(Q) ;
 S B=""
 S ^ZRUN(Q,$J)=""
 S STOP=0
 F  S B=$O(^Q(Q,B)) Q:B=""  DO  Q:STOP
 .S ^RUN(Q,B)=""
 .D FILE(B)
 .I $D(^STOP) S STOP=1
 .;
 .QUIT
 QUIT
 
INSERT ;
 ;K ^cqcaudit2
 S id=0
 S A=""
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .W !,A
 .D FILE(A)
 .Q
 Q
FILE(A) ;
 N sql
 S (ZI,JSON)=""
 F  S ZI=$O(^CQC(A,ZI)) Q:ZI=""  DO
 .I ZI'?1N.N QUIT
 .S JSON=JSON_^CQC(A,ZI)
 .Q
 S id=^CQC(A,"SUB") ; subscriber_id
 S h=^CQC(A,"H"),d=$$HD^STDDATE(+h),%TM=$P(h,",",2)
 S zd=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
 DO %CTS^%H
 S zdate=zd_" "_%TIM
 
 S config=^CQC(A,"CONFIG")
 
 K b,err
 ;
 D DECODE^VPRJSON($name(JSON),$name(b),$name(err))
 ;
 S sql="insert into audit_additional2 (id, subconfig, date, propertyid, valueid, value, name) values (:id, :subconfig, :date, :prop, :valueid, :value, :name)"
 s (a)=""
 s x="valueCodeableConcept"
 s y="coding"
 
 ;w !,A
 
 f  s a=$o(b("contained",1,"parameter",a)) q:a=""  do
 .s prop=$p(b("contained",1,"parameter",a,"name"),"_",7)
 .s display=b("contained",1,"parameter",a,x,y,1,"display")
 .s valueid=$P(b("contained",1,"parameter",a,x,y,1,"code"),"_",7)
 .s value=$p(display,"~",1)
 .s name=$p(display,"~",2)
 .;w !,id,"*",zdate,"*",prop,"*",valueid,"*",value,"*",name ; r *x1
 .;w "."
 .K %zi,%zo
 .S %zi("id")=id,%zi("prop")=prop
 .S %zi("valueid")=valueid,%zi("value")=value
 .S %zi("name")=name,%zi("date")=zdate
 .S %zi("subconfig")=config
 .S sql="insert into audit_additional2 (id, subconfig, date, propertyid, valueid, value, name) values (:id, :subconfig, :date, :prop, :valueid, :value, :name)"
 .;
 .S ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 .;
 .quit
 QUIT
 
ID() ;
 L ^CQC:5
 I '$T Q 0
 S ID=$I(^CQC)
 L -^CQC
 QUIT ID
 
SETUP set ^%W(17.6001,"B","POST","api2/cqcarchive","ARCHIVE^CQC2",922)=""
 set ^%W(17.6001,922,0)="POST"
 set ^%W(17.6001,922,1)="api2/cqcarchive"
 set ^%W(17.6001,922,2)="ARCHIVE^CQC"
 QUIT
 
ADDCONFIG ; redundant
 S A=""
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .W !,A
 .S ^CQC(A,"CONFIG")="subscriber_test"
 .QUIT
 QUIT
 
DISCO ; GET DISCOVERY UPRNs
 S (A,I)=""
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .S J=""
 .F  S I=$O(^CQC(A,I)) Q:I=""  DO
 ..S J=J_^(I)
 ..QUIT
 .K b D DECODE^VPRJSON($name(J),$name(b),$name(err))
 .S ADR=$get(b("address",1,"text"))
 .K ^TPARAMS($J)
 .S ^TPARAMS($J,"commercials")=1
 .D GETUPRN^UPRNMGR(ADR,"","","",0,0)
 .K b
 .D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 .W !,$get(b("UPRN"))
 .S UPRN=$get(b("UPRN"))
 .I UPRN'="" S ^CQC(A,"DISCO-UPRN")=UPRN
 .; insert in ^cqcaudit2
 .set id=^CQC(A,"SUB")
 .set config=^CQC(A,"CONFIG")
 .;D ZINSERT(UPRN,id,config)
 .QUIT
 QUIT
 
A ;
 S A=""
 F  S A=$O(^CQC(A)) Q:A=""  DO
 .I A=10152888 QUIT
 .S UPRN=$GET(^CQC(A,"DISCO-UPRN"))
 .I UPRN="" QUIT
 .S CONFIG=^CQC(A,"CONFIG")
 .S ID=^CQC(A,"SUB")
 .W !,UPRN,"*",CONFIG,"*",ID
 .D ZINSERT(UPRN,ID,CONFIG)
 .QUIT
 QUIT
 
ZINSERT(UPRN,id,config) 
 S sql="insert into audit_additional2 (id, subconfig, date, propertyid, valueid, value, name) values (:id, :subconfig, :date, :prop, :valueid, :value, :name)"
 ;
 S d=$$HD^STDDATE($h),%TM=$P($h,",",2)
 S zd=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
 DO %CTS^%H
 S zdate=zd_" "_%TIM
 S prop="Z1",valueid="Z1",value=UPRN,name="discovery_uprn"
 K %zi,%zo
 S %zi("id")=id,%zi("prop")=prop
 S %zi("valueid")=valueid,%zi("value")=value
 S %zi("name")=name,%zi("date")=zdate
 S %zi("subconfig")=config
 S ok=$$exec^%mgsql("",sql,.%zi,.%zo)
 ;
 QUIT
 
ARCHIVE(arguments,body,result) 
 K ^TMP($J)
 ;M ^CQC=body
 S ID=$$ID()
 S subid=$get(arguments("subscriber_id"))
 S config=$get(arguments("config"))
 S:subid'="" ^SUB(subid)=""
 S (i,json)=""
 f  s i=$o(body(i)) q:i=""  S ^CQC(ID,i)=body(i)
 ;S ^CQC(ID)=json
 S ^CQC(ID,"H")=$H
 S ^CQC(ID,"SUB")=subid
 S ^CQC(ID,"CONFIG")=config
 S:config'="" ^ICONFIG("SUB-CONFIG",config)=""
 set result("mime")="text/html"
 S ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result=$na(^TMP($J))
 QUIT 1
