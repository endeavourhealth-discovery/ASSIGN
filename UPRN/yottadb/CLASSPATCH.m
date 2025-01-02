CLASSPATCH ;
 quit

STT ;
 new z
 kill z
 
 s z(1)="CM06~?~Pharmacy"
 s z(2)="CR02EV~N~Electric Car Charging Station"
 s z(3)="CR06BA~?~Bar"
 s z(4)="CR06NC~?~Nightclub"
 s z(5)="CR06PH~?~Public House"
 s z(6)="CR08CS~?~Convenience Store"
 s z(7)="CR08SM~~Supermarket"
 s z(8)="CR09BS~?~Betting Shop"
 s z(9)="CR09OL~?~Off-licence"
 s z(10)="CT11CA~N~Road Bridge Over Canal"
 s z(11)="CT11MU~N~Road Bridge Over Multiple"
 s z(12)="CT11NN~N~Road Bridge Over No Network"
 s z(13)="CT11PA~N~Road Bridge Over Path"
 s z(14)="CT11RA~N~Road Bridge Over Railway"
 s z(15)="CT11RO~N~Road Bridge Over Road"
 s z(16)="CT11WA~N~Road Bridge Over Water"
 
 for i=1:1:16 do
 .set r=z(i)
 .set ite=$P(z(i),"~",1)
 .set include=$p(z(i),"~",2)
 .set term=$p(z(i),"~",3)
 .set ^UPRN("CLASSIFICATION",ite,"term")=term
 .set ^UPRN("CLASSIFICATION",ite,"residential")=include
 .quit
 quit
