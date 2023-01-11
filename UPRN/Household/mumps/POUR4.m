POUR4 ; ; 1/10/23 3:51pm
 ; next version of PoR utility
 ;
 
SETUP ;
 set ^%W(17.6001,"B","GET","por4/stt","STT^POUR4",650387)=""
 set ^%W(17.6001,650387,"AUTH")=2
 
 set ^%W(17.6001,"B","POST","por4/run","RUN^POUR4",650388)=""
 set ^%W(17.6001,650388,"AUTH")=2
 
 set ^%W(17.6001,"B","GET","por4/status","STATUS^POUR4",650390)=""
 set ^%W(17.6001,650390,"AUTH")=2
 quit
 
FN(file) ;
 new f
 s f=""
 c file
 o file:(readonly)
 f  u file r str q:$zeof  do  q:f'=""
 .i str["filename=" do
 ..s f=$p($p(str,"filename=""",2),"""")
 ..quit
 .quit
 close file
 quit f
 
RUN(arguments,body,result) ;
 new c,qf,count
 
 ; test if already running?
 lock ^KRUNNING(un):1
 if '$t do  quit 1
 .s ^TMP($J,1)="{""upload"": { ""status"": ""job already running for user""}}"
 .set result("mime")="text/html"
 .set result=$na(^TMP($J))
 .quit
 
 ; get rid of the fluff at the top of the file
 ;if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 K ^BODY
 M ^BODY=body
 
 set file="/tmp/f"_$job_".txt"
 close file
 open file:(newversion:stream:nowrap:chset="M")
 set c=""
 for  set c=$order(body(c)) q:c=""  do
 .s rec=body(c)
 .use file write rec
 .quit
 close file
 
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 
TEST ;set file="/tmp/f2516.txt"
 set count=1
 
 ; get fixed date, CompassSKID name, RALFSKID name 
 ; must be file in the request if date is null
 
 ; check filename extension
 set filename=$$FN(file)
 
 if filename'="",$p(filename,".",$l(filename,"."))'="txt" do  q 1
 .d DEL(file)
 .s ^TMP($J,1)="{""upload"": { ""status"": ""must be an ascii text file""}}"
 .set result("mime")="text/html"
 .set result=$na(^TMP($J))
 .quit
 
 ; nhs_number
 set pseudosalt=$$VAR^POUR(file,"pseudo_salts")
 set fixeddate=$$VAR^POUR(file,"date")
 ; ralf
 set ralfsalt=$$VAR^POUR(file,"ralf_salts")
 ;set filename=$$FN(file)
 
 kill ^U3(un)
 set ^U3(un)=pseudosalt_"~"_fixeddate_"~"_ralfsalt_"~"_filename_"~"_$Horolog
 
 if fixeddate="" do
 .; must have uploaded a file
 .;
 .;
 .;
 .close file
 .o file:(readonly)
 .s (qf,go)=0
 .f  use file r str q:$zeof  do  quit:qf
 ..if str[filename do  quit
 ...use file r str,str
 ...s go=1
 ...quit
 ..if 'go quit
 ..if str["----------------------" set qf=1 quit
 ..if str["WebKitForm" set qf=1 quit
 ..set str=$translate(str,$c(13),"")
 ..i str="" quit
 ..set ^U3(un,count)=str
 ..s count=$i(count)
 ..quit
 .close file
 .quit
 
 do DEL(file)
 
 lock -^KRUNNING(un)
 
 s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
DEL(f) ;
 close f
 o f:(readonly)
 c f:delete
 quit
 
JRUN(user) ;
 new c,pour,nor,eventdate,nors,propclass,propdesc,ralf00
 new pseudosalt,fixeddate,ralfsalt,filename
 
 set c=""
 k ^POUR("O",user)
 set rec=^U3(user)
 set pseudosalt=$piece(rec,"~",1)
 set fixeddate=$piece(rec,"~",2)
 set ralfsalt=$p(rec,"~",3)
 set filename=$p(rec,"~",4)
 if fixeddate'="" D FIXED(pseudosalt,fixeddate,ralfsalt,user) quit
 D FILE(pseudosalt,ralfsalt,user)
 quit
 
FILE(pseudosalt,ralfsalt,user) ;
 new count,pseudo,date,nors,nor,c
 
 set sralf=$p(ralfsalt,"_",3)
 set spseudo=$p(pseudosalt,"_",3)
 
 kill ^POUR("O",user)
 
 set count="",c=1
 f  set count=$o(^U3(user,count)) quit:count=""  do
 .s rec=^(count)
 .s pseudo=$piece(rec,$c(9),1)
 .s date=$p(rec,$c(9),2)
 .; get the patient ids
 .set nors=$get(^SPIT("P",spseudo,pseudo))
 .;
 .if nors="" quit
 .for i=1:1:$l(nors,"~") q:$p(nors,"~",i)=""  do
 ..set nor=$piece(nors,"~",i)
 ..;w !,nor r *y
 ..S pour=$$PLACEATEVT^FX2(nor,date,1)
 ..W !,pour r *y
 ..D SAVE(pour,c)
 ..set c=$i(c)
 ..quit
 .quit
 quit
 
 ; pseudo_salts_3
 ; 2023-01-04
 ; ralf_salts_1
 ; d FIXED^POUR4("pseudo_salts_3","2023-01-04","ralf_salts_1","eltest")
 ;
FIXED(pseudosalt,fixeddate,ralfsalt,user) 
 new nor,r,why,c
 
 set nor="",c=1
 K ^POUR("O",user)
 
 set sralf=$p(ralfsalt,"_",3)
 set spseudo=$p(pseudosalt,"_",3)
 
 f  s nor=$order(^ASUM(nor)) quit:nor=""  do
 .S pour=$$PLACEATEVT^FX2(nor,fixeddate,1)
 .;W !,pour r *y
 .;S why=$$WHY^POPEXT()
 .;I why'="",why'=5 w !,nor,!,"[",why,"]" r *y
 .;;s propclass=$p(pour,"~",6)
 .;;s propdesc=$get(^RESCODE(propclass))
 .;;s rec=$p(pour,"|",3)
 .;;s lsoa=$p(rec,"~",1),msoa=$p(rec,"~",2)
 .;;set uprn=$p(pour,"~",3)
 .;W !,"[",pour,"]" r *y
 .;i $L(pour,"~")<4 quit ; ** ?
 .;;set pseudo=$get(^SPIT("N",spseudo,nor))
 .;;s ralf=$get(^RALF(sralf,uprn))
 .;S ^POUR("O",user,c)=pseudo_$c(9)_ralf_$c(9)_$c(9)_propclass_$c(9)_propdesc_$c(9)_lsoa_$c(9)_msoa
 .;;S ^POUR("O",user,c)=pseudo_"~"_ralf_"~"_propclass_"~"_lsoa_"~"_msoa
 .do SAVE(pour,c)
 .s c=c+1
 .i c#1000=0 w !,c
 .quit
 quit
 
SAVE(pour,c) ;
 new propclass,propdesc,rec,lsoa,msoa,uprn,pseudo,ralf
 
 s propclass=$p(pour,"~",6)
 s propdesc=$get(^RESCODE(propclass))
 s rec=$p(pour,"|",3)
 s lsoa=$p(rec,"~",1),msoa=$p(rec,"~",2)
 set uprn=$p(pour,"~",3)
 set pseudo=$get(^SPIT("N",spseudo,nor))
 s ralf=$get(^RALF(sralf,uprn))
 S ^POUR("O",user,c)=pseudo_"~"_ralf_"~"_propclass_"~"_lsoa_"~"_msoa
 
 quit
 
H(h) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=h_$c(13,10)
 quit
 
WRITE ;
 new c,r,a
 D STT(.r,.a)
 s f="/tmp/pour4.html"
 close f
 o f:(newversion)
 s c=""
 f  s c=$o(^TMP($J,c)) q:c=""  do
 .use f w ^(c)
 .quit
 close f
 quit
 
OUTPUT ;
 do H("<font size=""3"" face=""Courier New""><u><b>Outputs</b></u></p></font>")
 do H("<table border=1 width=""50%"">")
 do H("<td>CompassSKID</td><td>pseudo anonymised nhs_number</td><tr>")
 do H("<td>PoR</td><td>RALFSKID (anonymised UPRN)</td><tr>")
 do H("<td>event_date</td><td>event date used to find PoR</td><tr>")
 do H("<td>prop_class</td><td>property classification code</td><tr>")
 do H("<td>prop_desc</td><td>property classification description</td><tr>")
 do H("<td>lsoa</td><td>lower layer super output area (2011)</td><tr>")
 do H("<td>msoa</td><td>middle layer super output area (2011)</td><tr>")
 do H("</table>")
 quit
 
TODAY() ;
 new today
 set today=$$HD^STDDATE(+$H)
 set today=$p(today,".",3)_"-"_$p(today,".",2)_"-"_$p(today,".",1)
 quit today
 
 ; pseudo_salts
 ; ralf_salts
COMBO1(id) ;
 new i,name
 set i=""
 set html="<select name="""_id_""" style=""width: 150px;"">"
 set html=html_"<option value=""?"">?</option>"
 f  s i=$o(^SALTS(id,i)) q:i=""  do
 .s name=^SALTS(id,i,"saltKeyName")
 .s n=+$e(name,$l(name)-1,$l(name))
 .s html=html_"<option value="""_id_"_"_n_""">"_name_"</option>"
 .quit
 s html=html_"</select>"
 quit html
 
COMBO2() ;
 quit ""
 
STT(result,arguments) 
 n c
 kill ^TMP($J)
 ; radio buttons (default to fixed date)
 do H("<html>")
 
 do H("<script src=""https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js""></script>")
 
 do H("<script>")
 do H("function validateForm() {")
 do H("  var pseudo_salts = document.forms[""MyForm""][""pseudo_salts""].value;")
 do H("  var ralf_salts = document.forms[""MyForm""][""ralf_salts""].value;")
 do H("  var file = document.forms[""MyForm""][""fileToUpload""].value;")
 
 ;do H("  var fileInput =  document.getElementById('fileToUpload');")
 ;do H("  var file = fileInput.files[0].name;")
 
 do H("  var date = document.forms[""MyForm""][""date""].value;")
 
 ;do H("  alert(pseudo_salts);")
 ;do H("  alert(ralf_salts);")
 ;do H("  alert(file);")
 ;do H("  alert(date);")
 ;do H("  parent._alert = new parent.Function(""alert(arguments[0]);"");");
 ;do H("  parent._alert('Test!');")
 
 ; ** TO DO
 ;do H("  if (!file.match('/[^/]*\.txt')) {alert('invalid filename '+file); return false;}")
 
 do H("  if (file != '' && date != '') {alert('Please enter a fixed date or upload file (not both)'); return false;}")
 do H("  if (file == '' && date == '') {alert('Please select a file, or enter a fixed date before proceeding'); return false;}")
 do H("  if (pseudo_salts == '?' || ralf_salts == '?') {alert('Please select a CompassSKID and RALFSKID before continuing'); return false;}")
 ;do H("  alert('here we go!');")
 do H("  return true;")
 do H("}")
 
 do H("function ajaxSubmit() {")
 do H("  var val = validateForm();")
 
 ;do H("  // alert('ajax '+val);")
 ;do H("  // if (val == true) {alert('truey');}")
 
 do H("  if (val == false) {return false;}")
 ;do H("  alert('do the ajax request');")
 do H("  if (!confirm('Continue?')) {return false;}")
 do H("  var form = document.getElementById('MyForm');")
 do H("  var formData = new FormData(form);")
 do H("  var xhr = new XMLHttpRequest();")
 
 do H("  xhr.addEventListener('readystatechange', onreadystatechangeHandler, false);")
 do H("  xhr.upload.addEventListener('progress', onprogressHandler, false);")
 
 do H("  xhr.open('POST', '/por4/run', true);")
 do H("  xhr.send(formData);")
 do H("  return false;")
 do H("}")
 
 do H("function onreadystatechangeHandler(evt) {")
 do H("  var status, text, readyState;")
 do H("  try {")
 do H("    readyState = evt.target.readyState;")
 do H("    text = evt.target.responseText;")
 do H("    status = evt.target.status;")
 do H("  }")
 do H("  catch(e) {")
 do H("    return;")
 do H("  }")
 do H("  if (readyState == 3 && status == '201' && evt.target.responseText) {")
 do H("    var status = document.getElementById('upload-status');")
 do H("    status.innerHTML += '<' + 'br>Success!';")
 do H("    var result = document.getElementById('result');")
 do H("    let obj = JSON.parse(event.target.responseText);")
 do H("    let json = JSON.stringify(obj);")
 do H("    console.log(json);")
 do H("    console.log(obj.upload.status);")
 do H("    var status = obj.upload.status;")
 
 ;do H("    result.innerHTML = '<p>The server saw it as:</p><pre>' + evt.target.responseText + '</pre>';")
 do H("    result.innerHTML = '<p>The servers response: ' + status + '</p>';")  
    
 do H("  }")
 do H("}")
 
 do H("function onprogressHandler(evt) {")
 do H("  var div = document.getElementById('progress');")
 do H("  var percent = evt.loaded/evt.total*100;")
 do H("  div.innerHTML = 'Progress: ' + percent + '%';")
 do H("}")
 
 do H("function resetFile() {")
 do H("  const file = document.querySelector('.fileToUpload');")
 do H("  file.value = '';")
 do H("}")
 
 do H("async function ajaxStatus() {")
 ;do H("  var url = '/por4/status';")
 ;do H("  let response = await fetch(url);")
 ;do H("  let response = await this.http.get(url).toPromise();")
 do H("  $.ajax({")
 do H("    url: '/por4/status',")
 do H("    async: false,")
 do H("    dataType: 'json',")
 do H("    success: function (response) {")
 do H("       //let obj  = JSON.parse(response);")
 do H("       //alert(response.text);")
 do H("       //console.log(response.json);")
 do H("       //console.log(response.text);")
 do H("       alert(response.upload.status);")
 do H("    }")
 do H("  });")
 do H("}")
 
 do H("</script>")
 
 do H("<h1 style=""background-color:DodgerBlue;"">PoR utility v0.4</h1>")
 
 do H("<font size=""3"" face=""Courier New""><u><b>Fixed date</b></u><br></font>")
 
 ;do H("<p>Finds place of residence (PoR) for date entered (for all currently registed patients)</p>")
 do H("<p>For all currently registered patients return place of residence (PoR) and associated meta data for date entered</p>")
 
 do H("<font size=""3"" face=""Courier New""><u><b>File</b></u><br></font>")
 ;do H("<p>Finds place of residence (PoR) for each CompassSKID and event_date in uploaded file ")
 do H("<p>For each CompassSKID and event_date in uploaded file return PoR and associated meta data</p>")
 
 ;do H("(CompassSKID is a psuedo anonymised NHS number)</p>")
 
 ;do H("<font size=""3"" face=""Courier New""><b>Output</b></p></font>")
 ;do H("<table border=1 width=""50%"">")
 ;do H("<td>CompassSKID</td><td>pseudo anonymised nhs_number</td><tr>")
 ;do H("<td>PoR</td><td>RALFSKID (anonymised UPRN)</td><tr>")
 ;do H("<td>event_date</td><td>event date used to find PoR</td><tr>")
 ;do H("<td>prop_class</td><td>property classification code</td><tr>")
 ;do H("<td>prop_desc</td><td>property classification description</td><tr>")
 ;do H("<td>lsoa</td><td>lower layer super output area (2011)</td><tr>")
 ;do H("<td>msoa</td><td>middle layer super output area (2011)</td><tr>")
 ;do H("</table>")
 
 ;do H("<form action=""/por4/run"" method=""post"" enctype=""multipart/form-data"" onsubmit=""return validateForm()"" name=""MyForm"" id=""MyForm"">")
 
 ;do H("<form action=""/por4/run"" method=""post"" enctype=""multipart/form-data"" name=""MyForm"" id=""MyForm"">")
 
 do H("<font size=""3"" face=""Courier New""><u><b>Inputs</b></u><br></font>")
 do H("</p>")
 
 do H("<form enctype=""multipart /form-data"" name=""MyForm"" id=""MyForm"">")
 
 do H("<font size=""2"" face=""Courier New"">")
 do H("<table border=1 width=""50%"">")
 do H("<td>Fixed date</td>")
 
 ;do H("<td><input type=""radio"" id=""date"" name=""groupme"" value=""date"" checked></td><tr>")
 
 do H("<td><input type=""date"" id=""date"" name=""date"" min=""1991-01-01"" max="""_$$TODAY()_"""></td><tr>")
 
 ;do H("<td>File</td><td><input type=""radio"" id=""file"" name=""groupme"" value=""file""></td><tr>")
 ;do H("<td>File (click Choose file, then Cancel button to remove)</td><td><input type=""file"" id=""fileToUpload"" name=""fileToUpload""></td><tr>")
 
 do H("<td>File</td><td><input type=""file"" class=""fileToUpload"" id=""fileToUpload"" name=""fileToUpload""/><tr>")
 do H("<td>CompassSKID name</td><td>"_$$COMBO1("pseudo_salts")_"</td><tr>")
 do H("<td>RALFSKID name</td><td>"_$$COMBO1("ralf_salts")_"</td><tr>")
 do H("<td>reset all inputs</td><td><button onclick=""resetFile()"">reset</button></td><tr>")
 
 ;do H("<td>&nbsp;</td>&nbsp;<td></td><tr>")
 ;do H("<tr>")
 ;do H("<td></td><td><input type=""submit"" name=""submit"" value=""Next""></td><tr>")
 ;do H("<td></td><td><button onclick=""ajaxSubmit()"">Ajax</button></td><tr>")
 
 do H("</table>")
 do H("</font>")
 do H("</form>")
 
 do H("<table style=""width:20%"">")
 
 do H("<td><button onclick=""resetFile()"">reset file chosen</button></td>")
 
 do H("<td><button onclick=""ajaxSubmit()"">Run</button></td>")
 ;do H("<td><button onclick=""resetFile()"">reset file chosen</button></td>")
 
 do H("</table>")
 do H("</p>")
 
 do OUTPUT
 
 ;do H("<fieldset>")
 ;do H("<legend>Fixed date or file upload?</legend>")
 
 ;do H("<div>")
 ;do H("<input type=""radio"" id=""date"" name=""groupme"" value=""date"" checked>")
 ;do H("<label for=""date"">Fixed date</label>")
 ;do H("</div>")
 
 ;do H("<div>")
 ;do H("<input type=""radio"" id=""file"" name=""groupme"" value=""file"">")
 ;do H("<label for=""file"">File</label>")
 ;do H("</div>")
 
 ;do H("</fieldset>")
 
 do H("<br>")
 do H("<font size=""3"" face=""Courier New""><u><b>Download</b></u></p></font>")
 
 
 do H("<p>Click on the Download button to download a copy of the Output from your last run</p>")
 do H("<p>Your last run was done on blah@blah</p>")
 do H("<p>You entered the following information to produce your last output:</p>")
 
 do H("<button onclick=""Download()"">Download</button>")
 
 do H("<button onclick=""ajaxStatus()"">Status</button>")
 
 do H("<p id=""upload-status""></p>")
 do H("<p id=""progress""></p>")
 do H("<pre id=""result""></pre>")
 
 do H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
STATUS(result,arguments) ;
 k ^TMP($job)
 ;s ^TMP($J,1)="user is: "_$get(un)_"!"
 s ^TMP($J,1)="{""upload"": { ""status"": ""hello hello""}}"
 set ^fred=$get(un)
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
