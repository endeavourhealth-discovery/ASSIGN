UPLOADER ;
	S ^%W(17.6001,"B","POST","uploader/process","SAVE^UPLOADER",7801)=""
	S ^%W(17.6001,7801,"AUTH")=2
	S ^%W(17.6001,"B","GET","uploader/ui","UI^UPLOADER",7802)=""
	S ^%W(17.6001,7802,"AUTH")=2
	S ^%W(17.6001,"B","GET","uploader/output","OUTPUT^UPLOADER",7803)=""
	S ^%W(17.6001,7803,"AUTH")=2
	quit
	;
H(H) ;
	N c
	s c=$order(^TMP($J,""),-1)+1
	s ^TMP($J,c)=H_$c(13)_$c(10)
	quit
	;	
OUTPUT(result,arguments)
	K ^TMP($J)
	S un=$get(un)
	i un="" s un="paul"
	S ^UN=un
	D H("<html>")
	D H("<table border=1>")
	set id=""
	f  s id=$o(^UPLOADER(un,id)) q:id=""  do
	. S rec=^(id)
	. s adr=$p(rec,"~",1),uprn=$piece(rec,"~",2),json=$p(rec,"~",3)
	. s h="<td>"_id_"</td><td>"_uprn_"</td><td>"_adr_"</td><td>"_json_"</td><tr>"
	. D H(h)
	. quit
	D H("</table>")
	D H("</html>")
	set result("mime")="text/html"
	set result=$na(^TMP($J))	
	quit
	;	
UI(result,arguments)
	K ^TMP($J)
	d H("<html>")
	D H("<form action=""/uploader/process"" method=""post"" enctype=""multipart/form-data"">")
	D H("Select text file to upload:")
	D H("<input type=""file"" name=""fileToUpload"" id=""fileToUpload"">")
	D H("<br><br>")
	D H("<input type=""submit"" value=""Upload"" name=""submit"">")
	D H("</form>")
	set result("mime")="text/html"
	set result=$na(^TMP($J))	
	quit
	;
SAVE(arguments,body,result) ;
	K ^TMP($J)
	;		
	if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
	S file="/tmp/uploader"_$J_".txt"
	close file
	O file:(newversion:stream:nowrap:chset="M")
	set line=""
	for  set line=$order(body(line)) q:line=""  do
	. use file write body(line)
	. quit
	close file
	;K ^BODY
	;M ^BODY=body
	job PROCESS($J,$get(un))
	S ^TMP($J,1)="Success!"
	set result("mime")="text/html"
	set result=$na(^TMP($J))
	quit 1
	;	
PROCESS(job,un)
	if un="" s un="paul"
	k ^UPLOADER(un)
	s f="/tmp/uploader"_job_".txt"
	close f
	o f:(readonly)
	set qf=0
	f  u f r str q:$zeof  do  q:qf
	. set str=$$TR^LIB(str,$char(13),"")
	. i str="" quit
	. i $e(str,1,3)="---" set qf=1 quit
	. set id=$p(str,$c(9))
	. set adrec=$p(str,$c(9),2)
	. D GETUPRN^UPRNMGR(adrec,"","","",0,0)
	. set json=^temp($j,1)
	. k b
	. D DECODE^VPRJSON($name(json),$name(b),$name(err))
	. set uprn=$get(b("BestMatch","UPRN"))
	. set ^UPLOADER(un,id)=adrec_"~"_uprn_"~"_json
	. if uprn'="" set ^UPLOADER(un,id,"U")=$get(^UPRN("U",uprn))
	. quit
	close f
	quit
	;
AFTER ; creates a file that can be uploaded
	new i
	s f="/tmp/uploader.txt"
	close f
	o f:(newversion:stream:nowrap:chset="M")
	use f
	set adr="",i=1
	f  s adr=$order(^AFTER(adr)) q:adr=""  do
	. w i,$c(9),adr,!
	. s i=$i(i) 
	. quit
	close f
	quit