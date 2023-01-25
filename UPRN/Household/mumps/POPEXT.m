POPEXT ; ; 1/25/23 10:03am
 ; Population extract for a fixed index date
 quit
 
 ; D STT^POPEXT("2021-03-21")
 ;
STT(eventdate) 
 ; get ethnicity data from observation table
 D sql(eventdate)
 
 W !,"calling SQL"
 
 s sql="SELECT p.id FROM compass_gp.dbo.patient p "
 s sql=sql_"join compass_gp.dbo.episode_of_care e on e.patient_id = p.id "
 s sql=sql_"join db_lookup.im.concept c on c.dbid = e.registration_type_concept_id "
 
 ;s sql=sql_"where c.code = 'R' and e.date_registered <= GetDate() and (e.date_registered_end >= '"_eventdate_"' or e.date_registered_end IS NULL)"
 
 s sql=sql_"where c.code = 'R' and e.date_registered <= '"_eventdate_"' and (e.date_registered_end > '"_eventdate_"' or e.date_registered_end IS NULL)"
 
 ;
 
 D RUN(sql)
 W !,"finished calling SQL"
 
 K ^TZ,^nope,^F
 
 ; run each of the patient through the algorithm
REENT s f="/tmp/uprnrtns/pop_ext.txt"
 
 s fileno=1
 s f2="/tmp/uprnrtns/pop_ext_out_"_fileno_".txt"
 S ^F(0)=f2
 
 close f,f2
 o f:(readonly)
 o f2:(newversion)
 u f r str,str
 s c=1,d=$c(9)
 
 set hdr="person_id"_d_"patient_id"_d_"date_of_birth"_d_"Gender"_d
 set hdr=hdr_"date_of_death"_d_"ethnic_code_nhs5"_d
 set hdr=hdr_"ethnic_term_nhs5"_d_"ethnic_code_ceg16"_d_"ethnic_term16"_d
 set hdr=hdr_"uprn"_d_"uprn_classification"_d_"uprn_qualifier"_d
 set hdr=hdr_"lsoa_code_2011"_d_"msoa_code_2011"_d_"practice_code"_d
 set hdr=hdr_"practice_name"_d_"CCG_code"_d_"CCG_name"_d
 set hdr=hdr_"obs_ethnic_code_nhs5"_d_"obs_ethnic_term_nhs5"_d_"obs_ethnic_code_ceg16"_d_"obs_ethnic_term16"
 
 u f2 w hdr,!
 
 s (pat,obs)=0
 f  u f r nor q:$zeof!(nor="")  do
 .;u 0 w !,"[",nor,"]" r *y
 .S data=$$PLACEATEVT^FX2(nor,eventdate,0,1)
 .;u 0 w ! r *y
 .i c#1000=0 u 0 w !,c
 .i c#500000=0 do
 ..set fileno=fileno+1
 ..close f2
 ..s f2="/tmp/uprnrtns/pop_ext_out_"_fileno_".txt"
 ..S z=$increment(^F)
 ..S ^F(z)=f2
 ..open f2:(newversion)
 ..u f2 w hdr,!
 ..quit
 .s c=c+1
 .s person=$G(^ASUM(nor))
 .i person="" U 0 w !,nor,"?" S ^TZ(nor)="" d topup^REFRESH(nor)
 .s dob=^ASUM(nor,"dob")
 .s gender=^ASUM(nor,"g")
 .;
 .s dod=$get(^ASUM(nor,"dod"))
 .s ethnic=$get(^ASUM(nor,"ethnic"))
 .s uprn=$p(data,"~",3)
 .if uprn="" set ^nope(nor)=""
 .s propclass=$p(data,"~",6)
 .s qualifier=$p(data,"~",11)
 .s rec=$p(data,"|",3)
 .s lsoa=$p(rec,"~",1)
 .s msoa=$p(rec,"~",2)
 .s org=^ASUM(nor,"o")
 .s rec=^ORG(org)
 .s odscode=$p(rec,"~",1)
 .s name=$p(rec,"~",2)
 .s name=""
 .s parent=$p(rec,"~",3)
 .s rec=$get(^ORG(parent))
 .s (ccgods,ccgname)=""
 .i rec'="" do
 ..s ccgods=$p(rec,"~",1)
 ..s ccgname=$p(rec,"~",2)
 ..s ccgname=""
 ..quit
 .s (nhs5code,nhs5term,ceg16code,ceg16term)=""
 .S rec=$get(^ethnic(ethnic))
 .;u 0 w !,rec r *y
 .i rec'="" do
 ..s pat=pat+1
 ..s ceg16code=$p(rec,"~",1)
 ..;s ceg16term=$p(rec,"~",2)
 ..s nhs5code=$p(rec,"~",3)
 ..;s nhs5term=$p(rec,"~",4)
 ..quit
 .S (obs5code,obs5term,obs16code,obs16term)=""
 .S rec=$get(^ETHOBS(nor))
 .if rec'="" do
 ..s obs=obs+1
 ..s obs5code=$piece(rec,"~",2)
 ..; set obs5term=^ZD(5,obs5code)
 ..s obs16code=$p(rec,"~",1)
 ..; set obs16term=^ZD(16,obs16code)
 ..quit
 .use f2
 .w person,d,nor,d,dob,d,gender,d,dod,d,nhs5code,d,nhs5term,d,ceg16code,d,ceg16term,d,uprn,d,propclass,d,qualifier,d,lsoa,d,msoa,d
 .w odscode,d,name,d,ccgods,d,ccgname,d
 .w obs5code,d,obs5term,d,obs16code,d,obs16term,!
 .;r *y
 .quit
 close f,f2
 quit
 
 ; do sql^POPEXT("2021-03-21")
sql(eventdate) ;
 s f="/tmp/popext.sql"
 c f
 o f:(newversion)
 u f w "SET NOCOUNT ON;",!!
 u f w "DROP TABLE IF EXISTS #tPOP",!
 u f w "SELECT p.id as p_id, o.id as o_id, o.clinical_effective_date, em.CEG_16, em.NHS_5",!
 u f w "INTO #tPOP",!
 u f w "FROM compass_gp.dbo.patient p",!
 u f w "join compass_gp.dbo.episode_of_care e on e.patient_id = p.id",!
 u f w "join db_lookup.im.concept c on c.dbid = e.registration_type_concept_id",!
 u f w "join compass_gp.dbo.observation o on o.patient_id = p.id",!
 u f w "join db_lookup.dbo.lu_ethnicity_map em on em.legacy = o.non_core_concept_id",!
 u f w "join db_lookup.im.concept c1 on c1.dbid = o.non_core_concept_id",!!
 
 ;u f w "where c.code = 'R' and e.date_registered <= GetDate() and (e.date_registered_end >= '"_eventdate_"' or e.date_registered_end IS NULL)",!!
 
 use f w "where c.code = 'R' and e.date_registered <= '"_eventdate_"' and (e.date_registered_end > '"_eventdate_"' or e.date_registered_end IS NULL)",!!
 
 u f w "CREATE CLUSTERED INDEX cx_tPOP",!
 u f w "ON #tPOP (o_id, clinical_effective_date);",!!
 u f w "SELECT *",!
 u f w "FROM (",!
 u f w "   SELECT *,",!
 u f w "     ROW_NUMBER() OVER (PARTITION BY p_id ORDER BY o_id DESC, clinical_effective_date DESC) AS rn",!
 u f w "   FROM #tPOP",!
 u f w "   ) as t",!
 u f w "WHERE rn = 1"
 close f
 
 S H=^ICONFIG("MSSQL","HOST")
 S U=^ICONFIG("MSSQL","USER")
 S P=^ICONFIG("MSSQL","PASS")
 
 w !,"running sql"
 set x="/opt/mssql-tools/bin/sqlcmd -S "_H_" -U '"_U_"' -P '"_P_"' -h-1 -W -s""~"" -i /tmp/popext.sql -o /tmp/uprnrtns/popext.txt"
 w !,x
 zsystem x
 w !,"finished running sql"
 
 kill ^ETHOBS
 s f="/tmp/uprnrtns/popext.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .s nor=$p(str,"~",1)
 .s ^ETHOBS(nor)=$piece(str,"~",4,5)
 .quit
 close f
 quit
 
nope(eventdate) ;
 new a,d,x,bits
 s a="",d=$c(9)
 kill q
 s f="/tmp/uprnrtns/nope.txt"
 close f
 o f:(newversion)
 use f
 s hdr="person_id"_$c(9)_"patient_id"_$c(9)_"outside_dates"_d_"invalid_class"_d_"not best"_d_"no assign"_d_"no address records"
 w hdr,!
 f  s a=$o(^nope(a)) q:a=""  do
 .;w !,"http://192.168.4.159:9080/api/hh?patient_id=",a,"&event_date=%222021-03-21%22"
 .S data=$$PLACEATEVT^FX2(a,eventdate,1,1)
 .;W !,"[",data,"]"
 .;zwr ^TLOG($J,*)
 .;W !
 .set x=$$WHY()
 .I x="" s q(5)=$get(q(5))+1 ; no address record in system
 .s bits="0"_$c(9)_"0"_$c(9)_"0"_$c(9)_"0"_$c(9)_0
 .i x="" s $p(bits,$c(9),5)=1
 .F i=1:1:$l(x,"~") do
 ..s q=$p(x,"~",i)
 ..s $p(bits,$c(9),i)=1
 ..;i q=1 w !,"one or more addresses not in date range"
 ..;i q=2 w !,"invalid class prop"
 ..;i q=3 w !,"*not* best residential match"
 ..;i q=4 w !,"patient does not have an assign record"
 ..s q(q)=$get(q(q))+1
 ..quit
 .S personid=^ASUM(a)
 .w personid,d,a,d,bits,!
 .quit
 ;w !
 ;zwr q
 close f
 quit
 
WHY() ;
 n l,str,r
 s l=""
 s r=""
 F  S l=$o(^TLOG($j,l)) q:l=""  do
 .s str=^(l)
 .i str["skipping",r'["1~" s r=r_"1~"
 .i str["class prop?",str["false",r'["2~" s r=r_"2~"
 .i r'["3~",str["Best (residential) match?",str["false" s r=r_"3~"
 .i r'["4~",str["ASSIGN" S r=r_"4~"
 .i str["not registered",r'["5~" s r=r_"5~"
 .i str["temp address",r'["6~" s r=r_"6~"
 .quit
 quit $e(r,1,$l(r)-1)
 
RUN(sql) ;
 S H=^ICONFIG("MSSQL","HOST")
 S U=^ICONFIG("MSSQL","USER")
 S P=^ICONFIG("MSSQL","PASS")
 
 set sql=""""_sql_""""
 
 S CMD="/opt/mssql-tools/bin/sqlcmd -W -S "_H_" -U '"_U_"' -P '"_P_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/pop_ext.txt"
 zsystem CMD
 i $zsystem'=0 w !,"something went wrong" r *y
 quit
 
PEEPS ;
 K ^X
 s f="/tmp/uprnrtns/pop_ext.txt"
 c f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .;u 0 w !,str
 .S P=$GET(^ASUM(str))
 .I P="" QUIT
 .S ^X(P,str)=""
 .quit
 close f
 
 S (p,n)=""
 f  s p=$o(^X(p)) q:p=""  do
 .s c=0
 .f  s n=$o(^X(p,n)) q:n=""  do
 ..S c=c+1
 .i c>1 m ^M(p)=^X(p) s ^M(p)=c
 quit
 
ORGS ;
 K ^TO
 s a=""
 f  s a=$o(^ASUM(a)) q:a=""  do
 .s o=^ASUM(a,"o")
 .I $GET(^ORG(o))="" quit
 .S rec=^ORG(o)
 .set parent=$p(rec,"~",3)
 .s ^TO(o)=^ORG(o)
 .;s ^TO(o,"P")=^ORG(parent)
 .S ^TO(parent)=^ORG(parent)
 .quit
 
WRITE s o="",d=$c(9)
 s f="/tmp/uprnrtns/orgs.txt"
 c f
 o f:(newversion)
 use f
 W "ods_code",d,"name",d,"parent",!
 f  s o=$o(^TO(o)) q:o=""  do
 .s rec=^TO(o)
 .s odscode=$p(rec,"~",1)
 .i odscode="NULL" quit
 .s name=$p(rec,"~",2)
 .s parent=$p(rec,"~",3)
 .s rec=$get(^TO(parent))
 .s parentods=$p(rec,"~",1)
 .use f w odscode,d,name,d,parentods,!
 .quit
 c f
 quit
 
COUNT ; count person
 K ^COUNT
 s f="/tmp/uprnrtns/pop_ext.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof!(str="")  do
 .;
 .s person=^ASUM(str)
 .S ^COUNT(person)=$g(^COUNT(person))+1
 .quit
 close f
 s a="",t=0 f  s a=$o(^COUNT(a)) q:a=""  s t=t+1
 w !,"total=",t
 quit
 
CHK ;
 n nor
 s nor="",zt=0,t=0
 f  s nor=$o(^ASUM(nor)) q:nor=""  do
 .s t=t+1
 .s ethnic1=$get(^ASUM(nor,"ethnic"))
 .s rec=$get(^ethnic(ethnic1))
 .W !,nor
 .s (acode16,acode5)=""
 .i rec'="" do
 ..set acode16=$p(rec,"~",1)
 ..set acode5=$p(rec,"~",3)
 ..quit
 .s rec=$get(^ETHOBS(nor))
 .;w !,rec
 .s (bcode16,bcode5)=""
 .if rec'="" do
 ..set bcode16=$p(rec,"~",1)
 ..s bcode5=$p(rec,"~",2)
 ..quit
 .;w !,rec
 .i bcode16="" s zt=$i(zt)
 .I acode16'=bcode16!(acode5'=bcode5) do
 ..w !,nor
 ..w !,"16: pat [",acode16,"] obs [",bcode16,"]"
 ..W !,"16: pat [",$$T(16,acode16),"] obs [",$$T(16,bcode16),"]"
 ..w !,"5: pat [",acode5,"] obs [",bcode5,"]"
 ..W !,"5: pat [",$$T(5,acode5),"] obs [",$$T(5,bcode5),"]"
 ..r *y
 ..quit
 .;
 .quit
 quit
 
T(a,code) q $get(^ZD(a,code))
