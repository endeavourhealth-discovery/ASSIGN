NCMP2 ; ; 1/27/23 10:29am
 quit
 
WRITE ;
 new personid,nor,d
 set (personid,nor)=""
 set d=$c(9)
 set f="/tmp/ncmp_2_1.txt"
 close f
 o f:(newversion)
 use f
 W "person_id",d,"patient_id",d,"dom",d,"age",d,"gender",d,"ethnic_code",d,"ethnic_term",d,"lsoa",d,"msoa",d,"uprn",d,"outside_adr_dates",d,"invalid_class_prop",d,"not_best",d,"no_assign",d,"not_registered",!
 f  s personid=$o(^NCMP2(personid)) q:personid=""  do
 .f  s nor=$o(^NCMP2(personid,nor)) q:nor=""  do
 ..s rec=^(nor)
 ..s dom=^NCMPL(personid,nor)
 ..s dom=$p(dom,"/",3)_"-"_$p(dom,"/",2)_"-"_$p(dom,"/",1)
 ..S why=$P($get(^NCMP2(personid,nor,"w")),"|")
 ..set reason=""
 ..;I why'="" w !,"[",why,"]" r *y
 ..S uprn=""
 ..i why="" s uprn=$p(rec,"~",3)
 ..f i=1:1:$length(why,"~") do
 ...s $p(reason,d,$P(why,"~",i))="Y"
 ...quit
 ..;i reason'="",reason'="~~~~Y" w !,why,!,reason r *y
 ..s dob=$get(^ASUM(nor,"dob"))
 ..s gender=$get(^ASUM(nor,"g"))
 ..s age=""
 ..s:dob'="" age=$$AGEAT(dom,dob) ; age=$$AGE^HH(dob)
 ..;u 0 w !,"DOM: ",dom," DOB:",dob," ",age r *y
 ..use f
 ..s imd=$p(rec,"|",3)
 ..s lsoa=$p(imd,"~",1)
 ..s msoa=$p(imd,"~",2)
 ..s ethnic=$get(^ASUM(nor,"ethnic"))
 ..S rec=$get(^ethnic(ethnic))
 ..i rec'="" do
 ...s ceg16code=$p(rec,"~",1)
 ...s ceg16term=$p(rec,"~",2)
 ...s nhs5code=$p(rec,"~",3)
 ...s nhs5term=$p(rec,"~",4)
 ...quit
 ..w personid,d,nor,d,dom,d,age,d,gender,d,ceg16code,d,ceg16term,d,lsoa,d,msoa,d,uprn,d,reason,!
 ..quit
 close f
 quit
 
XR ;
 new nor
 kill ^XR
 S nor=""
 f  s nor=$o(^ASUM(nor)) q:nor=""  do
 .s person=^ASUM(nor)
 .s ^XR(person,nor)=$get(^ASUM(nor,"dob"))
 .quit
 quit
 
CHK s (person,nor)="",T=0
 f  s person=$o(^XR(person)) q:person=""  do
 .k peeps
 .f  s nor=$o(^XR(person,nor)) q:nor=""  do
 ..s dob=^(nor)
 ..s peeps(dob)=person
 .s cnt=0
 .s dob=""
 .f  s dob=$o(peeps(dob)) q:dob=""  do
 ..s cnt=cnt+1
 .i cnt>1 w ! zwr peeps w ! S T=T+1
 quit
 
STT ;
 new f,person,nor,dom
 k ^NCMP2,^NCMPL
 set f="/tmp/dom.txt"
 close f
 o f:(readonly)
 s c=1
 f  u f r str q:$zeof  do
 .s person=$p(str,$c(9),1)
 .;s nor=$p(str,$c(9),2)
 .s dom=$TR($p(str,$c(9),3),$C(13),"")
 .D RUN(person,dom,c)
 .s c=$i(c)
 .;s dob=$get(^ASUM(nor,"dob"))
 .;use 0
 .;i dob="" w !,nor r *y
 .;w !,nor," ",$$AGE^HH(dob) r *y
 .quit
 close f
 quit
 
RUN(person,dom,c) 
 n nor
 s nor=""
 use 0
 
 if c#1000=0 w !,c
 
 f  s nor=$order(^XR(person,nor)) q:nor=""  do
 .;i c#10000=0 w !,c
 .;
 .s dob=^(nor)
 .;w !,person," ",nor," ",$$AGE^HH(dob)," ",dom r *y
 .set ret=$$PLACEATEVT^FX2(nor,dom,1,0)
 .s why=""
 .I $L(ret,"~")=3!(ret="") S why=$$WHY^POPEXT(),^NCMP2(person,nor,"w")=why_"|"_dom
 .S ^NCMP2(person,nor)=ret
 .S ^NCMPL(person,nor)=dom
 .;S ^NCMP2(person,nor,"w")=why_"|"_dom
 .quit
 quit
 
AGEAT(eventdate,dob) ; 
 use 0
 S eventdate=$P(eventdate,"-",3)_"."_$P(eventdate,"-",2)_"."_$P(eventdate,"-")
 S TDAY=$$DA^STDDATE(eventdate)
 S TDOB=$P(dob,"-",3)_"."_$P(dob,"-",2)_"."_$P(dob,"-")
 S JN=$$DA^STDDATE(TDOB)
 S DA2=$A($E(TDAY,5)),MO2=$A($E(TDAY,4)),YEC2=($A($E(TDAY,1))-33)_($A($E(TDAY,2))-33)_($A($E(TDAY,3))-33)
 S DA1=$A($E(JN,5)),MO1=$A($E(JN,4)),YEC1=($A($E(JN,1))-33)_($A($E(JN,2))-33)_($A($E(JN,3))-33)
 S YEARS=YEC2-YEC1
 I MO2>MO1 Q YEARS
 I MO2<MO1 S YEARS=YEARS-1 Q YEARS
 I DA2>DA1 Q YEARS
 I DA2<DA1 S YEARS=YEARS-1 Q YEARS
 quit YEARS
