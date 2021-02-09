SFTP ; ; 2/9/21 9:48am
 QUIT
 
RUN ;
 zsystem "cd /tmp;sudo ./expect2.sh"
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
