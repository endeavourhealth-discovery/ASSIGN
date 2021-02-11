SFTP ; ; 2/11/21 10:09am
 QUIT
 
RUN ;
 ; take a snap shot of /opt/os before running bash script
 D SNAP
 zsystem "cd /tmp;sudo ./expect2.sh"
 QUIT
 
SNAP ;
 n cmd,f,str,dir,line,d,t
 s cmd="ls -d /opt/os/* > /tmp/snap.txt"
 zsystem cmd
 s f="/tmp/snap.txt"
 c f
 o f:(readonly)
 set line=1
 set d=+$h,t=$p($h,",",2)
 f  u f r str q:$zeof  do
 .;u 0 w !,str
 .s dir=$p(str,"/",$l(str,"/"))
 .;u 0 w !,dir
 .S ^SNAP(d,t,line)=dir
 .S line=line+1
 .quit
 c f
 QUIT
 
CREATE ;
 D SH("BASH1","/tmp/expect2.sh")
 zsystem "chmod +x /tmp/expect2.sh"
 QUIT
 
SH(CALL,FILE) ;
 S user=^ICONFIG("SFTP","USER")
 S password=^ICONFIG("SFTP","PASSWORD")
 S ftpurl=^ICONFIG("SFTP","URL")
 CLOSE FILE
 O FILE:(newversion)
 S QF=0
 F I=1:1:50 DO  Q:QF
 .S L=$P($T(@CALL+I),";",2,9999)
 .I L["$user$" S L=$$TR^LIB(L,"$user$",user)
 .I L["$password$" S L=$$TR^LIB(L,"$password$",password)
 .I L["$ftpurl$" S L=$$TR^LIB(L,"$ftpurl$",ftpurl)
 .I L["** END **" S QF=1 QUIT
 .USE FILE W L,!
 .U 0 W L,!
 .QUIT
 CLOSE FILE
 QUIT
 
BASH1 ;
 ;#!/usr/bin/env expect
 ;cd /opt/os/
 ;set timeout 120
 ;spawn sftp $user$@$ftpurl$:/from-os
 ;#sleep 5
 ;#send -- "yes\r"
 ;expect "?*assword:*"
 ;sleep 5
 ;send -- "$password$\r"
 ;sleep 5
 ;send -- "get -r *\r"
 ;sleep 30
 ;send -- "bye\r"
 ;** END **
