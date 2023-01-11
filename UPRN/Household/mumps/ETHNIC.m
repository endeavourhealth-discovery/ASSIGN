ETHNIC ; ; 12/21/22 11:34am
 quit
 
STT ;
 new sql,str,dbid,nhs16,nhs16term,nh5,nhs5term
 k ^ethnic,^ZD
 s sql="select * from [db_lookup].[dbo].[lu_ethnicity_nhs]"
 D RUN(sql)
 S f="/tmp/uprnrtns/ethnic.txt"
 c f
 o f:(readonly)
 u f r str,str
 f  u f r str q:$zeof  do
 .s dbid=$p(str,"~",5)
 .q:dbid=""
 .s nhs16=$p(str,"~",1)
 .s nhs16term=$p(str,"~",2)
 .s nhs5=$p(str,"~",3)
 .s nhs5term=$p(str,"~",4)
 .s ^ethnic(dbid)=nhs16_"~"_nhs16term_"~"_nhs5_"~"_nhs5term
 .set ^ZD(16,nhs16)=nhs16term
 .set ^ZD(5,nhs5)=nhs5term
 .quit
 close f
 quit
 
RUN(sql) ; 
 new H,U,P,CMD
 
 S H=^ICONFIG("MSSQL","HOST")
 S U=^ICONFIG("MSSQL","USER")
 S P=^ICONFIG("MSSQL","PASS")
 
 set sql=""""_sql_""""
 S CMD="/opt/mssql-tools/bin/sqlcmd -W -S "_H_" -U '"_U_"' -P '"_P_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/ethnic.txt"
 zsystem CMD
 i $zsystem'=0 w !,"something went wrong" r *y
 quit
