FXLOG ; ; 12/21/22 2:42pm
 quit
 
SETUP ;
 S ^%W(17.6001,"B","GET","api/hh","STT^FXLOG",9375)=""
 S ^%W(17.6001,9375,"AUTH")=2
 quit
 
STT(result,arguments) ;
 new eventdate,nor,val,ret,line,ignoregms
 
 s eventdate=$get(arguments("event_date"))
 s ignoregms=+$get(arguments("ignoregms"))
 set val=eventdate
 S ^bob=eventdate
 i eventdate["-" s val=$$F^FX(eventdate)
 ;S ^bob=val
 s val=$$DH^STDDATE(val)
 if val="" S ^TMP($job,1)="invalid or missing event date" goto OUT ; YUK!
 
 s nor=$get(arguments("patient_id"))
 
 ;S ^bob=nor
 I '$data(^ASUM(nor)) S ^TMP($J,1)="patient does not exist" goto OUT
 
 ;S ret=$$PLACEATEVT^FX(nor,eventdate,1)
 S ret=$$PLACEATEVT^FX2(nor,eventdate,1,ignoregms)
 ;merge ^TMP($job)=^TLOG($job)
 set line=""
 f  s line=$o(^TLOG($J,line)) q:line=""  s ^TMP($J,line)=^(line)_"<br>"
 
OUT ;
 D DATA(nor)
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
DATA(nor) ;
 n id,c
 s id=""
 set c=$o(^TMP($J,""),-1)+1
 
 s deadtxt="not dead"
 i $d(^ASUM(nor,"dod")) s deadtxt="dead"
 S ^TMP($J,c)="<br>Patient is "_deadtxt_"<br>",c=c+1
 
 s ^TMP($J,c)="episode_of_care",c=c+1
 s ^TMP($J,c)="<br><table border=1>"
 s c=c+1
 s ^TMP($J,c)="<td>id</td><td>person_id</td><td>reg_type</td><td>date_reg</td><td>date_reg_end</td><td>org_id</td><tr>"
 s c=c+1
 f  s id=$o(^EOC(nor,id),-1) q:id=""  do
 .s rec=^EOC(nor,id)
 .s personid=$p(rec,"~",1),regtype=$p(rec,"~",2)
 .s datreg=$p(rec,"~",3),regend=$p(rec,"~",4)
 .s orgid=$piece(rec,"~",5)
 .s ^TMP($J,c)="<td>"_id_"</td><td>"_personid_"</td><td>("_regtype_") "_$get(^RTYPE(regtype))_"</td><td>"_datreg_"</td><td>"_regend_"</td><td>"_orgid_"</td><tr>"
 .s c=c+1
 .quit
 s ^TMP($J,c)="</table>",c=c+1
 
 s ^TMP($j,c)="<br>patient_address",c=c+1
 
 s ^TMP($J,c)="<br><table border=1>"
 s c=c+1
 s ^TMP($J,c)="<td>id</td><td>person_id</td><td>start_date</td><td>end_date</td><td>use</td><tr>"
 s c=c+1
 f  s id=$o(^ADR(nor,id),-1) q:id=""  do
 .s rec=^ADR(nor,id)
 .s personid=$p(rec,"~",1),start=$p(rec,"~",2),end=$p(rec,"~",3)
 .s use=$p(rec,"~",5)
 .S ^TMP($J,c)="<td>"_id_"</td><td>"_personid_"</td><td>"_start_"</td><td>"_end_"</td><td>("_use_") "_$get(^ADRTYPE(use))_"</td><tr>"
 .s c=c+1
 .quit
 
 s ^TMP($J,c)="</table>",c=c+1
 
 s ^TMP($J,c)="<br>patient_address_match",c=c+1
 S ^TMP($j,c)="<br><table border=1>",c=c+1
 s ^TMP($J,c)="<td>id</td><td>adr_id</td><td>ralf</td><td>class</td><td>qualifier</td><td>rule</td><td>match_date</td><tr>",c=c+1
 set adrid=""
 f  s adrid=$order(^ADR(nor,adrid)) q:adrid=""  do
 .f  s id=$o(^MATCH(adrid,id)) q:id=""  do
 ..s rec=^MATCH(adrid,id)
 ..s ralf=$p(rec,"~",2),class=$p(rec,"~",4)
 ..s qualifier=$p(rec,"~",9),rule=$p(rec,"~",10)
 ..s matchdate=$p(rec,"~",11)
 ..s ^TMP($J,c)="<td>"_id_"</td><td>"_adrid_"</td><td>"_ralf_"</td><td>"_class_"</td><td>"_qualifier_"</td><td>"_rule_"</td><td>"_matchdate_"</td><tr>"
 ..s c=$i(c)
 ..quit
 .quit
 
 s ^TMP($J,c)="</table>",c=c+1
 quit
