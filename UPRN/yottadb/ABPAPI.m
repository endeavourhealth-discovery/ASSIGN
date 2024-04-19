ABPAPI ; ; 11/7/23 3:00pm
	d STT
	quit
	;	
STT ;
	new json,token,b
	; get a list of data packages
	; get a token
	;S json=$$TOKEN()
	;D DECODE^VPRJSON($name(json),$name(b),$name(err))
	;S token=$get(b("access_token"))
	;i token="" w !,"no token" quit
	;w !,token
	D DATAPAKS
	quit
	;	
GETTOKEN() ;
	new json,b
	W !,"Getting a token"
	kill b
	S json=$$TOKEN()
	D DECODE^VPRJSON($name(json),$name(b),$name(err))
	S token=$get(b("access_token"))
	i token="" w !,"no token"
	quit token
	;	
DATAPAKS ;
	new token,b,a
	s token=$$GETTOKEN()
	W !,token
	S cmd="curl -s -H ""Authorization: Bearer "_token_""" ""https://api.os.uk/downloads/v1/dataPackages"""
	w !,cmd
	D RUN(cmd)
	;ZWR ^TRUN($J,*)
	set json=$$JSON()
	k b
	D DECODE^VPRJSON($name(json),$name(b),$name(err))
	w !
	;zwr b
	;	
	W !,"Which package are you interested in?"
	set a="",z=""
	f  s a=$o(b(a)) q:a=""  do
	. W !,a,". ",b(a,"id")," ",b(a,"name")
	. ; w !,"Versions:"
	. ; f  s z=$o(b(a,"versions",z)) q:z=""  do
	. ; . w !,z," ",b(a,"versions",z,"url")
	. quit
	;set J=json
A write !,"Select a data package? "
	read x
	if x="" G A
	if '$d(b(x)) goto A
	;	
	W !!,b(x,"name")
	W !,"Which version are you interested in?"
	f  s z=$o(b(x,"versions",z)) q:z=""  do
	. write !,z," supplyType: ",b(x,"versions",z,"supplyType")
	. write " created on: ",b(x,"versions",z,"createdOn")
	. write " id: ",b(x,"versions",z,"id")
	. quit
	;	
B write !,"Select a version? "
	read y
	if x="" G B
	i '$d(b(x,"versions",y)) goto B
	;	
	; get filename
	s token=$$GETTOKEN()
	; get versions url
	w !,b(x,"versions",y,"url")
	set url=b(x,"versions",y,"url")
	S cmd="curl -s -H ""Authorization: Bearer "_token_""" """_url_""""
	D RUN(cmd)
	set json=$$JSON()
	set J=json
	kill b
	D DECODE^VPRJSON($name(J),$name(b),$name(err))
	;zwr b
	;	
	w !,"Download which file? "
	s l=""
	f  s l=$o(b("downloads",l)) q:l=""  do
	. w !,l," ",b("downloads",l,"fileName")," size: ",b("downloads",l,"size")
	. quit
	;	
F W !,"Select a file? "
	read f
	I f="" goto F
	i '$d(b("downloads",f)) goto F
	set file=b("downloads",f,"fileName")
YN w !,"Download ",file," (y/n)? "
	r yn#1
	if yn="" g YN
	set yn=$$LC^LIB(yn)
	i "\y\n\"'[("\"_yn_"\") goto YN
	S dir=^ICONFIG("HUB","DIR")
	set url=b("downloads",f,"url")
	s token=$$GETTOKEN()
	set dir=^ICONFIG("HUB","DIR")
	S cmd="curl -L -H ""Authorization: Bearer "_token_""" """_url_""" --output """_dir_file_""""
	w !,cmd
	;do RUN(cmd)
	w !
	zsystem cmd
UNZIP W !,"Unzip?  might ask for sudo password (y/n)?"
	r yn#1
	i yn="" goto UNZIP
	set yn=$$LC^LIB(yn)
	i "\y\n\"'[("\"_yn_"\") goto UNZIP
	; get the contents of the zip
	set cmd="unzip -l "_dir_file
	D RUN(cmd)
	set l=""
	kill result
	f  s l=$o(^TRUN($J,l)) q:l=""  do
	. set ln=^(l)
	. if ln'[".csv" quit
	. s csv=$p(ln," ",$l(ln," "))
	. set result(dir_csv)=""
	. quit
	W !
	set cmd="sudo unzip "_dir_file_" -d "_dir
	zsystem cmd
	;	
GAWK write !,"do you want to gawk the files you have just unzipped (y/n)?"
	read yn#1
	i yn="" goto GAWK
	;	
	; a version of PAWK
	kill f
	s f(32)=dir_"ID32_Class_Records.csv" ; 4
	s f(15)=dir_"ID15_StreetDesc_Records.csv" ; 5
	s f(21)=dir_"ID21_BLPU_Records.csv" ; 1
	s f(28)=dir_"ID28_DPA_Records.csv" ; 3
	s f(24)=dir_"ID24_LPI_Records.csv" ; 2
	;	
	S i=""
	f  s i=$o(f(i)) q:i=""  do
	. s file=f(i)
	. close file
	. o file:(newversion:stream:nowrap:chset="M")
	. use file
	. ; BLPU, LPI, DPA, CLASS, STREET_DESC
	. set text=$select(i=32:4,i=15:5,i=21:1,i=28:3,i=24:2,1:"")
	. ;w "header",$c(10)
	. w $p($text(TEXT+text),"; ",2,99),$c(10)
	. quit
	;	
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
	;	
	s i=""
	f  s i=$o(f(i)) q:i=""  do
	. s file=f(i)
	. close file
	. quit
	quit
	;	
TOKEN() ;
	new key,secret,cmd
	set key=$get(^ICONFIG("HUB","KEY"))
	set secret=$get(^ICONFIG("HUB","SECRET"))
	set cmd="curl -s -X POST https://api.os.uk/oauth2/token/v1 -d ""grant_type=client_credentials"" -H ""Content-Type: application/x-www-form-urlencoded"" -u "_key_":"_secret ; _" --output /tmp/token.txt"
	;W !,cmd
	do RUN(cmd)
	;zwr ^TRUN($J,*)
	quit $$JSON()
	;	
JSON() ;
	new i,json
	set json=""
	f i=1:1 q:'$d(^TRUN($J,i))  s json=json_^(i)
	quit json
	;	
RUN(cmd) ;
	new i,str
	kill ^TRUN($j)
	O "D":(shell="/bin/sh":command=cmd:parse):0:"pipe"
	F i=1:1 U "D" R str#255 Q:$zeof  S ^TRUN($J,i)=str
	close "D"
	quit
	;
SPEED ;
	k ^SPEED
	s f="/mnt/d/output/api/AddressBasePremium_COU_2022-11-29_003.csv"
	c f
	;s f2="/mnt/d/output/api/speed.txt"
	;close f2
	;o f2:(newversion:stream:nowrap:chset="M")
	o f:(readonly)
	s c=1
	f  u f r str q:$zeof  do
	. i c#10000=0 use 0 w !,c
	. ;use f2 w str,!
	. s str=$e(str,1,$l(str)-1)
	. S ^SPEED(c)=str
	. s c=c+1
	. quit
	;quit
	close f ;,f2
	s f2="/mnt/d/output/api/speed.txt"
	o f2:(newversion:stream:nowrap:chset="M")
	f i=1:1 q:'$d(^SPEED(i))  use f2 w ^(i),! if i#10000=0 U 0 w !,i
	close f2
	quit
	; BLPU, LPI, DPA, CLASS, STREET_DESC
TEXT ;
	; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LOGICAL_STATUS","BLPU_STATE","BLPU_STATE_DATE","PARENT_UPRN","X_COORDINATE","Y_COORDINATE","LATITUDE","LONGITUDE","RPC","LOCAL_CUSTODIAN_CODE","COUNTRY","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","ADDRESSBASE_POSTAL","POSTCODE_LOCATOR","MULTI_OCC_COUNT"
	; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LPI_KEY","LANGUAGE","LOGICAL_STATUS","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","SAO_START_NUMBER","SAO_START_SUFFIX","SAO_END_NUMBER","SAO_END_SUFFIX","SAO_TEXT","PAO_START_NUMBER","PAO_START_SUFFIX","PAO_END_NUMBER","PAO_END_SUFFIX","PAO_TEXT","USRN","USRN_MATCH_INDICATOR","AREA_NAME","LEVEL","OFFICIAL_FLAG"
	; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","UDPRN","ORGANISATION_NAME","DEPARTMENT_NAME","SUB_BUILDING_NAME","BUILDING_NAME","BUILDING_NUMBER","DEPENDENT_THOROUGHFARE","THOROUGHFARE","DOUBLE_DEPENDENT_LOCALITY","DEPENDENT_LOCALITY","POST_TOWN","POSTCODE","POSTCODE_TYPE","DELIVERY_POINT_SUFFIX","WELSH_DEPENDENT_THOROUGHFARE","WELSH_THOROUGHFARE","WELSH_DOUBLE_DEPENDENT_LOCALITY","WELSH_DEPENDENT_LOCALITY","WELSH_POST_TOWN","PO_BOX_NUMBER","PROCESS_DATE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
	; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","CLASS_KEY","CLASSIFICATION_CODE","CLASS_SCHEME","SCHEME_VERSION","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
	; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","USRN","STREET_DESCRIPTION","LOCALITY","TOWN_NAME","ADMINISTRATIVE_AREA","LANGUAGE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"