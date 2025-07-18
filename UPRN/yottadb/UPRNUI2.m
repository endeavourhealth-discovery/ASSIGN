UPRNUI2 ; ; 7/18/25 11:19am
 set ^%W(17.6001,"B","POST","api/fileupload2","UPLOAD^UPRNUI2",565)=""
 set ^%W(17.6001,565,0)="POST"
 set ^%W(17.6001,565,1)="api/fileupload2"
 set ^%W(17.6001,565,2)="UPLOAD^UPRNUI2"
 set ^%W(17.6001,565,"AUTH")=1
 
 set ^%W(17.6001,"B","GET","api/filedownload2","DOWNLOAD^UPRNUI2",566)=""
 set ^%W(17.6001,566,0)="GET"
 set ^%W(17.6001,566,1)="api/filedownload2"
 set ^%W(17.6001,566,2)="DOWNLOAD^UPRNUI2"
 set ^%W(17.6001,566,"AUTH")=1
 
 set ^%W(17.6001,"B","GET","api/getreg","GETREG^UPRNUI2",568)=""
 set ^%W(17.6001,568,0)="GET"
 set ^%W(17.6001,568,1)="api/getreg"
 set ^%W(17.6001,568,2)="GETREG^UPRNUI2"
 set ^%W(17.6001,568,"AUTH")=1
 
 set ^%W(17.6001,"B","POST","api/register","REG^UPRNUI2",567)=""
 set ^%W(17.6001,567,0)="POST"
 set ^%W(17.6001,567,1)="api/register"
 set ^%W(17.6001,567,2)="REG^UPRNUI2"
 set ^%W(17.6001,567,"AUTH")=1
 quit
 
GETREG(result,arguments) 
 K ^TMP($J)
 S userid=$get(arguments("userid"))
 S ^TREG=userid
 S ^TMP($J,1)="{""name"": ""?"", ""organization"": ""?""}"
 S rec=$GET(^ZREG(userid))
 S dt=$P(rec,"~"),org=$P(rec,"~",2),name=$P(rec,"~",3)
 S epoch=$get(^ICONFIG("EPOCH"))
 S areas=$$ESC^VPRJSON($g(^ICONFIG("AREAS")))
 S admin=""
 I userid'="",$D(^ADMINS(userid)) S admin=1
 s saltdets=""
 i userid'="",$data(^SALTS("audit",userid)) do
 .S d=$o(^SALTS("audit",userid,""),-1)
 .S t=$o(^SALTS("audit",userid,d,""),-1)
 .S saltfile=^(t)
 .S saltdets="You uploaded "_saltfile_" on "_$$HD^STDDATE(d)_" at "_$$HT^STDDATE(t)
 .quit 
 i name'="" do
 .set d=$p(dt,","),t=$p(dt,",",2)
 .set d=$$HD^STDDATE(d),t=$$HT^STDDATE(t)
 .S ^TMP($J,1)="{""name"": """_name_""",""organization"": """_org_""",""regdate"": """_d_":"_t_""",""epoch"": """_epoch_""",""areas"": """_areas_""",""admin"": """_admin_""",""salt"": """_saltdets_"""}"
 .quit
 S result("mime")="text/plain, */*"
 S result=$NA(^TMP($J))
 QUIT
 
DOWNLOAD(result,arguments) 
 K ^TMP($J)
 set file=$get(arguments("filename"))
 set user=$get(arguments("userid"))
 
 i $g(un)'="" s user=un
 
 I file'["/opt/" S file="/opt/files/"_file
 s c=1,^TMP($J,c)="[",c=c+1,l="" f  s l=$order(^NGX(user,file,l)) q:l=""  S ^TMP($J,c)=^(l)_$C(13,10),c=c+1
 S z=$o(^TMP($J,""),-1)
 i z'="" s json=^TMP($J,z) i $e(json,$l(json)-2)="," s ^TMP($J,z)=$e(json,1,$l(json)-3)
 s ^TMP($J,c)="]"
 S result("mime")="text/plain, */*"
 S result=$NA(^TMP($J))
 S I=$O(^ACTIVITY(user,""),-1)+1
 S ^ACTIVITY(user,I)=$H_"~"_file_" downloaded~"
 QUIT
 
REG(arguments,body,result) 
 S b=$get(body(1))
 S userid=$P($P(b,"name=""userid"""_$C(13,10,13,10),2),$C(13,10))
 S org=$P($P(b,"name=""organisation"""_$C(13,10,13,10),2),$C(13,10))
 S name=$P($P(b,"name=""name"""_$C(13,10,13,10),2),$C(13,10))
 S ^ZREG(userid)=$H_"~"_org_"~"_name
 S ^TMP($J,1)="{""status"": ""OK""}"
 set result("mime")="text/html"
 S result=$NA(^TMP($J))
 QUIT 1
 
UPLOAD(arguments,body,result) 
 new file,line
 K ^TMP($J)
 ;M ^FILES=body
 
 S X=$O(body(""),-1)
 S ZZ=body(X)
 
 set result("mime")="text/html"
 
 set file=$piece(body(1),$c(10),2)
 set file=$piece(file,"""",4)
 
 S type=body(1)
 S type=$P($P(type,"Content-Type:",2),$C(13,10,13,10))
 ;python
 S type=$$LT^LIB(type)
 S ^TYPE=type
 i type'["text/plain",$$LC^LIB(file)'["encryptedsalt" do  quit 1
 .S ^TMP($J,1)="{""upload"": { ""status"": ""NOK""}}"
 .set result=$na(^TMP($J))
 .quit
 
 lock ^UPRNUI("process",file):1
 i '$t s ^UPRNUI("process",file)="Already being processed "_$h quit
 lock -^UPRNUI("process",file)
 do 6^ZOS("/opt/files")
 set file="/opt/files/"_file
 ;
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 
 set line=$order(body(""),-1)
 ;if line'="" set body(line)=$piece(body(line),"------WebKitFormBoundary",1)
 ;if line'="" set body(line)=$p(body(line),$C(13,10,13,10),1)
 
 ;open file:newversion
 O file:(newversion:stream:nowrap:chset="M")
 set line=""
 for  set line=$order(body(line)) q:line=""  do
 .use file write body(line)
 .quit
 close file
 
 if $$LC^LIB(file)["encryptedsalt" DO  Q 1
 .S USER=$P($P(ZZ,"name=""userid"""_$C(13,10,13,10),2),$C(13,10))
 .I USER="" s USER=un
 .S I=$O(^ACTIVITY(USER,""),-1)+1
 .S saltfile=$P(file,"/",$L(file,"/"))
 .S h=+$h,t=$p($h,",",2)
 .S ^SALTS("audit",USER,h,t)=saltfile
 .S ^ACTIVITY(USER,I)=$H_"~salt uploaded ("_saltfile_")"_"~"_file
 .D FIX^RALF(file,USER)
 .s ^TMP($J,1)="{""upload"": { ""status"": ""SALTOK""}}"
 .set result=$na(^TMP($J))
 .quit
  
 ;
 ; test that the file has tabs in it?
 ; validate the first 10 records
 open file:(readonly)
 s ok=1,qf=0,ZZ=""
 ;f i=1:1:10 use file r str q:$zeof  i $p(str,$c(9))'?1n.n s ok=0
 set error="",start=1
 for i=1:1 use file r str q:$zeof  do  quit:'ok!(qf)
 .I str=$C(13) use file r str
 .if start=1 set str=$$RemoveBOM(str,.error),start=0
 .if str["------WebKitFormBoundary" s qf=1
 .; python
 .if $e(str,$l(str)-3,$l(str))["--" s qf=1
 .; safari
 .if $E(str,1,28)="----------------------------" s qf=1
 .; curl
 .if $E(str,1,26)="--------------------------" s qf=1
 .if qf do  quit
 ..S ZZ=str
 ..f i=1:1 use file r str q:$zeof  S ZZ=ZZ_str
 ..quit
 .if $p(str,$c(9))'?1n.n s ok=0,error="row "_i_" - id column not rumeric"
 .quit
 close file
 
 S ^ok=ok
 
 if qf=0,ok=1 set error="Unable to locate Boundary",ok=0
 
 i 'ok S ^TMP($J,1)="{""upload"": { ""status"": ""NOK""}}"
 ; S ok=1
 i ok s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 
 i error'="" do
 . set ze="error"
 . i error["BOM" s ze="warning"
 . s ^TMP($J,1)="{""upload"": { ""status"": "_$s(ok:"""OK""",1:"""NOK""")_", """_ze_""": """_error_"""}}"
 . quit
 
 set result=$na(^TMP($J))
 I 'ok quit 1
 
 ;S USER=$P($P(ZZ,"name=""userid"""_$C(13,10,13,10),2),$C(13,10))
 S USER=$P($P(ZZ,"name=""userid"""_$C(13,13),2),$C(13))
 ; basic authentication
 I $get(un)'="" set USER=un
 
 S I=$O(^ACTIVITY(USER,""),-1)+1
 S ^ACTIVITY(USER,I)=$H_"~"_file_" uploaded ok~"_file
 
 Job PROCESS(file,USER,$GET(ZCOGID))
 quit 1
 
RemoveBOM(str,error) ;
 set error=""
 I $A(str)=239,$A($E(str,2))=187,$A($E(str,3))=191 D  ; UTF-8 BOM
 .S str=$E(str,4,$L(str))
 .set error="UTF-8 BOM detected and removed"
 .quit
 I $A(str)=255,$A($E(str,2))=254 D  ; UTF-16 LE BOM
 .S str=$E(str,3,$L(str))
 .set error="UTF-16 LE BOM detected and removed"
 .quit
 I $A(str)=254,$A($E(str,2))=255 D  ; UTF-16 BE BOM
 .S str=$E(str,3,$L(str))
 .set error="UTF-16 BE BOM detected and removed"
 .quit
 I $A(str)=255,$A($E(str,2))=254,$A($E(str,3))=0,$A($E(str,4))=0 D  ; UTF-32 LE BOM
 .S str=$E(str,5,$L(str))
 .set error="UTF-32 LE BOM detected and removed"
 .quit
 I $A(str)=0,$A($E(str,2))=0,$A($E(str,3))=254,$A($E(str,4))=255 D  ; UTF-32 BE BOM
 .S str=$E(str,5,$L(str))
 .set error="UTF-32 BE BOM detected and removed"
 .quit
 quit str
 
ETCODE ;
 ;;S HTTPLOG("DT")=+$H
 ;;S HTTPLOG("ID")=99999
 ;;D LOGERR^VPRJREQ
 S I=$O(^ACTIVITY(user,""),-1)+1
 S ^ACTIVITY(user,I)=$H_"~"_$ZSTATUS
 S $ETRAP=""
 QUIT
 
STRIP(Y) 
 N OUT,I,CH
 S OUT=""
 F I=1:1:$L(Y) D
 .S CH=$A(Y,I)
 .;I CH=9 S OUT=OUT_$C(CH)
 .;I CH<32!(CH>127) Q
 .I CH>127 Q
 .S OUT=OUT_$C(CH)
 .Q 
 QUIT OUT
 
PROCESS(file,user,ZCOGID) ;
 S $ETRAP="G ETCODE^UPRNUI"
 LOCK ^UPRNUI("process",file):1
 I '$T S ^UPRNUI("process",file)="Already being processed "_$h quit
 
 K ^TPARAMS($J)
 
 K ^TLIST($J)
 I $D(^SALTS("base64",user)) Do GETRALFS^RALF(file,user)
 
 K ^FILE(file),^NGX(user,file)
 close file
 o file:(readonly):0
 S cnt=1,qf=0
 f  u file r str q:$zeof  do  quit:cnt>$get(^UI2,100000)!(qf)
 .S str=$$STRIP(str)
 .I str=$c(13) quit
 .if str["------WebKitFormBoundary" set qf=1 quit
 .if $E(str,1,28)="----------------------------" s qf=1 quit
 .S ZID=$$TR^LIB($P(str,$C(9),1),"""","")
 .I ZID=""!(ZID=$C(13)) QUIT
 .I ZID'?1N.N quit
 .s adrec=$$TR^LIB($p(str,$C(9),2,99),$C(13),"")
 .set adrec=$$TR^LIB(adrec,$c(9)," ")
 .s qpost=$$TR^LIB($p(str,$c(9),3),$C(13),"")
 .I '$D(^TLIST($J,ZID)) D GETUPRN^UPRNMGR(adrec,qpost) s json=^temp($j,1)
 .I $D(^TLIST($J,ZID)) S json=^TLIST($J,ZID,"J")
 .K B,C
 .D DECODE^VPRJSON($name(json),$name(B),$name(C))
 .S UPRN=$GET(B("BestMatch","UPRN"))
 .S ADDFORMAT=$GET(B("BestMatch","Address_format"))
 .S ALG=$GET(B("BestMatch","Algorithm"))
 .S CLASS=$GET(B("BestMatch","Classification"))
 .S MATCHB=$GET(B("BestMatch","Match_pattern","Building"))
 .S MATCHF=$GET(B("BestMatch","Match_pattern","Flat"))
 .S MATCHN=$GET(B("BestMatch","Match_pattern","Number"))
 .S MATCHP=$GET(B("BestMatch","Match_pattern","Postcode"))
 .S MATCHS=$GET(B("BestMatch","Match_pattern","Street"))
 .S ABPN=$GET(B("BestMatch","ABPAddress","Number"))
 .S ABPP=$GET(B("BestMatch","ABPAddress","Postcode"))
 .S ABPS=$GET(B("BestMatch","ABPAddress","Street"))
 .S ABPT=$GET(B("BestMatch","ABPAddress","Town"))
 .S ABPB=$GET(B("BestMatch","ABPAddress","Building"))
 .S QUAL=$GET(B("BestMatch","Qualifier"))
 .S CTERM=$G(B("BestMatch","ClassTerm"))
 .set CTERM=CTERM_$get(B("BestMatch","ClassTerm","\",1))
 .set ABPF=$GET(B("BestMatch","ABPAddress","Flat"))
 .set BLPUSTAT=$GET(B("BestMatch","BLPUStatus"))
 .set BLPUTERM=$GET(B("BestMatch","BLPUTerm"))
 .S J=$$JSON(UPRN,ADDFORMAT,ALG,CLASS,MATCHB,MATCHF,MATCHN,MATCHP,MATCHS,ABPN,ABPP,ABPS,ABPT,QUAL,$$ESC^VPRJSON(adrec),ZID,ABPB,CTERM)
 .I $D(^BUSER("USER",user))!($GET(ZCOGID)'="") D ROW^UPRNUI3(user,file,ZID,UPRN,ADDFORMAT,ALG,CLASS,MATCHB,MATCHF,MATCHN,MATCHP,MATCHS,ABPN,ABPP,ABPS,ABPT,QUAL,adrec,ABPB,CTERM,ABPF,BLPUSTAT,BLPUTERM)
 .S cnt=cnt+1
 .I '$D(^NGX(user,file,ZID)) set ^NGX(user,file,ZID)=J QUIT
 .I $D(^NGX(user,file,ZID)) DO
 ..S Z=$O(^NGX(user,file,ZID,""),-1)+1
 ..S ^NGX(user,file,ZID,Z)=J
 ..QUIT
 .quit
 
 ; remove extra comma
 S cnt=$o(^NGX(user,file,""),-1)
 I cnt'="" do
 .s rec=^NGX(user,file,cnt)
 .s rec=$e(rec,1,$l(rec)-1)
 .S ^NGX(user,file,cnt)=rec
 .quit
 
 close file
 
 ; delete the file that has been uploaded to the server
 zsystem "rm "_file
 i $zsystem>0 s ^ZDEL($I(^ZDEL))="problem deleting file "_file
 e  s ^ZDEL($I(^ZDEL))="del ok "_file
 
 LOCK -^UPRNUI("process",file)
 S I=$O(^ACTIVITY(user,""),-1)+1
 S ^ACTIVITY(user,I)=$H_"~"_file_" processed "_cnt_" records~"_file
 QUIT
 
JSON(A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,ZID,P,Q) 
 S JS="{""ID"":"""_ZID_""","
 S JS=JS_"""UPRN"":"""_A_""","
 S JS=JS_"""add_format"":"""_B_""","
 S JS=JS_"""alg"":"""_C_""","
 S JS=JS_"""class"":"""_D_""","
 S JS=JS_"""match_build"":"""_E_""","
 S JS=JS_"""match_flat"":"""_F_""","
 S JS=JS_"""match_number"":"""_G_""","
 S JS=JS_"""match_postcode"":"""_H_""","
 S JS=JS_"""match_street"":"""_I_""","
 S JS=JS_"""abp_number"":"""_J_""","
 S JS=JS_"""abp_postcode"":"""_K_""","
 S JS=JS_"""abp_street"":"""_L_""","
 S JS=JS_"""abp_town"":"""_M_""","
 S JS=JS_"""qualifier"":"""_N_""","
 S JS=JS_"""add_candidate"":"""_O_""","
 S JS=JS_"""abp_building"":"""_P_""","
 I A'="" D
 .S COORD=$piece($get(^UPRN("U",A)),"~",7)
 .S LAT=$P(COORD,",",3),LONG=$P(COORD,",",4)
 .S POINT=$P(COORD,",",3),X=$P(COORD,",",1),Y=$P(COORD,",",2)
 .S JS=JS_"""latitude"":"""_LAT_""","
 .S JS=JS_"""longitude"":"""_LONG_""","
 .S JS=JS_"""point:"":"""_POINT_""","
 .S JS=JS_"""X"":"""_X_""","
 .S JS=JS_"""Y"":"""_Y_""","
 .S JS=JS_"""ralf"":"""_$GET(^TRALFS($J,A))_""","
 .QUIT
 S JS=JS_"""class_term"":"""_Q_"""},"
 QUIT JS
