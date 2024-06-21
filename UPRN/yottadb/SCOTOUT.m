SCOTOUT ; ; 4/18/24 10:41am
 quit
 
MATCH ; matches.
 S f="/tmp/scot_match.txt"
 close f
 o f:(newversion)
 use f
 set (q,sno)=""
 s d=$c(9)
 w "serial_number",d,"$TR_address",d,"$_address",d,"uprn",d,"algorithm",d,"qualifier",d,"match_pattern_building",d
 w "match_pattern_flat",d,"match_pattern_number",d
 w "match_pattern_postcode",d,"match_pattern_street",d
 w "class_code",d,"class_term",!
 f  s q=$o(^OUT(q)) q:q=""  do
 .f  s sno=$o(^OUT(q,sno)) q:sno=""  do
 ..s rec=^OUT(q,sno,1)
 ..;i rec["residential" quit
 ..set uprn=$p(rec,"~",21)
 ..i uprn="" quit
 ..set alg=$p(rec,"~",7)
 ..set qualifier=$p(rec,"~",8)
 ..set matpatbuild=$p(rec,"~",9)
 ..set matpatflat=$piece(rec,"~",10)
 ..set matpatnumber=$p(rec,"~",11)
 ..set matpatpostcode=$p(rec,"~",12)
 ..set matpatstreet=$p(rec,"~",13)
 ..set class=$p(rec,"~",20) 
 ..set uprn=$p(rec,"~",21)
 ..set address=^Q(q,sno)
 ..set abp=^OUT(q,sno,2)
 ..;w !,address
 ..;w !,rec
 ..;w !,abp
 ..;w ! r *y
 ..s naddress=$$TR^LIB(address,"$",",")
 ..set out=sno_d_naddress_d_address_d_uprn_d_alg_d_qualifier_d_matpatbuild_d_matpatflat_d
 ..set out=out_matpatnumber_d_matpatpostcode_d_matpatstreet_d_class_d
 ..set out=out_$get(^UPRN("CLASSIFICATION",class,"term"))
 ..write out,!
 ..quit
 .quit
 close f
 quit
 
NOMATCH ;
 set f="/tmp/scot_nomatch.txt"
 close f
 o f:(newversion)
 use f
 s (q,sno)=""
 s d=$c(9)
 write "serial_number",d,"$TR_address",d,"$_address",d,"address_quality",!
 f  s q=$o(^OUT(q)) q:q=""  do
 .f  s sno=$o(^OUT(q,sno)) q:sno=""  do
 ..set rec=^OUT(q,sno,1)
 ..set quality1=$get(^UQUAL(q,sno,"POSTCODE"))
 ..set quality2=$get(^UQUAL(q,sno,"INVALID"))
 ..;if quality1'=""!(quality2'="") quit
 ..set uprn=$p(rec,"~",21)
 ..i uprn'="" quit
 ..set address=^Q(q,sno)
 ..set out=sno_d_$$TR^LIB(address,"$",",")_d_address_d_quality1_$select(quality2'="":" and ",1:"")_quality2
 ..;w !,sno,d,$$TR^LIB(address,"$",","),d,address,d,quality1,$S(quality2'="":" and ",1:"")_quality2
 ..w out,!
 ..quit
 .quit
 close f
 quit
 
INVALID ;
 quit

SERIAL ;
 K ^XOUT
 set (q,sno)=""
 f  s q=$o(^OUT(q)) q:q=""  do
 .f  s sno=$o(^OUT(q,sno)) q:sno=""  do
 ..s ^XOUT(sno,q)=""
 ..quit
 quit
 
OUTPUT ;
 new rec,out
 k ^R
 do SERIAL
 S f="/tmp/scot-output.txt"
 close f
 o f:(newversion)
 use f
 set (q,sno)="",d=$c(9)
 write "serial_number",d,"uprn",d,"abp_address",d,"class_code",d,"matching_quality",d,"address_quality",!
 ;f  s q=$o(^OUT(q)) q:q=""  do
 ;.f  s sno=$o(^OUT(q,sno)) q:sno=""  do
 f  S sno=$o(^XOUT(sno)) q:sno=""  do
 .f  s q=$o(^XOUT(sno,q)) q:q=""  do
 ..set rec=^OUT(q,sno,1)
 ..set abp=^OUT(q,sno,2)
 ..set abp=$$TR^LIB(abp,"~",",")
 ..set class=$p(rec,"~",20)
 ..set uprn=$p(rec,"~",21)
 ..set quality1=$get(^UQUAL(q,sno,"POSTCODE"))
 ..set quality2=$get(^UQUAL(q,sno,"INVALID"))
 ..;set qmatch=$piece(rec,"~",7) ; algorithm?
 ..;set qmatch=$p(rec,"~",8) ; qualifier
 ..set qmatch=$$MQUAL(rec)
 ..set out=sno_d_uprn_d_abp_d_class_d_qmatch_d_quality1_$s(quality1'=""&(quality2'=""):" and ",1:"")_quality2
 ..set r=quality1_$s(quality1'=""&(quality2'=""):" and ",1:"")_quality2
 ..s:'$d(^R(r)) ^R(r)=""
 ..;write sno,d,abp,d,class,d,qmatch,d,quality1,quality2,!
 ..write out,!
 ..quit
 close f
 quit
 
MQUAL(rec) ; matching quality
 new out,i
 set out=""
 f i=9:1:13 do
 .s prefix="building"
 .if i=10 set prefix="flat"
 .if i=11 set prefix="number"
 .if i=12 set prefix="postcode"
 .if i=13 set prefix="street"
 .if $p(rec,"~",i)'="",$p(rec,"~",i)'="equivalent" s out=out_$p(rec,"~",i)_"("_prefix_"),"
 .quit
 set out=$p(out,",",$l(out,",")-1)
 set out=$p(rec,"~",7)_$s(out'="":":"_out,1:"")
 quit out

STATS ;
 ;new i,match,tot
 kill tot
 S totq=$o(^OUT(""),-1)
 set match=0
 set nomatch=0
 set tot=0
 set invalid=0
 for i=1:1:totq do
 .set id=""
 .W !,"queue: ",i
 .set match=0
 .set nomatch=0
 .set tot=0
 .set invalid=0
 .f  s id=$o(^OUT(i,id)) q:id=""   do
 ..s rec=^OUT(i,id,1)
 ..s uprn=$piece(rec,"~",21)
 ..;w !,uprn r *Y
 ..i uprn'="" s match=match+1
 ..;i uprn="" s nomatch=nomatch+1
 ..I $data(^UQUAL(i,id,"POSTCODE")) s invalid=invalid+1
 ..I $data(^UQUAL(i,id,"INVALID")) s invalid=invalid+1
 ..set tot=tot+1
 ..quit
 .set tot(i)=match_"~"_tot_"~"_invalid
 .quit
 
 set i="",gtot=0,gmatch=0,ginvalid=0
 f  s i=$o(tot(i)) q:i=""  do
 .set rec=tot(i)
 .set match=$p(rec,"~",1),tot=$p(rec,"~",2)
 .set invalid=$p(rec,"~",3)
 .set gtot=gtot+tot,gmatch=gmatch+match
 .set ginvalid=ginvalid+invalid
 .w:tot>0 !,i," ",$j((match/tot)*100,0,2)
 .quit
 w !,"overall: ",$j((gmatch/gtot)*100,0,2)," total processed:",gtot," matches: ",gmatch
 w !,"%invalid: ",$j((ginvalid/gtot)*100,0,2)," invalid: ",ginvalid
 quit
