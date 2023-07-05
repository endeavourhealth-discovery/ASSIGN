UPRNUI3 ; ; 1/24/23 3:04pm
 ;
 quit
 
W ;
 S ^%W(17.6001,"B","GET","api2/download3","DOWNLOAD^UPRNUI3",22113)=""
 S ^%W(17.6001,22113,"AUTH")=2
 quit
 
DOWNLOAD(result,arguments) 
 new zid,c,i,hdr,d
 k ^TMP($J)
 
 set file=$get(arguments("filename"))
 set user=$get(arguments("userid"))
 
 i $g(un)'="" s user=un
 
 set d=$char(9)
 
 s hdr="id"_d_"uprn"_d_"address_fmt"_d_"algorithm"_d_"classification"_d
 s hdr=hdr_"match_building"_d_"match_flat"_d_"match_number"_d_"match_postcode"_d
 s hdr=hdr_"match_street"_d_"abp_number"_d_"abp_postcode"_d_"abp_street"_d
 s hdr=hdr_"abp_town"_d_"qualifier"_d_"adr_candiddate"_d_"abp_building"_d
 s hdr=hdr_"latitude"_d_"longitude"_d_"point"_d_"x"_d_"y"_d_"ralf"_d_"classification_term"_$c(10)
 
 I file'["/opt/" S file="/opt/files/"_file
 set ^TMP($J,1)=hdr
 s zid="",c=2
 f  s zid=$order(^TSV(user,file,zid)) q:zid=""  do
 .s ^TMP($job,c)=^(zid)_$char(10)
 .s c=$i(c)
 .quit
 set result("mime")="text/plain, */*"
 set result=$NA(^TMP($J))
 
 S i=$O(^ACTIVITY(user,""),-1)+1
 S ^ACTIVITY(user,i)=$H_"~"_file_" downloaded~"
 quit
 
TRANSFER(user,file) ; test ^TSV stuff
 ; new zid,json,error
 ; new B,last
 KILL ^TSV(user,file)
 set zid=""
 set last=$o(^NGX(user,file,""),-1)
 f  s zid=$o(^NGX(user,file,zid)) q:zid=""  do
 .s json=^(zid)
 .set:zid'=last json=$extract(json,1,$l(json)-1)
 .kill B
 .D DECODE^VPRJSON($name(json),$name(B),$name(error))
 .;w !
 .;zwr b
 .;w !
 .;r *y
 .set UPRN=B("UPRN"),ADDFMT=B("add_format"),ALG=B("alg"),CLASS=B("class"),MATCHB=B("match_build"),MATCHF=B("match_flat")
 .S MATCHN=B("match_number"),MATCHP=B("match_postcode"),MATCHS=B("match_street"),ABPN=B("abp_number"),ABPP=B("abp_postcode")
 .S ABPS=B("abp_street"),ABPT=B("abp_town"),QUAL=B("qualifier"),ABPB=B("abp_building")
 .S CAND=B("add_candidate"),CTERM=B("class_term")
 .D ROW^UPRNUI3(user,file,zid,UPRN,ADDFMT,ALG,CLASS,MATCHB,MATCHF,MATCHN,MATCHP,MATCHS,ABPN,ABPP,ABPS,ABPT,QUAL,CAND,ABPB,CTERM)
 .quit
 quit
 
 ; download the output as a file
ROW(user,file,zid,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q) 
 ; a=uprn,b=addformat,c=alg,d=class,e=matchb,f=matchf,g=matchn
 ; h=matchp,i=matchs,j=abpn,k=abpp,l=abps,m=abpt,n=qual
 ; o=adrec,p=abpb,q=cterm
 new row
 kill row
 set row(1)=a,row(2)=b,row(3)=c,row(4)=d,row(5)=e,row(6)=f
 set row(7)=g,row(8)=h,row(9)=i,row(10)=j,row(11)=k,row(12)=l
 set row(13)=m,row(14)=n,row(15)=o,row(16)=p,row(17)=q
 D STT(user,file,zid,.row)
 quit
 
STT(user,file,zid,row) ;
 new uprn,addformat,alg,class,matchb,matchf,matchn,matchp,matchs
 new abpn,abpp,abpt,qual,adr,abpb,cterm,d,rec,ralf
 new coord,lat,long,point,x,y
 set d=$char(9)
 
 set uprn=row(1),addformat=row(2),alg=row(3),class=row(4)
 set matchb=row(5),matchf=row(6),matchn=row(7),matchp=row(8)
 set matchs=row(9),abpn=row(10),abpp=row(11),abps=row(12),abpt=row(13)
 set qual=row(14),adr=row(15),abpb=row(16),cterm=row(17)
 set ralf=$get(^TRALFS($job,uprn))
 set (lat,long,point,x,y)=""
 if uprn'="" do
 .set coord=$piece($get(^UPRN("U",uprn)),"~",7)
 .set lat=$piece(coord,",",3),long=$piece(coord,",",4)
 .set point=$piece(coord,",",3),x=$piece(coord,",",1),y=$piece(coord,",",2)
 .quit
 set rec=zid_d_uprn_d_addformat_d_alg_d_class_d_matchb_d_matchf_d
 set rec=rec_matchn_d_matchp_d_matchs_d_abpn_d_abpp_d_abps_d_abpt_d_qual_d
 set rec=rec_adr_d_abpb_d_lat_d_long_d_point_d_x_d_y_d_ralf_d_cterm
 set ^TSV(user,file,zid)=rec
 quit
