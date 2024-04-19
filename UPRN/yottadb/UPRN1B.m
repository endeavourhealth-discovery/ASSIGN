UPRN1B ; ; 4/11/24 2:28pm
 quit
 
STT(dir,id) ; deltas.
 ;S abp="/opt/all"
 if $data(^DSYSTEM("COU",id)) write !,"change only update has alredy been processed" quit
 set abp=dir
 ;s ^DELTAS(1)=$H
 set id=$i(^COU)
 S ^COU(id,1)=$H_"~"_abp
 do IMPCLASS^UPRN1A
 do IMPSTR^UPRN1A
 do IMPBLP^UPRN1A
 do IMPDPA^UPRN1A
 do IMPLPI^UPRN1A
 ;s ^DELTAS(2)=$H
 S ^COU(id,2)=$H_"~"_abp
 set ^DSYSTEM("COU",id)=$h
 quit
