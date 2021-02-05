SOURCE ; ; 1/19/21 10:34am
STT(ids,UPRN) 
 set valg=$get(^ICONFIG("ALG-VERSION"))
 set vepoch=$get(^ICONFIG("EPOCH-PIPELINE"))
 
 I ids["org`",UPRN'="" do
 .s subid=$p(ids,"`",2)
 .S zh=+$h,zt=$p($h,",",2)
 .S ^SOURCE("T",UPRN,zh,zt)=$get(^temp($j,1))
 .S ^SOURCE("T",UPRN,zh,zt,"V")=valg
 .S ^SOURCE("T",UPRN,zh,zt,"E")=vepoch
 .S ^SOURCE("T",UPRN,zh,zt,"SUB")=subid
 .quit
 
 I ids["odsload`",UPRN'="" do
 .s odscode=$p(ids,"`",2)
 .S zh=+$h,zt=$p($h,",",2)
 .S ^SOURCE("ODS",UPRN,zh,zt)=$get(^temp($j,1))
 .S ^SOURCE("ODS",UPRN,zh,zt,"V")=valg
 .S ^SOURCE("ODS",UPRN,zh,zt,"E")=vepoch
 .S ^SOURCE("ODS",UPRN,zh,zt,"ODS")=odscode
 .quit
 quit
