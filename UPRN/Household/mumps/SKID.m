SKID ; ; 11/21/22 12:04pm
 ; a background job that runs every night that converts nhs_numbers
 ; into pseudo nhs_numbers
 quit
 
STT ;
 new qf,i
 s qf=0
 kill ^ZPAT
 F i=1:1000000 do  quit:qf=1
 .set sql="select id, nhs_number from [compass_gp].[dbo].[patient] ORDER BY id OFFSET "_i_" ROWS FETCH NEXT "_(i+999999)_" ROWS ONLY;"
 .do RUN(sql)
 .s qf=$$COLLECT()
 .; test
 .;s qf=1
 .quit
 quit
 
WRITE ;
 ; write out the contents of ^ZPAT
 new id,nhsno
 set f="/tmp/uprnrtns/patients.txt"
 close f
 o f:(newversion)
 s id=""
 for  set id=$order(^ZPAT(id)) quit:id=""  do
 .set nhsno=^ZPAT(id)
 .u f w id,$char(9),nhsno,!
 .quit
 close f
 quit
 
TEST ;
 new f,str,f2,salt,cmd,skid
 s f="/tmp/uprnrtns/patients.txt"
 s test="/tmp/uprnrtns/patients_test.txt"
 o test:(newversion)
 c f
 o f:(readonly)
 f i=1:1:10 do
 .u f r str
 .;u 0 w !,str
 .use test w str,!
 .quit
 c f,test
 S skid=3
 s salt=^SALTS("pseudo_salts",skid,"salt")
 set cmd="/tmp/ralfs.sh /tmp/uprnrtns/patients_test.txt notused /tmp/uprnrtns/nhs_number_spit.txt "_salt
 w !,cmd
 zsystem cmd
 quit
 
SPIT(skid) ;
 new f,str
 K ^SPIT(skid)
 s f="/tmp/uprnrtns/nhs_number_spit.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .;use 0 w !,str r *y
 .set nor=$p(str,$c(9),1)
 .set pseudo=$p(str,$c(9),2)
 .set ^SPIT(skid,pseudo,nor)=""
 .quit
 close f
 quit
 
SKIDS ;
 new i
 for i=1:1:5 D RUNJAR(i)
 quit
 
RUNJAR(skid) ;
 new cmd,salt
 s salt=^SALTS("pseudo_salts",skid,"salt")
 set cmd="/tmp/ralfs.sh /tmp/uprnrtns/patients.txt notused /tmp/uprnrtns/nhs_number_spit.txt "_salt
 w !,cmd
 zsystem cmd
 D SPIT(skid)
 quit
 
COLLECT() ;
 new f,d,id,nhsno,str
 s f="/tmp/uprnrtns/patients.txt"
 c f
 o f:(readonly)
 u f r str,str,str
 if str="" close f q 1
 close f
 o f:(readonly)
 set d="~"
 f  u f r str q:$zeof  do
 .;u 0 w !,str
 .s id=$p(str,d,1)
 .if id'?1n.n quit
 .s nhsno=$p(str,d,2)
 .s ^ZPAT(id)=nhsno
 .quit
 close f
 quit 0
 
RUN(sql) ;
 new h,u,p,cmd
 S h=^ICONFIG("MSSQL","HOST")
 S u=^ICONFIG("MSSQL","USER")
 S p=^ICONFIG("MSSQL","PASS")
 set sql=""""_sql_""""
 S cmd="/opt/mssql-tools/bin/sqlcmd -W -S "_h_" -U '"_u_"' -P '"_p_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/patients.txt"
 w !,cmd
 zsystem cmd
 quit
