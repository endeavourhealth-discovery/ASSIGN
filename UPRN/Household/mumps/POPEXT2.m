POPEXT2 ; ; 12/29/22 2:29pm
 quit
 
SETUP ;
 S ^%W(17.6001,"B","GET","popext/ui","STT^POPEXT2",774411)=""
 S ^%W(17.6001,774411,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","popext/download","DOWNLOAD^POPEXT2",774412)=""
 S ^%W(17.6001,774412,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","popext/download/orgs","ORGS^POPEXT2",774414)=""
 S ^%W(17.6001,774414,"AUTH")=2
 
 S ^%W(17.6001,"B","GET","popext/test","STT2^POPEXT2",774450)=""
 S ^%W(17.6001,774450,"AUTH")=2
 quit
 
ORGS(result,arguments) ;
 k ^TMP($J)
 set c=1
 s f="/tmp/uprnrtns/orgs.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .s ^TMP($J,c)=str_$C(10)
 .s c=c+1
 .quit
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
DOWNLOAD(result,arguments) 
 ;S ^d=1
 ;m ^d=arguments
 set f=$get(arguments("f"))
 set fno=f
 set f=^F(f)
 ;s ^d=f
 o f:(readonly)
 set c=1
 K ^TF(fno)
 f  u f r str q:$zeof  do
 .s ^TF(fno,c)=str_$c(10)
 .s c=c+1
 .quit
 close f
 set result("mime")="text/html"
 set result=$na(^TF(fno))
 quit
 
H(h) ;
 new i
 s i=$o(^TMP($J,""),-1)+1
 s ^TMP($job,i)=h_$char(10)
 quit
 
STT2(result,arguments) 
 d H("<html>")
 d H("<body>")
 
 d H("<h2>Using the XMLHttpRequest Object</h2>")
 d H("<div id=""demo"">")
 d H("<button type=""button"" onclick=""downloadFile('/popext/download?f=1')"">extract 1</button>")
 d H("</div>")
 d H("<script>")
 
 d H("function downloadFile(urlToSend) {")
 d H("var req = new XMLHttpRequest();")
 d H("req.open(""GET"", urlToSend, true);")
 d H("req.responseType = ""blob"";")
 d H("req.onload = function (event) {")
 d H("var blob = req.response;")
 d H("var fileName = req.getResponseHeader(""fileName"") //if you have the fileName header available")
 d H("var link=document.createElement('a');")
 d H("link.href=window.URL.createObjectURL(blob);")
 d H("link.download=fileName;")
 d H("link.click();")
 d H("};")
 
 d H("req.send();")
 d H("}")
 
 d H("</script>")
 d H("</body>")
 d H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
STT(result,arguments) ;
 k ^TMP($J)
 s ^TMP($J,1)="<html>"
 S ^TMP($J,2)="<p><h2>It may take a couple of seconds to download after you click on the link!</h2></p>"
 ;s ^TMP($J,2)="click on a file to download<br>"
 set i="",l=3
 f  s i=$o(^F(i)) q:i=""  do
 .set z=i+1
 .s html="<a href=""/popext/download?f="_i_""" download=""popext"_z_".txt"">file "_z_"</a><br>"
 .s ^TMP($j,l)=html
 .s l=l+1
 .quit
 s href="<a href=""/popext/download/orgs"" download=""orgs.txt"">Organisations</a><br>"
 set ^TMP($j,l)=href
 
 set l=$i(l)
 
 set href="<a href=""/popext/download/ethnicity"" download=""ethnicity.txt"">Ethnicity code set</a><br>"
 
 set ^TMP($j,l)=href
 set l=$i(l)
 
 set ^TMP($job,l)="</html>"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
ZD ;
 n scheme,code,term
 s (scheme,code,term)="",d=$c(9)
 S f="/tmp/ethnic_set.txt"
 c f
 o f:(newversion)
 f  s scheme=$o(^ZD(scheme)) q:scheme=""  do
 .f  s code=$o(^ZD(scheme,code)) q:code=""  do
 ..s term=^(code)
 ..use f w scheme,d,code,d,term,!
 c f
 quit
