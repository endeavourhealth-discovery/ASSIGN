UCL4 ; ; 4/13/23 8:36am
 new input,output,id,str,adrec,postcode,iadrec,count
 new del,b,csv,hdr
 new LOCALITY,NUMBER,ORG,POSTCODE,STREET,TOWN
 new ALG,QUAL,MATPATBUILD,MATPATFLAT
 new MATPATNUMBER,MATPATPSTCDE,MATPATSTRT
 new QUALITY,LAT,LONG,POINT,X
 new Y,CLASS,UPRN,zid
 
 kill ^TPARAMS($job)
 write !,"include full path"
in write !,"enter input file (. quit): "
 read input
 if input="." quit
 if $$10^ZOS(input)'=1 w !,"input file does not exist" goto in
out write !,"enter output file (. go back): "
 read output
 if output="." goto in
 
 set outdir=$p(output,"/",1,$l(output,"/")-1)_"/"
 if '$$8^ZOS(outdir) w !,"output directory does not exist" goto out
 ;w !,outdir r *y
 
COMM write !,"commercials (Y/N)?: "
 read comm#1
 if "\y\n\"'[("\"_$$LC^LIB(comm)_"\") goto COMM
 if $$LC^LIB(comm)="y" set ^TPARAMS($J,"commercials")=1
 set id=+$get(^UCL)+1
 set ^UCL=id
 ;set output="/tmp/output-"_id_".txt"
 use 0 w !,"output will get written to ",output
 close output
 open output:(newversion)
 close input
 open input:(readonly)
 s hdr="id"_$c(9)_"address_candidate"_$c(9)_"postcode"_$c(9)_"locality"_$c(9)_"number"_$c(9)_"organization"_$c(9)_"postcode"_$c(9)_"street"_$c(9)_"town"_$c(9)_"algorithm"_$c(9)_"qualifier"_$c(9)_"mp_building"_$c(9)_"mp_flat"_$c(9)_"mp_number"_$c(9)_"mp_postcode"_$c(9)_"mp_street"_$c(9)_"quality"_$c(9)_"latitude"_$c(9)_"logitude"_$c(9)_"point"_$c(9)_"X"_$c(9)_"Y"_$c(9)_"classification"_$c(9)_"uprn"
 use output w hdr,!
 set count=1
 for  use input read str quit:$zeof  do
 .if count#1000=0 u 0 write !,count
 .set zid=$piece(str,$char(9),1)
 .set adrec=$piece(str,$char(9),2)
 .set postcode=$piece(str,$c(9),3)
 .set iadrec=adrec_","_postcode
 .use 0 w !,zid,"~",iadrec
 .use output w zid,$char(9),adrec,$char(9),postcode,$char(9)
 .D GETUPRN^UPRNMGR(iadrec,"","","",0,0)
 .;use output write ^temp($j,1),$char(9)
 .K b
 .D DECODE^VPRJSON($name(^temp($j,1)),$name(b),$name(err))
 .set UPRN=$get(b("UPRN"))
 .set ALG=$get(b("Algorithm"))
 .set QUAL=$get(b("Qualifier"))
 .set MATPATBUILD=$get(b("Match_pattern","Building"))
 .set MATPATFLAT=$get(b("Match_pattern","Flat"))
 .set MATPATNUMBER=$get(b("Match_pattern","Number"))
 .set MATPATPSTCDE=$get(b("Match_pattern","Postcode"))
 .set MATPATSTRT=$get(b("Match_pattern","Street"))
 .set QUALITY=$get(b("Address_format"))
 .S (COORD,LAT,LONG,POINT,X,Y,CLASS)=""
 .if UPRN'="" do
 ..do GETUPRNI^UPRNMGR(uprn)
 ..S COORD=$piece($get(^UPRN("U",UPRN)),"~",7)
 ..S LAT=$P(COORD,",",3),LONG=$P(COORD,",",4)
 ..S POINT=$P(COORD,",",3),X=$P(COORD,",",1),Y=$P(COORD,",",2)
 ..S CLASS=$piece($get(^UPRN("CLASS",UPRN)),"~",1)
 ..;use output write ^temp($j,1),!
 ..quit
 .S LOCALITY=$get(b("ABPAddress","Locality"))
 .S NUMBER=$g(b("ABPAddress","Number"))
 .S ORG=$g(b("ABPAddress","Organisaton"))
 .S POSTCODE=$g(b("ABPAddress","Postcode"))
 .S STREET=$g(b("ABPAddress","Street"))
 .S TOWN=$g(b("ABPAddress","Town"))
 .S del=$char(9)
 .s csv=LOCALITY_del_NUMBER_del_ORG_del_POSTCODE_del_STREET_del_TOWN
 .set csv=csv_del_ALG_del_QUAL_del_MATPATBUILD_del_MATPATFLAT_del
 .s csv=csv_MATPATNUMBER_del_MATPATPSTCDE_del_MATPATSTRT_del
 .s csv=csv_QUALITY_del_$g(LAT)_del_$g(LONG)_del_$g(POINT)_del_$g(X)_del_$g(Y)_del_$g(CLASS)_del_UPRN
 .use output w csv,!
 .s count=count+1
 .quit
 close input,output
 quit
 
COUNT ;
 new uprn,t
 s uprn="",t=1
 f  s uprn=$o(^UPRN("U",uprn)) q:uprn=""  do
 .i t#10000=0 w !,t
 .s t=t+1
 .quit
 w !,"total: ",t
 quit
