UPRN4 ;Import routine [ 06/16/2020  10:38 AM ]
 O 51:("C:\msm\shared\BestFitRank.txt":"W")
 u 51 w "{| class=""wikitable"" border=""1"""
 w !,"|-"
 W !,"| '''Rank'''"
 w !,"| '''Post code'''"
 w !,"| '''Street'''"
 w !,"| '''Number'''"
 w !,"| '''Building'''"
 w !,"| '''Flat'''"
 w !,"|-"
 f i=1:1 q:'$D(^UPRNS("BESTFIT",i))  d
 .s matchrec=^(i)
 .w !,"|-"
 .W !,"| "_i
 .f q=1:1:5 d
 ..s part=$p(matchrec,",",q)
 ..s degree=$$degree^UPRN2(part)
 ..w !,"| "_degree
 w !,"|}",!
 C 51
 Q
