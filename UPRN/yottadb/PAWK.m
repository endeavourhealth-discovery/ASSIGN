PAWK ; ; 9/29/23 9:42am
 quit
 ;	
STT ;
 kill
 ;	
 s f(32)="/mnt/d/output/pawk/ID32_Class_Records.csv"
 s f(32,"H")=$p($text(TEXT+4),"; ",2,999)
 s f(15)="/mnt/d/output/pawk/ID15_StreetDesc_Records.csv"
 s f(15,"H")=$p($text(TEXT+5),"; ",2,999)
 s f(21)="/mnt/d/output/pawk/ID21_BLPU_Records.csv"
 s f(21,"H")=$piece($text(TEXT+1),"; ",2,999)
 s f(28)="/mnt/d/output/pawk/ID28_DPA_Records.csv"
 s f(28,"H")=$p($text(TEXT+3),"; ",2,999)
 s f(24)="/mnt/d/output/pawk/ID24_LPI_Records.csv"
 s f(24,"H")=$p($text(TEXT+2),"; ",2,999)
 ;	
 s q="/mnt/d/output/api/*.csv"
 for  set x=$zsearch(q) quit:x=""  do
 . s name=$zparse(x,"NAME")
 . s dir=$zparse(x,"DIRECTORY")
 . s type=$zparse(x,"TYPE")
 . s f=dir_name_type
 . s result(f)=""
 . w !,dir,name,type
 . quit
 ;	
 s i=""
 f  s i=$o(f(i)) q:i=""  do
 . s file=f(i)
 . close file
 . o file:(newversion:stream:nowrap:chset="M")
 . use file
 . w f(i,"H"),$c(10)
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
 ;	
 quit
 ;
 ; BLPU, LPI, DPA, CLASS, STREET_DESC
TEXT ;
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LOGICAL_STATUS","BLPU_STATE","BLPU_STATE_DATE","PARENT_UPRN","X_COORDINATE","Y_COORDINATE","LATITUDE","LONGITUDE","RPC","LOCAL_CUSTODIAN_CODE","COUNTRY","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","ADDRESSBASE_POSTAL","POSTCODE_LOCATOR","MULTI_OCC_COUNT"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","LPI_KEY","LANGUAGE","LOGICAL_STATUS","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE","SAO_START_NUMBER","SAO_START_SUFFIX","SAO_END_NUMBER","SAO_END_SUFFIX","SAO_TEXT","PAO_START_NUMBER","PAO_START_SUFFIX","PAO_END_NUMBER","PAO_END_SUFFIX","PAO_TEXT","USRN","USRN_MATCH_INDICATOR","AREA_NAME","LEVEL","OFFICIAL_FLAG"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","UDPRN","ORGANISATION_NAME","DEPARTMENT_NAME","SUB_BUILDING_NAME","BUILDING_NAME","BUILDING_NUMBER","DEPENDENT_THOROUGHFARE","THOROUGHFARE","DOUBLE_DEPENDENT_LOCALITY","DEPENDENT_LOCALITY","POST_TOWN","POSTCODE","POSTCODE_TYPE","DELIVERY_POINT_SUFFIX","WELSH_DEPENDENT_THOROUGHFARE","WELSH_THOROUGHFARE","WELSH_DOUBLE_DEPENDENT_LOCALITY","WELSH_DEPENDENT_LOCALITY","WELSH_POST_TOWN","PO_BOX_NUMBER","PROCESS_DATE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","UPRN","CLASS_KEY","CLASSIFICATION_CODE","CLASS_SCHEME","SCHEME_VERSION","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
 ; "RECORD_IDENTIFIER","CHANGE_TYPE","PRO_ORDER","USRN","STREET_DESCRIPTION","LOCALITY","TOWN_NAME","ADMINISTRATIVE_AREA","LANGUAGE","START_DATE","END_DATE","LAST_UPDATE_DATE","ENTRY_DATE"
