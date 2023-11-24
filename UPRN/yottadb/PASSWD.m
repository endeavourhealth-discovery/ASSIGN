PASSWD ; ; 11/24/23 12:49pm
 quit
 
MENU ;
 new opt,users
M W !,". (exit)"
 W !,"1. Add a user"
 W !,"2. List existing users"
 W !,"3. Delete a user"
 W !,"4. Change a users password"
 write !,"?: "
 read opt#1
 
 if opt="." quit
 if opt=1 D STT
 if opt=2 kill users D LIST(.users)
 if opt=3 D DELETE
 if opt=4 D AMNDPASS
 goto M
 
AMNDPASS ;
 new users,opt,pass,u,y
 write !,"Change a users password"
 kill users
 D LIST(.users)
Q W !,"? (. exit): "
 read opt
 if opt="" goto Q
 if opt="." quit
 i '$data(users(opt)) goto Q
 s u=users(opt)
P W !,"new password (. exit): "
 read pass
 if pass="" goto P
 if pass="." quit
 S y=$$TORCFOUR^EWEBRC4(pass,^ICONFIG("KEY"))
 set ^BUSER("USER",u)=y
 quit
 
DELETE new opt,users,u,yn
 W !,"Delete a user"
 kill users
 D LIST(.users)
D W !,"? (. exit)"
 read opt
 i opt="" goto D
 i opt="." quit
 i '$data(users(opt)) goto D
 s u=users(opt)
YND write !,"Delete "_u_"?: "
 read yn#1
 set yn=$$LC^LIB(yn)
 i ("\y\n\")'[yn goto YND
 K ^BUSER("USER",u)
 quit
 
STT ;
 new user,pass,yn,y
 
 w !,". (exit), ^ (go back)"
USER w !,"username? "
 read user
 if user="." quit
 if user=""!(user="^") goto USER
 if $data(^BUSER("USER",user)) w !,"user already exists" goto USER
 w !,"password? "
PASS read pass
 if pass="." quit
 if pass="^" goto USER
 if pass="" goto PASS
YN w !,"continue (y/n)?: "
 read yn#1
 set yn=$$LC^LIB(yn)
 i ("\y\n\")'[yn goto YN
 if yn="y" do
 .S y=$$TORCFOUR^EWEBRC4(pass,^ICONFIG("KEY"))
 .S ^BUSER("USER",user)=y
 .quit
 quit
 
LIST(users) ;
 new u,cnt
 W !!,"users:"
 s u="",cnt=1
 f  s u=$o(^BUSER("USER",u)) q:u=""  do
 .w !,cnt,". ",u
 .s users(cnt)=u
 .s cnt=$i(cnt)
 .quit
 write !
 quit
