POUR ; ; 11/21/22 12:22pm
 quit
 
SETUP ;
 S ^%W(17.6001,"B","POST","por/upload","UPLOAD^POUR",99471)=""
 S ^%W(17.6001,99471,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","por/ui","UI^POUR",22551)=""
 S ^%W(17.6001,22551,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","por/download","DOWNLOAD^POUR",99463)=""
 S ^%W(17.6001,99463,"AUTH")=2
 quit
 
TESTDATA ;
 new f,f2
 set f="/tmp/2204_ncmp_ralf.txt"
 set f2="/tmp/testdata.txt"
 o f2:(newversion)
 close f
 o f:(readonly)
 use f r str
 f  u f r str q:$zeof  do
 .s pseudo=$p(str,$c(9),1)
 .s eventdate=$$F^STATA($p(str,$c(9),24))
 .;u 0 w !,eventdate r *y
 .use f2 w pseudo,$c(9),eventdate,!
 .quit
 close f,f2
 quit
 
UI(result,arguments) ;
 new user,rec,acvc
 K ^TMP($job)
 
 ;set rec=$get(HTTPREQ("header","authorization"))
 ;s ^bob=$$DECODE64^VPRJRUT($p(rec," ",2))
 ;set acvc=$$DECODE64^VPRJRUT(rec)
 ;set user=$piece(acvc,":")
 
 ;set ^TMP($J,1)="<html>"
 ;set ^TMP($J,2)="<b>"_$get(un)_"</b>"
 
 d H("<html>")
 
 d H("PoR utility v 0.1<br><br>")
 
 d H("<form action=""/por/upload"" method=""post"" enctype=""multipart/form-data"">")
 d H("Select text file to upload:")
 d H("<input type=""file"" id=""fileToUpload"" name=""fileToUpload"">")
 D H("<input type=""submit"" value=""Submit"" name=""submit"">")
 D H("</form>")
 
 I '$D(^U2(un)) D H("You have nothing to download, because you have never uploaded a file before")
 
 D:$d(^U2(un)) H("<a href=""/por/download"" a download=""por.txt"">Download the output from your last upload</a>")
 
 d H("</html>")
 
 ;set ^TMP($J,3)="</html>"
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
H(H) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=H_$c(13,10)
 quit
 
VAR(file,var) ;
 n str,qvar
 close file
 open file:(readonly)
 set qvar=""
 f  u file r str q:$zeof  do  q:qvar'=""
 .set str=$$TR^LIB(str,$c(13),"")
 .;?
 .i str[("name="""_var_"""") do
 ..;?
 ..use file r crlf
 ..read qvar
 ..quit
 .quit
 close file
 quit $$TR^LIB(qvar,$char(13),"")
 
UPLOAD(arguments,body,result) ;
 new count,c
 K ^TMP($J)
 
 ; get rid of the fluff at the top of the file
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 
 ;S ^BODY($O(^BODY(""),-1)+1)=$e(body(1),1,999)
 ;M ^HEADER=HTTPREQ
 
 ;M ^BODY=body
 
 set count=1,c=""
 set file="/tmp/f"_$job_".txt"
 close file
 open file:(newversion:stream:nowrap:chset="M")
 for  set c=$order(body(c)) q:c=""  do
 .s rec=body(c)
 .use file w rec
 .quit
 close file
 
 ;S filename=$$VAR(file,"tag")
 kill ^U2(un)
 set ^U2(un)=$Horolog
 set count=1
 close file
 
 o file:(readonly)
 set qf=0
 f  u file r str q:$zeof  do  q:qf
 .if str["----------------------" set qf=1 quit
 .if str["WebKitForm" set qf=1 quit
 .set str=$translate(str,$c(13),"")
 .i str="" quit
 .set ^U2(un,count)=str
 .s count=$i(count)
 .quit
 close file
 
 job RUN(un):(out="/dev/null")
 
 s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
DOWNLOAD(result,arguments) ;
 new c
 kill ^TMP($J)
 s c=""
 s un=$get(un)
 f  s c=$o(^POUR("O",un,c)) q:c=""  do
 .s ^TMP($J,c)=^POUR("O",un,c)_$char(10)
 .quit
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
NORS(pseudo,nors,salt) 
 new nor,saltid
 set ^salty(2)=salt
 set saltid=$$SALTID(salt)
 set ^salty(3)=saltid
 s nor=""
 f  s nor=$o(^SPIT(saltid,pseudo,nor)) q:nor=""  set nors(nor)=""
 quit
 
SALTID(salt) ;
 new saltid,name,qf
 set saltid="",qf=0
 for  s saltid=$order(^SALTS("pseudo_salts",saltid)) q:saltid=""  do  q:qf
 .set name=^SALTS("pseudo_salts",saltid,"saltKeyName")
 .if name=salt s qf=1
 .quit
 quit saltid
 
CLASS ;
 K ^RESCODE
 S f="/tmp/ABP/Residential_codes.txt"
 c f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .s code=$p(str,$c(9),2)
 .s desc=$p(str,$c(9),3)
 .set ^RESCODE(code)=desc
 .quit
 close f
 quit
 
RUN(user,salt) ;
 new c,pour,nor,eventdate,nors,propclass,propdesc,ralf00
 s c="",zc=1
 
 ; convert the psuedo nhs numbers to patient numbers
 K ^POUR("O",user)
 for  s c=$order(^U2(user,c)) quit:c=""  do
 .s rec=^U2(user,c)
 .s pseudo=$p(rec,$c(9),1),eventdate=$p(rec,$char(9),2)
 .kill nors
 .D NORS(pseudo,.nors,salt)
 .;W !,pseudo
 .;w !
 .;zwr nors
 .;w !
 .s nor=""
 .f  s nor=$o(nors(nor)) q:nor=""  do
 ..;W !,nor
 ..;W !,eventdate
 ..set pour=$$PLACEATEVT^FX2(nor,eventdate)
 ..s propclass=$p(pour,"~",6)
 ..s ralf00=$p(pour,"~",4)
 ..s propdesc=$get(^RESCODE(propclass))
 ..s rec=$p(pour,"|",3)
 ..s lsoa=$p(rec,"~",1),msoa=$p(rec,"~",2)
 ..set ^POUR("O",user,zc)=pseudo_$c(9)_ralf00_$c(9)_eventdate_$c(9)_propclass_$c(9)_propdesc_$c(9)_lsoa_$c(9)_msoa
 ..set zc=$increment(zc)
 ..quit
 .quit
 
 ;K ^POUR("O",user)
 ;f  s c=$o(^U2(user,c)) q:c=""  do
 ;.s rec=^(c)
 ;.s nor=$p(rec,$c(9),1),eventdate=$p(rec,$c(9),2)
 ;.set pour=$$PLACEATEVT^FX2(nor,eventdate)
 ;.set ^POUR("O",user,c)=$$TR^LIB(pour,"~",$C(9))_$C(9)_nor_$C(9)_eventdate
 ;.quit
 
 quit
