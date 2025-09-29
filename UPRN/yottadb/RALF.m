RALF ; ; 3/28/24 3:15pm
 D STT("b786234a-edfd-4424-b87f-d0ea7ee8949b","/opt/files/qpost-test.txt")
 QUIT
 
STT2 ;
 S F="/opt/files/qpost-test.txt"
 C F
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .U 0 W !,"[",$$TR^LIB(STR,$C(13),""),"]"
 .QUIT
 C F
 QUIT
 
 ; D FIX^RALF("/opt/files/uprn-match.EncryptedSalt",""b786234a-edfd-4424-b87f-d0ea7ee8949b")
FIX(file,user) ;
 c file
 o file:(readonly)
 S OUT=""
 f  u file r *str q:$zeof  do
 .S OUT=OUT_$C(str)
 .quit
 c file
 ;S OUT=$P(OUT,"-----")
 ;S OUT=$E(OUT,1,$L(OUT)-1)
 S OUT=$E(OUT,1,128)
 S id=$order(^SALTS("base64",user,""),-1)+1
 S ^SALTS("base64",user,id)=$$ENCODE^BASE64(OUT)
 S ^SALTS("binary",user,id)=OUT
 D DEL(file)
 quit
 
DEL(file) ;
 open file:(readonly)
 close file:delete
 quit
 
TEST ;
 S user="b786234a-edfd-4424-b87f-d0ea7ee8949b"
 S id=$order(^SALTS("base64",user,""),-1)
 S base64=^SALTS("base64",user,id)
 ;S binary=$$DECODE^BASE64(base64)
 
 S binary=^SALTS("binary",user,id)
 S file="/tmp/binary.txt"
 close file
 
 ;open file:(newversion) use file w binary
 ;O file:(newversion:stream:nowrap:chset="M")
 ;F i=1:1:127 use file w $e(binary,i)
 
 O file:(newversion:fixed:stream:nowrap:recordsize=$L(binary):chset="M")
 use file w binary
 close file
 ZSYSTEM "/tmp/ralfs.sh /tmp/ralfs-in-10991.txt /tmp/binary.txt /tmp/zspit2.txt"
 QUIT
 
GETRALFS(file,userid) 
 K ^TRALFS($J),^TLIST($J)
 
 close file
 open file:(readonly):0
 S qf=0
 f  u file r str q:$zeof  do  q:qf
 .S str=$$STRIP^UPRNUI2(str)
 .I str=$c(13) quit
 .if str["------WebKitFormBoundary" set qf=1 quit
 .if $E(str,1,26)="----------------------------" s qf=1 quit
 .S ZID=$$TR^LIB($P(str,$C(9),1),"""","")
 .;U 0 W !,ZID
 .I ZID=""!(ZID=$C(13)) QUIT
 .s adrec=$$TR^LIB($p(str,$C(9),2),$C(13),"")
 .set adrec=$$TR^LIB(adrec,$c(9)," ")
 .s qpost=$$TR^LIB($p(str,$c(9),3),$C(13),"")
 .s commercial=$$TR^LIB($p(str,$c(9),4),$C(13),"")
 .kill ^TPARAMS($J,"commercials")
 .if $$UC^LIB(commercial)="Y" set ^TPARAMS($J,"commercials")=1
 .D GETUPRN^UPRNMGR(adrec,qpost,"","",0,0)
 .s json=^temp($j,1)
 .K B,C
 .D DECODE^VPRJSON($name(json),$name(B),$name(C))
 .S UPRN=$GET(B("BestMatch","UPRN"))
 .S ^TLIST($J,ZID)=UPRN
 .; cache the json response
 .S ^TLIST($J,ZID,"J")=^temp($j,1)
 .quit
 
 close file
 
 S ZID=""
 S file="/tmp/ralfs-in-"_$J_".txt"
 close file
 o file:(newversion)
 F  S ZID=$O(^TLIST($J,ZID)) Q:ZID=""  DO
 .S UPRN=^(ZID)
 .I UPRN="" QUIT
 .U file W ZID,$C(9),UPRN,!
 .quit
 close file
 
 S id=$order(^SALTS("base64",userid,""),-1)
 S base64=^SALTS("base64",userid,id)
 S binary=^SALTS("binary",user,id)
 
 S salt="/tmp/binary"_$j_".txt"
 c salt
 
 ;open salt:(newversion)
 
 ;use salt write $$DECODE^BASE64(base64)
 ;S binary=$$DECODE^BASE64(base64)
 ;F zi=1:1:127 use salt w $e(binary,zi)
 
 O salt:(newversion:fixed:stream:nowrap:recordsize=$L(binary):chset="M")
 use salt w binary
 close salt
 
 S cmd="/tmp/ralfs.sh "_file_" "_salt_" /tmp/ralfspit"_$j_".txt"
 S ^CMD2=cmd
 zsystem cmd
 
 set spit="/tmp/ralfspit"_$j_".txt"
 close spit
 open spit:(readonly)
 f  u spit r str q:$zeof  do
 .s uprn=$p(str,",",3)
 .s ralf=$p(str,",",2)
 .S ^TRALFS($J,uprn)=ralf
 .quit
 close spit
 
 ; delete the tmp files that helped create the ralfs
 D DEL(file),DEL(salt),DEL(spit)
 QUIT
 
STT(userid,file) 
 n line,f
 S f="/tmp/ralfs"_$job_".txt"
 close f
 o f:(newversion)
 set line=""
 set last=$order(^NGX(userid,file,""),-1)
 f  s line=$o(^NGX(userid,file,line)) q:line=""  do
 .s json=^(line)
 .i line<last set json=$e(json,1,$l(json)-1)
 .K b
 .D DECODE^VPRJSON($name(json),$name(b),$name(err))
 .use f w b("ID"),$c(9),b("UPRN"),!
 .quit
 close f
 S cmd="/tmp/ralfs.sh "_f_" /tmp/uprn-match.EncryptedSalt /tmp/ralfspit"_$j_".txt"
 zsystem cmd
 QUIT
