ASSTST ; ; 3/2/21 9:55am
 ;S ^%W(17.6001,"B","GET","m/selfile","ASSERT^ASSTST",6109)=""
 ;S ^%W(17.6001,"B","POST","m/saveass","SAVE^ASSTST",6110)=""
 ;S ^%W(17.6001,"B","GET","m/saveass","SAVE^ASSTST",6110)=""
 
 S ^%W(17.6001,"B","GET","m/selfile2","ASSERT2^ASSTST",6111)=""
 S ^%W(17.6001,"B","POST","m/saveass2","SAVE2^ASSTST",6112)=""
 S ^%W(17.6001,"B","GET","m/download2","DOWN2^ASSTST",6114)=""
 QUIT
 
ASSERT(result,arguments) 
 K ^TMP($J)
 I '$$IP^UPRNUI() G BYE
 d H("<html>")
 ;D H("<form action=""https://devuprn8.discoverydataservice.net:8443/m/saveass"">")
 D H("<form action=""/m/saveass"">")
 D H("<input type=""file"" id=""myFile"" name=""filename"">")
 D H("<input type=""submit"">")
 D H("</form>")
 d H("</html>")
BYE set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
ASSERT2(result,arguments) 
 K ^TMP($J)
 I '$$IP^UPRNUI() G BYE
 d H("<html>")
 ;D H("<br>")
 D H("<a href=""/m/download2"" a download=""uprn_assertions.txt"">Download assertions</a>")
 D H("<br><br>")
 ;D H("cleardown before filing? <input type=""checkbox"" id=""purge"" name=""purge"" value=""purge""><br><br>")
 ;d H("<form action=""https://devuprn8.discoverydataservice.net:8443/m/saveass2"" method=""post"" enctype=""multipart/form-data"">")
 D H("<form action=""/m/saveass2"" method=""post"" enctype=""multipart/form-data"">")
 D H("Select text file to upload:")
 D H("<input type=""file"" name=""fileToUpload"" id=""fileToUpload"">")
 D H("<br><br>purge before filing? <input type=""checkbox"" id=""purge"" name=""purge"" value=""1""><br><br>")
 D H("<input type=""submit"" value=""Upload assertions"" name=""submit"">")
 D H("</form>")
 
 ;
 
 D H("<table border=1>")
 D H("<td>new uprn</td>")
 D H("<td>original uprn</td>")
 D H("<td>original candidate address</td>")
 D H("<td>new candidate address</td>")
 D H("<tr>")
 
 S origadd=""
 F  S origadd=$O(^ZASSERT(origadd)) quit:origadd=""  do
 .set forigadd=^ZASSERT(origadd,"O")
 .set fnewadd=^ZASSERT2(origadd)
 .set uprns=^ZASSERT3(origadd)
 .set newuprn=$p(uprns,"~",1)
 .set origuprn=$p(uprns,"~",2)
 .D H("<td>"_newuprn_"</td>")
 .D H("<td>"_origuprn_"</td>")
 .D H("<td>"_forigadd_"</td>")
 .D H("<td>"_fnewadd_"</td>")
 .D H("<tr>")
 .quit
 D H("</table>")
 
 D H("</html>")
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
 ; DOWNLOAD ASSERTIONS
DOWN2(result,arguments) 
 K ^TMP($J)
 I '$$IP^UPRNUI() G BYE
 ;S ^TMP($J,1)="LINE 1"
 ;F I=1:1:1000 S ^TMP($J,I)="LINE "_I_$C(10)
 S D=$C(9)
 S origadd="",C=1
 f  s origadd=$order(^ZASSERT(origadd)) q:origadd=""  do
 .s newuprn=$p(^ZASSERT3(origadd),"~",1)
 .s origuprn=$p(^ZASSERT3(origadd),"~",2)
 .s origfmtd=^ZASSERT(origadd,"O")
 .s newfmtd=^ZASSERT2(origadd)
 .S ^TMP($J,C)=newuprn_D_origuprn_D_origfmtd_D_newfmtd_$C(10)
 .S C=$I(C)
 .QUIT
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 QUIT
 
STRIP(Y) ;
 N OUT,I,CH
 S OUT=""
 F I=1:1:$L(Y) D
 .S CH=$A(Y,I)
 .I CH>127 Q
 .S OUT=OUT_$C(CH)
 .QUIT
 QUIT OUT
 
VAR(file,var) 
 S ^TST=file_"~"_var
 c file
 O file:(readonly)
 S qvar=""
 f  u file r str q:$zeof  do  q:qvar'=""
 .;BREAK
 .S str=$$STRIP(str)
 .I str=$c(13) q
 .;U 0 W !
 .;U 0 W !,str," ",$L(str)
 .;U 0 W !,var," ",$L(var)
 .;U 0 W !
 .i $E(str,1,$L(str)-1)=var do
 ..;U 0 W !,"HERE"
 ..u file r crlf
 ..u file r qvar
 ..quit
 .quit
 c file
 QUIT qvar
 
 ; UPLOAD ASSERTIONS
SAVE2(arguments,body,result) 
 ;I '$$IP^UPRNUI() G BYE
 K ^TMP($J)
 I '$$IP^UPRNUI() G BYE
 
 ;M ^A=arguments
 ;M ^ASS2=body
 
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 
 S file="/tmp/assert"_$J_".txt"
 close file
 O file:(newversion:stream:nowrap:chset="M")
 set line=""
 for  set line=$order(body(line)) q:line=""  do
 .use file write body(line)
 .quit
 close file
 
 ;M ^ASS2=body
 ;M ^ZBODY=HTTPREQ
 
 ; get the purge variable
 set var="Content-Disposition: form-data; name=""purge"""
 S purge=$$VAR(file,var)
 s ^purge=purge
 
 ; process the file
 K ^TASS($J)
 close file
 o file:(readonly)
 s (qf,c)=0
 f  u file r str q:$zeof  do  quit:qf
 .S str=$$STRIP(str)
 .I str=$c(13) quit
 .if str["------WebKitFormBoundary" set qf=1 quit
 .if $E(str,1,28)="----------------------------" s qf=1 quit
 .S ^TASS($j,c)=str,c=$i(c)
 .quit
 close file
 
 D:$D(^TASS($J)) FILE(purge)
 
 I '$D(^TASS($J)) S ^TMP($J,1)="Sorry, nothing was processed"
 
 ;S ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 QUIT 1
 
FILE(purge) ;
 N line
 if purge K ^ZASSERT,^ZASSERT2,^ZASSERT3
 set line="",c=1
 for  s line=$order(^TASS($J,line)) q:line=""  do
 .set STR=^(line)
 .S origuprn=$P(STR,$C(9),2)
 .S newuprn=$P(STR,$C(9),1)
 .S origaddress=$P(STR,$C(9),3)
 .S zuprn=$$GETUPRN(origaddress)
 .i zuprn'=origuprn do  quit
 ..S ^TMP($J,c)="uprn mismatch (row "_c_")<br>"
 ..S c=$i(c)
 ..quit
 .S newaddress=$P(STR,$C(9),4)
 .S zuprn=$$GETUPRN(newaddress)
 .i zuprn'=newuprn S ^TMP($J,c)="uprn mismatch (row "_c_")<br>",c=$i(c) quit
 .S lorigaddress=$$TR^LIB($$TR^LIB($$LC^LIB(origaddress)," ",""),",","")
 .S lnewaddress=$$TR^LIB($$TR^LIB($$LC^LIB(newaddress)," ",""),",","")
 .S ^ZASSERT(lorigaddress)=newuprn
 .S ^ZASSERT(lorigaddress,"O")=origaddress
 .S ^ZASSERT2(lorigaddress)=newaddress
 .S ^ZASSERT2(lorigaddress,"O")=origaddress
 .S ^ZASSERT3(lorigaddress)=newuprn_"~"_origuprn
 .quit
 I '$D(^TMP($J)) S ^TMP($J,1)="Success!"
 QUIT
 
GETUPRN(zorigadd) 
 K ^TPARAMS($J)
 S ^TPARAMS($J,"commercials")=1 ; commercials on
 D GETUPRN^UPRNMGR(zorigadd,"","","",0,0)
 k b
 D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 quit $get(b("UPRN"))
 QUIT
 
SAVE(result,arguments) ; 
 K ^TMP($J)
 I '$$IP^UPRNUI() G BYE
 M ^ASS=arguments
 M ^ZBODY=HTTPREQ
 S ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
H(H) ;
 N c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=H_$c(13)_$c(10)
 quit
