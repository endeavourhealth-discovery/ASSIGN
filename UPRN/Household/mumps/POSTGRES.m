POSTGRES ; ; 2/3/23 5:59pm
 quit
 
STT ;
 new nor,dod,c,person,org
 s nor=""
 s dod=""
 s c=1
 
 set f="/tmp/asum.txt"
 o f:(newversion)
 
 set f2="/tmp/eoc.txt"
 o f2:(newversion)
 
 set f3="/tmp/adr.txt"
 o f3:(newversion)
 
 set f4="/tmp/match.txt"
 o f4:(newversion)
 
 s n="\N",d=$c(9)
 use f
 f  s nor=$o(^ASUM(nor)) q:nor=""  do  q:c>10000
 .s dod=$get(^ASUM(nor,"dod"))
 .s person=^ASUM(nor)
 .s org=^ASUM(nor,"o")
 .i dod="" s dod=n
 .;U 0 W !,dod
 .use f w nor,d,org,d,person,d,n,d,n,d,n,d,n,d,n,d,n,d,dod,d,n,d,n,d,n,d,n,d,n,d,n,!
 .D EOC(nor,f2)
 .D ADR(nor,f3)
 .D MATCH(nor,f4)
 .s c=c+1
 .quit
 c f,f2,f3,f4
 quit
 
MATCH(nor,f4) ;
 new id,n,d
 s n="\N",d=$c(9)
 s id="",adrid=""
 f  s adrid=$o(^ADR(nor,adrid)) q:adrid=""  do
 .f  s id=$o(^MATCH(adrid,id)) q:id=""  do
 ..s rec=^MATCH(adrid,id)
 ..s uprn=$p(rec,"~",1)
 ..s class=$p(rec,"~",4)
 ..s qual=$p(rec,"~",9)
 ..s rule=$p(rec,"~",10)
 ..s matchdate=$p(rec,"~",11)
 ..use f4 w id,d,adrid,d,uprn,d,n,d,n,d,class,d
 ..w n,d ; lat
 ..w n,d ; long
 ..w n,d ; x
 ..w n,d ; y
 ..w qual,d 
 ..w rule,d
 ..w matchdate,d
 ..w n,d ; abp_adr_no
 ..w n,d ; abp_street
 ..w n,d ; abp_local
 ..w n,d ; abp_town
 ..w n,d ; abp_postcode
 ..w n,d ; abp_org
 ..w n,d ; mp_post
 ..w n,d ; mp_street
 ..w n,d ; mp_number
 ..w n,d ; mp_building
 ..w n,d ; mp_flat
 ..w n,d ; version
 ..w n,! ; epoch
 ..quit
 .quit
 quit
 
ADR(nor,f3) ;
 new id,n,d
 s n="\N",d=$c(9)
 s id=""
 f  s id=$order(^ADR(nor,id)) q:id=""  do
 .s rec=^ADR(nor,id)
 .s start=$p(rec,"~",2)
 .s end=$p(rec,"~",3)
 .i start="" s start=n
 .i end="" s end=n
 .S org=$p(rec,"~",4)
 .S use=$p(rec,"~",5)
 .S personid=$p(rec,"~",1)
 .use f3 w id,d,org,d,nor,d,personid,d
 .w n,d ; add_1
 .w n,d ; add_2
 .w n,d ; add_3
 .w n,d ; add_4
 .w n,d ; city
 .w n,d ; postcode
 .w use,d ; use
 .w start,d
 .w end,d
 .w n,d ; lsoa
 .w n,d ; lsoa
 .w n,d ; msoa
 .w n,d ; msoa
 .w n,d ; ward
 .w n,! ; local_auth
 .quit
 quit
 
EOC(nor,f2) ;
 new id,rec,d,n
 set id=""
 set f2=$get(f2)
 if f2'="" use f2
 set d=$c(9),n="\N"
 f  s id=$o(^EOC(nor,id)) q:id=""  do
 .s rec=^(id)
 .s personid=$p(rec,"~",1)
 .s regtype=$p(rec,"~",2)
 .s datereg=$p(rec,"~",3)
 .s regend=$p(rec,"~",4)
 .s org=$p(rec,"~",5)
 .I regtype="NULL"!(regtype="") s regtype=n
 .I datereg="" s datereg=n
 .I regend="" s regend=n
 .s personid=^ASUM(nor)
 .w id,d,org,d,nor,d,personid,d,regtype,d,n,d,datereg,d,regend,d,n,!
 .quit
 quit
