POUR2 ; ; 11/2/22 8:53am
 quit
 
SETUP ;
 S ^%W(17.6001,"B","GET","por2/ui","STT^POUR2",22667)=""
 S ^%W(17.6001,22667,"AUTH")=2
 
 S ^%W(17.6001,"B","POST","por2/upload","UPLOAD^POUR2",76328)=""
 S ^%W(17.6001,76328,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","por2/download","DOWNLOAD^POUR2",64908)=""
 S ^%W(17.6001,64908,"AUTH")=2
 quit
 
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
 
UPLOAD(arguments,body,result) ;
 ;K ^BODY
 
 ;M ^BODY=body
 
 K ^TMP($J)
 
 ; get rid of the fluff at the top of the file
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 
 set count=1,c=""
 set file="/tmp/f"_$job_".txt"
 close file
 open file:(newversion:stream:nowrap:chset="M")
 for  set c=$order(body(c)) q:c=""  do
 .s rec=body(c)
 .use file w rec
 .quit
 
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
 close file ; :delete
 job RUN^POUR(un):(out="/dev/null")
 
 ;S ^TMP($J,1)="<a href=""/por2/download"" a download=""por.txt"">Download the output from your last upload</a>"
 S ^TMP($J,1)="Success!"
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
STT(result,arguments) ;
 new i
 k ^TMP($J)
 for i=1:1 q:$text(JS+i)["*** end ***"  do
 .;w $piece($t(JS+i),";",2,999),!
 .s ^TMP($j,i)=$piece($t(JS+i),";",2,999)_$char(13,10)
 .quit
 ;zwr ^TMP($J,*)
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
JS ;
 ;<script type="text/javascript">
 ;
 ;function _(el) {
 ;    return document.getElementById(el);
 ;}
 ;
 ;function upload() {
 ;   var file = _("image").files[0];
 ;   var formdata = new FormData();
 ;   formdata.append("image", file);
 ;   var ajax = new XMLHttpRequest();
 ;   ajax.upload.addEventListener("progress", progressHandler, false);
 ;   ajax.addEventListener("load", completeHandler, false);
 ;   ajax.addEventListener("error", errorHandler, false);
 ;   ajax.addEventListener("abort", abortHandler, false);
 ;   ajax.open("POST", "/por2/upload");
 ;   ajax.send(formdata);
 ;}
 ;
 ;function progressHandler(event) {
 ;   _("loadedtotal").innerHTML = "Uploaded " + event.loaded + " bytes of " + event.total;
 ;   var percent = (event.loaded / event.total) * 100;
 ;    _("progressBar").value = Math.round(percent);
 ;    _("status").innerHTML = Math.round(percent) + "% uploaded... please wait";
 ;}
 ;
 ;function completeHandler(event) {
 ;    _("status").innerHTML = event.target.responseText;
 ;    _("progressBar").value = 0;
 ;}
 ;
 ;function errorHandler(event) {
 ;    _("status").innerHTML = "Upload Failed";
 ;}
 ;
 ;function abortHandler(event) {
 ;    _("status").innerHTML = "Upload Aborted";
 ;}
 ;
 ;</script>
 ;<html>
 ;<p>PoR utility v0.2</p><br>
 ;<form method="post" enctype="multipart/form-data">
 ;    <input type="file" name="image" id="image" onchange="upload()"><br>
 ;    <progress id="progressBar" value="0" max="100" style="width:500px;"></progress>
 ;    <h2 id="status"></h2>
 ;    <p id="loadedtotal"></p>
 ;</form>
 ;<br>
 ;<a href="/por2/download" a download="por.txt">Download the output from your last upload</a>
 ;</html>
 ;*** end ***
