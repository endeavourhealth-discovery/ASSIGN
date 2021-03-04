MSQL ; ; 2/28/21 7:44pm
 ;
SET ;
 S ^%W(17.6001,"B","GET","m/sql2","STT^MSQL",6140)=""
 S ^%W(17.6001,"B","POST","m/runsql2","RUN^MSQL",6141)=""
 QUIT
 
STT(result,arguments) 
 ;
 K ^TMP($J)
 S ^ZHERE=1
 I '$$IP^UPRNUI() QUIT
 S ^ZHERE=2
 D H("<html>")
 D H("<head><title>SQL Test Form</title></head>")
 D H("<body>")
 D H("<form action=""/m/runsql2"" method=""post"">")
 D H("<h2>SQL Test Form</h2>")
 D H("<p></p>")
 D H("<textarea name=SQL rows=20 cols=140></textarea>")
 D H("<p></p>")
 D H("<input type=SUBMIT value='Execute SQL'>")
 D H("</form>")
 D H("</body>")
 D H("</html>")
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 QUIT
 
RUN(arguments,body,result) 
 K ^TMP($J)
 I '$$IP^UPRNUI() QUIT
 M ^MSQL2=body
 K ^MSQL
 ;S ^TMP($J,1)="{""sql"": { ""status"": ""OK""}}"
 ;set result("mime")="text/html"
 ;set result=$na(^TMP($J))
 S (sql,line)=""
 f  s line=$o(body(line)) q:line=""  set sql=sql_$$REL^UPRNUI(body(line))
 ;S ^MSQL(1)=sql
 S sql=$p(sql,"=",2,99999)
 S sql=$$TR^LIB(sql,$c(13,10)," ")
 S ^MSQL(1)=sql
 D RUNSQL^CQC2(sql)
 ;i error'="" s ^TMP($j,1)=error G X
 S (row,col)=""
 S C=1
 S ^TMP($J,C)="<table border=1>",C=C+1
 f  s row=$o(^mgsqls($j,0,0,row)) q:row=""  do
 .S data=""
 .f  s col=$o(^mgsqls($j,0,0,row,col)) q:col=""  do
 ..s data=data_"<td>"_^(col)_"</td>"
 ..quit
 .S ^TMP($j,C)=data_"<tr>"
 .S C=C+1
 .quit
 S ^TMP($J,C)="</table>"
 ;
 ;S ^TMP($J,1)="OK"
X set result("mime")="text/html"
 set result=$na(^TMP($J))
 QUIT 1
 
H(H) ;
 N c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=H_$c(13)_$c(10)
 QUIT
