ABPAPI2 ; ; 4/16/24 12:46pm
 quit

ORDERDETS(id) 
 set x=$zsearch("/opt/all/"_id_"/*.fake")
 set x=$zsearch("/opt/all/"_id_"/"_id_"-Order_Details.txt")
 quit x
 
PROCESS ;
 new cmd,f,str,cou,id,dir
 set cmd="ls /opt/all/ > /tmp/tmp"_$j_".txt"
 zsystem cmd
 set f="/tmp/tmp"_$j_".txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .u 0 w !,str
 .I $D(^DSYSTEM("COU",str)) quit
 .set cou(str)=""
 .quit
 c f:delete
 ;w !
 ;zwr cou
 set id="",uprnind=0
 set zt=$o(^RUN(""),-1)+1
 f  s id=$order(cou(id)) q:id=""  do
 .set dir="/opt/all/"_id_"/"
 .d STT^UPRN1B(dir,id)
 .set uprnind=1
 .s ^RUN(zt)="d STT^UPRN1B("""_dir_""","""_id_""")"
 .s zt=zt+1
 .quit
 D:uprnind ^UPRNIND
 quit
 
DONE ; change only updates that have been processed previously
 ; Full created on: 2023-09-19
 S ^DSYSTEM("COU",6471504)=$h
 ; Change Only Update created on: 2023-10-13
 S ^DSYSTEM("COU",6482588)=$horolog
 ; Change Only Update created on: 2023-11-24
 S ^DSYSTEM("COU",6495547)=$h
 ; Change Only Update created on: 2024-01-05
 S ^DSYSTEM("COU",6510393)=$h
 quit
 
EMPTY ; yeah, I could have done rm /tmp/all/*.*
 new q
 s q="/tmp/all/*.*"
 for  set x=$zsearch(q) quit:x=""  do
 .s name=$zparse(x,"NAME")
 .s type=$zparse(x,"TYPE")
 .set f=name_type
 .set cmd="rm /tmp/all/"_f
 .w !,cmd
 .zsystem cmd
 .w !,$zsystem
 .quit
 quit
 
ALL ;
 new id
 kill b
 ;D EMPTY
 if '$data(^ICONFIG("COU-NAME")) write !,"cou package name does not exists" quit
 s token=$$GETTOKEN^ABPAPI()
 S cmd="curl -s -H ""Authorization: Bearer "_token_""" ""https://api.os.uk/downloads/v1/dataPackages"""
 D RUN^ABPAPI(cmd)
 set json=$$JSON^ABPAPI()
 ;W !,json
 set J=json
 D DECODE^VPRJSON($name(J),$name(b),$name(err))
 s l=""
 set cegutil=""
 f  s l=$o(b(l)) q:l=""  do
 .;w !,l," ",b(l,"id")," name: ",b(l,"name")
 .i b(l,"name")=^ICONFIG("COU-NAME") s cegutil=l
 .quit
 
 ;zwr b(cegutil,*)
 ;R *Y
 
 ;get all the versions
 ;set latest=$o(b(cegutil,"versions",""),-1)
 
 ; figure out what needs importing?
 kill changes
 do COU(cegutil,.changes,.b)
 
 I '$data(changes) write !,"no change only updates to download for ",^ICONFIG("COU-NAME") quit
 ;w !
 ;zwr changes
 ;w !
 ;read *Y
 
 ; 1 is always the latest version
 ;set url=b(cegutil,"versions",1,"url")
 
 ;kill:$d(b) ^V
 merge ^V=changes(cegutil)
 
 set l=""
 f  s l=$o(changes(cegutil,"version",l)) q:l=""  do
 .set url=changes(cegutil,"version",l,"url")
 .set id=changes(cegutil,"version",l,"id")
 .w !,url," ",id
 .d DOWNLOAD(url,id)
 .quit
 quit
 
 ;
DOWNLOAD(url,id) s token=$$GETTOKEN^ABPAPI()
 S cmd="curl -s -H ""Authorization: Bearer "_token_""" """_url_""""
 D RUN^ABPAPI(cmd)
 set json=$$JSON^ABPAPI()
 set J=json
 k b
 D DECODE^VPRJSON($name(J),$name(b),$name(err))
 zwr b
 ;quit
 
 zsystem "mkdir /opt/all/"
 zsystem "mkdir /opt/all/"_id_"/"
 
 set dir="/opt/all/"_id_"/"
 ; empty /tmp/all/
 s token=$$GETTOKEN^ABPAPI()
 set f="",c=1
 K ^TUNZIP($job)
 f  s f=$o(b("downloads",f)) q:f=""  do
 .set url=b("downloads",f,"url")
 .set file=b("downloads",f,"fileName")
 .I c#100=0 s token=$$GETTOKEN^ABPAPI()
 .S cmd="curl -L -H ""Authorization: Bearer "_token_""" """_url_""" --output """_dir_file_""""
 .set:file[".zip" ^TUNZIP($job,c)=file
 .set c=c+1
 .w !,cmd
 .zsystem cmd
 .quit
 do UNZIP(id)
 do GAWK(id)
 ;S ^DSYSTEM("COU",id)=$h
 quit
 
COU(cegutil,changes,b) ;
 new l,id
 s l=""
 f  s l=$o(b(cegutil,"versions",l)) q:l=""  do
 .set id=b(cegutil,"versions",l,"id")
 .;if $d(^DSYSTEM("COU",id)) quit
 .set supply=$$UC^LIB(b(cegutil,"versions",l,"supplyType"))
 .if supply="FULL" quit
 .if $$ORDERDETS(id)'="" quit
 .merge changes(cegutil,"version",l)=b(cegutil,"versions",l)
 .quit
 quit
 
UNZIP(id) ;
 set c=""
 f  s c=$o(^TUNZIP($J,c)) q:c=""  do
 .s zf=^TUNZIP($J,c)
 .s f="/opt/all/"_id_"/"_zf
 .set cmd="unzip -o "_f_" -d /opt/all/"_id_"/"
 .w !,cmd ; r *y
 .zsystem cmd
 .quit
 quit
 
GAWK(id) ;
 kill result,f
 
 s f(32)="/opt/all/"_id_"/ID32_Class_Records.csv"
 s f(32,"H")=$p($text(TEXT+4),"; ",2,999)
 s f(15)="/opt/all/"_id_"/ID15_StreetDesc_Records.csv"
 s f(15,"H")=$p($text(TEXT+5),"; ",2,999)
 s f(21)="/opt/all/"_id_"/ID21_BLPU_Records.csv"
 s f(21,"H")=$piece($text(TEXT+1),"; ",2,999)
 s f(28)="/opt/all/"_id_"/ID28_DPA_Records.csv"
 s f(28,"H")=$p($text(TEXT+3),"; ",2,999)
 s f(24)="/opt/all/"_id_"/ID24_LPI_Records.csv"
 s f(24,"H")=$p($text(TEXT+2),"; ",2,999)
 
 s x=$zsearch("/opt/all/"_id_"/*.fake")
 s q="/opt/all/"_id_"/*.csv"
 for  set x=$zsearch(q) quit:x=""  do
 .s name=$zparse(x,"NAME")
 .;i name'["AddressBasePremium" quit
 .s dir=$zparse(x,"DIRECTORY")
 .s type=$zparse(x,"TYPE")
 .s f=dir_name_type
 .s result(f)=""
 .quit
 
 set i=""
 f  s i=$o(f(i)) q:i=""  do
 . s file=f(i)
 . close file
 . o file:(newversion:stream:nowrap:chset="M")
 . use file
 . w f(i,"H"),$c(10)
 .;
 . quit
 
 s f=""
 f  s f=$o(result(f)) q:f=""  do
 . use 0 w !,f
 . close f
 . o f:(readonly)
 . s c=1
 . f  u f r str q:$zeof  do
 . . i c#10000=0 u 0 w !,c
 . . s id=$p(str,",",1)
 . . s file=$get(f(id))
 . . i file="" quit
 . . u file w str,$c(10)
 . . s c=c+1
 . . quit
 . close f
 . quit
 
 s i=""
 f  s i=$o(f(i)) q:i=""  do
 . s file=f(i)
 . close file
 . quit
 quit
 
TEXT ;
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LOGICAL_STATUS","BLPU_STATE","BLPU_STATE_DATE","PARENT_UPRN","X_COORDINATE","Y_COORDINATE","LATITUDE","LONGITUDE","RPC","LOCAL_CUSTODIAN_CODE","COUNTRY","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","ADDRESSBASE_POSTAL","POSTCODE_LOCATOR","MULTI_OCC_COUNT"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LPI_KEY","LANGUAGE","LOGICAL_STATUS","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","SAO_START_NUMBER","SAO_START_SUFFIX","SAO_END_NUMBER","SAO_END_SUFFIX","SAO_TEXT","PAO_START_NUMBER","PAO_START_SUFFIX","PAO_END_NUMBER","PAO_END_SUFFIX","PAO_TEXT","USRN","USRN_MATCH_INDICATOR","AREA_NAME","LEVEL","OFFICIAL_FLAG"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","UDPRN","ORGANISATION_NAME","DEPARTMENT_NAME","SUB_BUILDING_NAME","BUILDING_NAME","BUILDING_NUMBER","DEPENDENT_THOROUGHFARE","THOROUGHFARE","DOUBLE_DEPENDENT_LOCALITY","DEPENDENT_LOCALITY","POST_TOWN","POSTCODE","POSTCODE_TYPE","DELIVERY_POINT_SUFFIX","WELSH_DEPENDENT_THOROUGHFARE","WELSH_THOROUGHFARE","WELSH_DOUBLE_DEPENDENT_LOCALITY","WELSH_DEPENDENT_LOCALITY","WELSH_POST_TOWN","PO_BOX_NUMBER","PROCESS_DATE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","CLASS_KEY","CLASSIFICATION_CODE","CLASS_SCHEME","SCHEME_VERSION","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","USRN","STREET_DESCRIPTION","LOCALITY","TOWN_NAME","ADMINISTRATIVE_AREA","LANGUAGE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
