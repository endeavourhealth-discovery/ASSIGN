ORGS ; ; 12/15/22 3:40pm
 quit
 
STT ;
 k ^ORG
 S sql="select * from [compass_gp].[dbo].organization"
 d RUN(sql)
 D COLL
 quit
 
COLL ;
 new f
 s f="/tmp/uprnrtns/all_orgs.txt"
 c f
 o f:(readonly)
 u f r str,str
 f  u f r str q:$zeof  do
 .s id=$p(str,"~",1)
 .s odscode=$p(str,"~",2)
 .s name=$p(str,"~",3)
 .s parent=$p(str,"~",7)
 .s ^ORG(id)=odscode_"~"_name_"~"_parent
 .quit
 close f
 quit
 
RUN(sql) ;
 S H=^ICONFIG("MSSQL","HOST")
 S U=^ICONFIG("MSSQL","USER")
 S P=^ICONFIG("MSSQL","PASS")
 
 set sql=""""_sql_""""
 S CMD="/opt/mssql-tools/bin/sqlcmd -W -S "_H_" -U '"_U_"' -P '"_P_"' -d compass_gp -Q "_sql_" -s ""~"" -W -o /tmp/uprnrtns/all_orgs.txt"
 zsystem CMD
 i $zsystem'=0 w !,"something went wrong" r *y
 quit
