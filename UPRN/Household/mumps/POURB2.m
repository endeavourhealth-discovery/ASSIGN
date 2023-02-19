POURB2 ; ; 2/11/23 11:34am
 ;
 quit
 
RUN ;
 quit
 
TOPUP ;
 new max,select,str,sql,count,date,idx
 
 ;set ^S("POURB2",1)=$$HT^STDDATE($P($H,",",2))
 
 set max=$$MAX()
 
 set select="id,patient_address_id,uprn,uprn_property_classification,qualifier,match_rule,match_date"
 
 set sql="SELECT "_select_" FROM [compass_gp].[dbo].[patient_address_match] pm where pm.id > "_max
 W !,sql
 D RUN^DOWNLOAD(sql)
 
 if $$EOF^DOWNLOAD() set idx=$o(^audit("POURB2",+$h,""),-1)+1,^audit("POURB2",+$h,idx)=0 quit
 
 set ^S("POURB2",1)=$$HT^STDDATE($P($H,",",2))
 
 s f="/tmp/uprnrtns/download.txt"
 c f
 o f:(readonly)
 u f r str,str
 set count=0
 set date=+$Horolog
 
 ;k ^audit("POURB2",date)
 
 f  u f r str q:$zeof!(str="")  do
 .d set^REFRESH(str)
 .s count=$i(count)
 .;set ^audit("POURB2",date,count)=str
 .quit
 close f
 
 set ^S("POURB2",2)=$$HT^STDDATE($P($H,",",2))
 set idx=$o(^audit("POURB2",date,""),-1)+1
 set ^audit("POURB2",date,idx)=count
 quit
 
COUNT() ;
 new count,adrid,id
 s count=0
 s (adrid,id)=""
 f  s adrid=$o(^MATCH(adrid)) q:adrid=""  do
 .f  s id=$o(^MATCH(adrid,id)) q:id=""  do
 ..s count=count+1
 quit count
 
MAX() ;
 new adrid,id,max
 s (adrid,id)="",max=0
 f  s adrid=$o(^MATCH(adrid)) q:adrid=""  do
 .f  s id=$o(^MATCH(adrid,id)) q:id=""  do
 ..i id>max s max=id
 quit max
