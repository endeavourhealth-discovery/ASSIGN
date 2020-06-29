BENCH ;
 QUIT
CNT ;
 K ^CNT
 S S="",Q=""
 F  S S=$O(^PS(S)) Q:S=""  D 
 .F  S Q=$O(^PS(S,Q)) Q:Q=""  D
 ..S T=$$HT^STDDATE(S)
 ..S ^CNT(T)=$G(^CNT(T))+1
 ..S ^CNT(T,"Q")=Q
 ..Q
 .QUIT
 QUIT
FILE ;
 K ^PS
 S FILE="/tmp/APR-2019/ID21_BLPU_Records.csv",C=0
 c FILE
 o FILE:(readonly):0
 S C=0
 for i=1:1 use FILE read z q:$zeof  S S=$P($H,",",2),Q=$O(^PS(S,""),-1)+1 S ^PS(S,Q)=$h_"~"_z S C=C+1 I C#10000=0 u 0 W !,z ; U 0 w !,z
 
 close FILE
 QUIT
