QA5 ; ; 7/8/21 8:07am
 K ^MERGE
 S C=1
 F I=1:1:4 DO
 .S F="/tmp/QAREPORT("_I_").txt"
 .C F
 .O F:(readonly)
 .F  U F R STR Q:$ZEOF  DO
 ..;U 0 W !,STR R *Y
 ..S ^MERGE(C)=$P(STR,$C(9),2,200)
 ..S C=C+1
 ..QUIT
 .CLOSE F
 .QUIT
 
 S F="/tmp/QAREPORT.nope.1.txt"
 O F:(readonly)
 F  U F R STR Q:$ZEOF  DO
 .; AVOID INCLUDING MISSING PATIENT_ADDRESS_MATCH RECORDS
 .I $P(STR,$C(9),21)="?" QUIT
 .S ^MERGE(C)=$P(STR,$C(9),2,200)
 .S C=C+1
 .QUIT
 CLOSE F
 
 S F="/tmp/QA_MERGE.txt"
 CLOSE F
 O F:(newversion)
 
 U F W "id",$C(9),"patient_address_id",$C(9),"patient_address_match_id",$C(9),"patient_address_string",$C(9)
 W "existing_epoch",$C(9),"existing_alg_version",$C(9),"existing_uprn",$C(9)
 W "existing_match_rule",$C(9),"existing_qualifier",$C(9),"existing_class_code",$C(9)
 W "existing_start_date",$C(9),"existing_postcode",$C(9),"new_epoch",$C(9),"new_alg_version",$C(9),"new_uprn",$C(9)
 W "new_match_rule",$C(9),"new_qualifier",$C(9),"new_class_code",$C(9),"new_start_date",$C(9),"new_postcode",$C(9)
 W "new_uprn_existing_epoch",$C(9),"new_uprn_new_epoch"
 W !
 
 S A=""
 F  S A=$O(^MERGE(A)) Q:A=""  DO
 .USE F W A,$C(9),^(A),!
 .QUIT
 CLOSE F
 
 QUIT
