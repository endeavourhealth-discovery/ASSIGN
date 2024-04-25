UPRN1B ; ; 4/24/24 10:23am
 quit
 
STT(dir,did) ; deltas.
 ;S abp="/opt/all"
 new zid
 
 if $data(^DSYSTEM("COU",id)) write !,"change only update has already been processed" quit
 set abp=dir
 
 W !,abp
 
 set zid=$i(^COU)
 S ^COU(zid,1)=$H_"~"_abp
 do IMPCLASS^UPRN1A
 do IMPSTR^UPRN1A
 do IMPBLP^UPRN1A
 do IMPDPA^UPRN1A
 do IMPLPI^UPRN1A
 
 S ^COU(zid,2)=$H_"~"_abp
 set ^DSYSTEM("COU",did)=$h
 quit
