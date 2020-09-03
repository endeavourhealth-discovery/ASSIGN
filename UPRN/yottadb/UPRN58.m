UPRN58 ; ; 9/3/20 1:46pm
 N FILES
 
 W !,"BASELINE FOLDER? "
 R BDIR ; /tmp/newbaseline/
 
 W !,"EPOCH NUMBER? "
 R EPOCHNO ; 76
 
 W !,"EPOCH FOLDER? "
 R EPOCH ; /tmp/epoch77/
YN W !,"Continue (Y/N)? "
 R YN
 I "\Y\N\"'[("\"_YN_"\") G YN
 I YN="N" QUIT
 
 K ^BASE,^EPOCH
 S FILES(1)="ID15_StreetDesc_Records."_EPOCHNO_".csv"
 S FILES(2)="ID21_BLPU_Records."_EPOCHNO_".csv"
 S FILES(3)="ID24_LPI_Records."_EPOCHNO_".csv"
 S FILES(4)="ID28_DPA_Records."_EPOCHNO_".csv"
 S FILES(5)="ID32_Class_Records."_EPOCHNO_".csv"
 
 S F(1)="ID15_StreetDesc_Records.csv"
 S F(2)="ID21_BLPU_Records.csv"
 S F(3)="ID24_LPI_Records.csv"
 S F(4)="ID28_DPA_Records.csv"
 S F(5)="ID32_Class_Records.csv"
 
 ;S BDIR="/tmp/newbaseline/"
 ;S EPOC="/tmp/OUTPUT77/"
 ;S EPOC="/tmp/epoch77/"
 
 F I=1:1:5 DO
 .I $GET(FILES(I))="" Q
 .S F=BDIR_$GET(FILES(I))
 .S C=0
 .C F
 .O F:(readonly)
 .F  U F R STR Q:$ZEOF  DO
 ..;U 0 W !,STR R *Y
 ..S UPRN=$P(STR,",",4)
 ..S ^BASE(I,UPRN)=STR
 ..S C=C+1
 ..I C#10000=0 U 0 W ".",I S C=0
 ..QUIT
 .C F
 .QUIT
 ;QUIT
 
 F I=1:1:5 DO
 .S F=EPOC_F(I)
 .S C=0
 .C F
 .O F:(readonly)
 .F  U F R STR Q:$ZEOF  DO
 ..;U 0 W !,STR R *Y
 ..S UPRN=$P(STR,",",4)
 ..S ^EPOCH(I,UPRN)=STR
 ..S C=C+1
 ..I C#10000=0 U 0 W ".",I S C=0
 ..QUIT
 .C F
 .QUIT
 
 QUIT
