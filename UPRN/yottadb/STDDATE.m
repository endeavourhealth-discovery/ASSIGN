STDDATE ;NEW PROGRAM [ 09/03/2007  1:51 PM ] ; 11/14/19 9:18am
 
 Q
 
 ;returns the $h of the last day of the month specified in ascii
 
ENDDAY(DT) 
 N OUT,MO,YR,Z
 S MO=$P(DT,".",2)
 S YR=$P(DT,".",3)
 S OUT=""
 F Z=31:-1:28 Q:OUT'=""  S OUT=$$HD^DAT(Z_"."_MO_"."_YR)
 Q OUT
 
 ;dt-full date e.g. 1.1.90
 ;add-duration e.g. 1
 ;type-d/m/y
 
ADD(DT,ADD,TYPE) 
 N HD,DOM,MON,YR,OUT
 S HD=$$HD^DAT(DT)
 ;S TMPHD=(HD-1) ;If leap year conversion ;LE
 I $TR(HD," ","")="" Q ""
 I TYPE="D" S HD=HD+ADD Q HD
 I TYPE="W" S HD=HD+(ADD*7) Q HD
 S DOM=$P(DT,".")
 S MON=$P(DT,".",2)
 S YR=$P(DT,".",3)
 I YR<100 S YR=YR+1900
 I TYPE="Y" D  Q OUT
 .S YR=YR+ADD
 .F  D  Q:OUT'=""
 ..S OUT=$$HD^DAT(DOM_"."_MON_"."_YR),DOM=DOM-1
 ..Q
 .Q
 F  Q:'ADD  D
 .I ADD>0 D  Q
 ..S MON=MON+1 I MON>12 S MON=1,YR=YR+1
 ..S ADD=ADD-1
 ..Q
 .S MON=MON-1 I MON<1 S MON=12,YR=YR+1
 .S ADD=ADD+1
 .Q
 F  D  Q:OUT'=""
 .S OUT=$$HD^DAT(DOM_"."_MON_"."_YR),DOM=DOM-1
 .Q
 ;I OUT="" S OUT=TMPHD  ;eg. 29.2.96 + 3 years = no date
 Q OUT
 
MON(M) S M=+M
 Q $S(M=1:"January",M=2:"February",M=3:"March",M=4:"April",M=5:"May",M=6:"June",M=7:"July",M=8:"August",M=9:"September",M=10:"October",M=11:"November",M=12:"December",1:"")
 ;//////////////////////////////////////////////////////////////////////
 ;return the week day from a $H date
 ;//////////////////////////////////////////////////////////////////////
DAY(date) 
 Q $P("Thursday Friday Saturday Sunday Monday Tuesday Wednesday"," ",date#7+1)
 ;//////////////////////////////////////////////////////////////////////
 ;format a $H date according to a format string. EG:
 ;        write $$FORMDATE^STDDATE($H,"longday~ ~longmon~ ~D~, ~CC~YY")
 ;would display:
 ;        Wednesday May 14, 1997
 ;all format fields are separated by tilda's (~)
 ;anything not recognised is display as a literal
 ;D,M,Y      - Unpadded number as in 4/3/7
 ;DD,MM,YY   - Zero padded number as in 04/03/07
 ;CC         - Century number as in 4/3/1997
 ;mon        - Short month text - as in 4-Aug-97
 ;longmon    - Long month text - as in August 4, 1997
 ;day        - Short day - as in Mon 4/3/97
 ;longday    - Long day - as in Monday 4/3/97
 ;//////////////////////////////////////////////////////////////////////
FORMDATE(date,format) 
 N return,day,month,year,str,cent,loop
 S str=$$HD(date,1)
 S day=$P(str,".",1)
 S month=$P(str,".",2)
 S year=$P(str,".",3)
 ;I date<58074 S year="19"_year
 
 S return=""
 F loop=1:1:$L(format,"~") D
 .S pce=$P(format,"~",loop)
 .I pce="D" S return=return_day Q
 .I pce="M" S return=return_month Q
 .I pce="Y" S return=return_$E(year,1,4) Q
 .I pce="DD" S return=return_$TR($J(day,2)," ",0) Q
 .I pce="MM" S return=return_$TR($J(month,2)," ",0) Q
 .I pce="YY" S return=return_$TR($J($E(year,1,4),2)," ",0) Q
 .I pce="CC" Q   ;SHA sbid 25200 - YY=yyyy S return=return_$E(year,1,2) Q
 .I pce="mon" S return=return_$E($$MON(month),1,3) Q
 .I pce="longmon" S return=return_$$MON(month) Q
 .I pce="day" S return=return_$E($$DAY(date),1,3) Q
 .I pce="longday" S return=return_$$DAY(date) Q
 .S return=return_pce
 .Q
 Q return
 ;//////////////////////////////////////////////////////////////////////
 ;see FORMDATE above
 ;hh       - 12 hour - space padded
 ;HH       - 24 hour - zero padded
 ;MM       - Minutes - zero padded
 ;FM       - Full time in minutes eg 90mins
 ;SS       - Seconds - zero padded
 ;P        - Period - am or pm
 ;//////////////////////////////////////////////////////////////////////
FORMTIME(time,format) 
 N return,hours12,hours24,mins,secs,loop,pce
 S (return,hours12,hours24,mins,secs,loop,pce)=""
 
 I time<0 D
 .S return="-"
 .S time=time*(-1)    ;make positive
 .Q
 
 I $L(time,",")>1 S time=$P(time,",",2)
 S hours24=time\(60*60)
 S hours12=hours24
 
 S period="am"
 I hours24'<12 S hours12=hours12-12,period="pm"
 
 S mins=(time\60)#60
 S secs=(time#60)\1
 F loop=1:1:$L(format,"~") D
 .S pce=$P(format,"~",loop)
 .I pce="hh" S return=return_$J(hours12,2) Q
 .I pce="HH" S return=return_$TR($J(hours24,2)," ","0") Q
 .I pce="MM" S return=return_$TR($J(mins,2)," ","0") Q
 .I pce="SS" S return=return_$TR($J(secs,2)," ","0") Q
 .I pce="P" S return=return_period Q
 .I pce="FM" S return=return_(time\60) Q
 .S return=return_pce
 .Q
 Q return
 ;//////////////////////////////////////////////////////////////////////
 ;$H -> DD.MM.YY
 ;//////////////////////////////////////////////////////////////////////
HD(date,longcent) 
 I $G(date)="" Q "Unknown"
 N day,loop,leap,month,%R,year
 S longcent=$G(longcent,1)    ;4 figure century  1=yes, 0=no
 S date=date>21914+date
 S leap=date\1461
 S %R=date#1461
 S year=leap*4+1841+(%R\365)
 S day=%R#365
 S month=1
 I %R=1460,leap'=14 S day=365,year=year-1
 F loop=31,(%R>1154)&(leap'=14)+28,31,30,31,30,31,31,30,31,30 Q:loop'<day  S month=month+1,day=day-loop
 I day=0 S year=year-1,month=12,day=31
 I longcent="",$E(year,1,2)="19" S year=$E(year,3,4)
 Q $TR($J(day,2)," ","0")_"."_$TR($J(month,2)," ","0")_"."_$TR($J(year,2)," ","0")
 ;//////////////////////////////////////////////////////////////////////
 ;DD.MM.YY -> $H
 ;//////////////////////////////////////////////////////////////////////
DH(date) 
 N return,loop,leap,str
 
 S str=""
 F loop=1:1:$L(date) D
 .I $E(date,loop)?1N S str=str_$E(date,loop)
 .E  I $E(str,$L(str))'="." S str=str_"."
 .Q
 S date=str
 
 S day=$P(date,".",1)
 Q:(day="")!(day'?1N.N)!(day>31) ""
 S month=$P(date,".",2)
 Q:(month="")!(month'?1N.N)!(month>12) ""
 S year=$P(date,".",3)
 Q:year=""!(year'?1N.N) ""
 
 I year<100 S year=19_year                   ;just you wait 'til 2000 :(
 
 S loop=year-1\4-(year-1\100)+(year-1\400)-446
 S return=366*loop+(year-1841-loop*365)+day
 
 D
 .I year#4 S leap=28 Q
 .I year#100 S leap=29 Q
 .I year#400 S leap=28 Q
 .S leap=29
 .Q
 
 F loop=31,leap,31,30,31,30,31,31,30,31,30,31 D  Q:month=0
 .S month=month-1 
 .Q:month=0
 .S return=return+loop
 .Q
 S return=$TR($J(return,5)," ","0")     ;always 5 numbers long!
 I day'>loop*day>0 Q return
 Q ""
 
HD0(var) Q $$DH^DAT(var)     ; $h -> date format
 
HDT(var) Q $$HDT^LIBDAT(var)   ; $h -> date and time
 
HT(var) Q $$TH^DAT(var)     ; $h -> time
 
TH(var) Q $$HT^DAT(var)     ; time -> $h
 
DA(var) Q $$AD^LIB(var)     ; date -> ascii
 
AD(var) Q $$DA^LIB(var)     ; ascii -> date
 
DH0(var) Q $$HD^DAT(var)     ; date -> +$h
 
DOW(var) Q ((var+3)#7)+1     ; returns day of the week 1 = mon, 7 = sun
 
HR(var) Q $$RV^LIB($$DA($$HD(var)))  ; $h -> reverse ascii
 
RH(var) Q $$DH($$AD($$RV^LIB(var)))   ; reverse asci -> $h
 ;
CENT4VAL(date)  ;Validate/Force 4 figure centuries  dd.mm.yyyy  ;See IOS dates
 N valid
 S valid=1
 S date=$G(date)
 I date="" Q valid
 S date=$TR(date,"/",".")                ;dd/mm/yyyy to dd.mm.yyyy
 S date=$TR(date," ",".")                ;dd mm yyyy to dd.mm.yyyy
 I $L(date,".")-1'=2 S valid=0           ;not full date
 I $L($P(date,".",3))'=4 S valid=0       ;not valid dd.mm.yyyy
 I valid=0 D
 .D MSG^STDLIB("Four figure year required - dd.mm.ccyy",1,1,3,1)  ;DB 27/10/98 for 4.3d
 .Q
 Q valid
 ;
 ;
DEFAULT(date,extrin) 
 ;pass date as a call by reference, if extrin = 0
 ;
 ;allways default to current century
 n year,curcent,ypiece
 s date=$tr(date," ",".")
 s date=$tr(date,"/",".")
 s ypiece=$l(date,".")
 s year=$p(date,".",ypiece)
 i $p(date,".",ypiece)>2099 s date=""
 I $l(year)>2 G DEFAULT1    ;already ok, or invalid
 i year'?1n.n G DEFAULT1
 s year=$tr($j(year,2)," ",0)
 s curcent=$E($P($$HD(+$H,1),".",3),1,2)
 s $p(date,".",ypiece)=curcent_year
 i $p(date,".",ypiece)>2099 s date=""
 i $l(date,".")>1 S $P(date,".")=$TR($J($P(date,"."),2)," ","0")    ;DB 12/11/98 - for PS
 i $l(date,".")=3 S $P(date,".",2)=$TR($J($P(date,".",2),2)," ","0")    ;DB 12/11/98 - for PS
DEFAULT1 
 i +$G(extrin) q date              ;Extrinsic function
 Q                                 ;call by reference
 
 ;##Packaged on 61128,37004 for (10552) uci/patch=29/2150
