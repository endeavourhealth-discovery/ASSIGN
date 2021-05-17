UPRNB1 ;Best fit algorithms for UPRN match [ 05/11/2021  1:05 PM ]
 ;
match18(tpost,tstreet,tbno,tbuild,tflat,tloc)        ;
 ;Will match before match18a matches
 ;flat is range and treated as number, with building as street
 i tbuild'="",tflat?1n.n1"-"1n.n,tbno="" d
 .I '$D(^UPRNX("X5",tpost,tstreet,tflat*1)) d
 ..i $D(^UPRNX("X5",tpost,tbuild,tflat*1,"","")) d
 ...s matchrec="Pe,S<B,N<Fp,B>S,F>Np"
 ...S $P(ALG,"-",2)="match18z100"
 ...s matched=$$setuprns^UPRN("X5",tpost,tbuild,tflat*1,"","")
 q
