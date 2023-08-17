UPRNONS ;NEW PROGRAM [ 06/12/2020  10:45 AM ]
 s matched=0,total=0,onsnull=0,dnull=0,unmatched=0
 s d=$c(9)
 s count=0
 O 52:("C:\msm\shared\results\mismatch.txt":"W")
 u 52 w "disc address"_d_"disc uprn"_d_"disc abp match"_d_"disc status"
 w d_"ons uprn"_d_"ons match"_d_"ons status",!
 f import=1:1:4 d import(import)
 u 0
 w !,"Total : "_total
 w !,"matched : "_matched
 w !,"unmatched : "_unmatched
 w !,"Null ons : "_onsnull
 w !,"Null discovery : "_dnull
 q
import(import)     ;
 i count>1000000 q
 O 51:("C:\msm\shared\results\ons"_import_".txt")
 i import=1 u 51 r rec
 for  u 51 r rec q:rec=""  d  q:(count>1000000)
 .s count=count+1
 .s ons=$p(rec,d,4)
 .s adno=$p(rec,d,8)
 .;s duprn=$p(rec,d,6)
 .s duprn=$O(^UPRNI("M",adno,""))
 .s onsadr=$P(rec,d,3)
 .s total=total+1
 .i ons=duprn s matched=matched+1 q
 .i ons="" s onsnull=onsnull+1 q
 .i duprn="" s dnull=dnull+1 q
 .s unmatched=unmatched+1
 .s dad=^UPRNI("D",adno)
 .D mismatch(rec,adno,ons,duprn,onsadr)
 c 51
 q
 q
mismatch(rec,adno,ons,duprn,onsadr) 
 ;
 n d
 s d=$c(9)
 ;u 0
 ;W !!
 s dstatus=$P(^UPRN("U",duprn),"~",3)
 u 52 w $tr(^UPRNI("D",adno),"~"," ")_d_duprn
 ;w !,"Discovery  : "_^UPRNI("D",adno)
 ;w !,"ONS        : "_onsadr
 s type=$O(^UPRN("U",duprn,"")) q:type=""  d
 s key=$O(^UPRN("U",duprn,type,"")) q:key=""  d
 s dadr=^(key)
 u 52 W d_$tr(dadr,"~"," ")
 u 52 w d_dstatus
 s type=$O(^UPRN("U",ons,"")) q:type=""  d
 s key=$O(^UPRN("U",ons,type,""))
 s oadr=^UPRN("U",ons,type,key)
 i $p(oadr,"~",$l(oadr,"~"))?1l d
 .s oadr=$p(oadr,"~",1,$l(oadr,"~")-1)
 u 52 w d,ons
 u 52 w d_$tr(oadr,"~"," ")
 s ostatus=$P(^UPRN("U",ons),"~",3)
 u 52 w d,ostatus,!
 ;s ^ADNO=adno
 ;D ONE^UPRN
 ;R T
 q
