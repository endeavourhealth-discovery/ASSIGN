GITDIFF ; ; 4/10/24 11:41am
 quit
 
STT ;
 s cmd="curl -H ""Accept: application/vnd.github.v3+json"" -o /tmp/git.json https://api.github.com/repos/endeavourhealth-discovery/ASSIGN/contents/UPRN/yottadb"
 zsystem cmd
 s f="/tmp/git.json"
 close f
 o f:(readonly)
 set j=""
 f  u f r str q:$zeof  s j=j_str
 close f
 
 s cmd="mkdir /tmp/git/; mkdir /tmp/git/diffs"
 zsystem cmd
 
 s cmd="rm /tmp/git/*.*; rm /tmp/git/diffs/*.*"
 zsystem cmd
 
 D DECODE^VPRJSON($name(j),$name(b),$name(err))
 s l="",q=0
 f  s l=$o(b(l)) q:l=""  do  q:q=1
 .s rtn=b(l,"name")
 .s z=$length(rtn,".")
 .set e=$p(rtn,".",z)
 .if e'="m" quit
 .set cmd="wget -q -P /tmp/git ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
 .w !,rtn
 .zsystem cmd
 .if $zsystem'=0 S q=1
 .quit
 
 if q=1 w !,"something went wrong downloading the routines from git" quit
 do LOAD
 do ALL
 
 quit
 
 ; patch an individual routine.
 ; D PATCH^GITDIFF("CQCSCHED.m")
PATCH(rtn) ; 
 new cmd
 set cmd="rm /tmp/git/"_rtn
 zsystem cmd
 set cmd="wget -q -P /tmp/git ""https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/"_rtn_""""
 zsystem cmd
 if $zsystem'=0 w !,"could not download ",rtn," from github.com" quit
 s ro=$p($p($p($zro,"(",2)," "),")")
 set cmd="cp /tmp/git/"_rtn_" "_ro_"/"_rtn
 ;W !,"copy? (y/n)"
 write !,cmd
YN W !,"copy? (y/n): "
 read yn#1
 set yn=$$LC^LIB(yn)
 if "\y\n\"'[("\"_yn_"\") G YN
 if yn="n" quit
 zsystem cmd
 i $zsystem'=0 w !,"Something went wrong copying the files" quit
 W !,"linking"
 ZLINK $P(rtn,".")
 quit
 
ALL ;
 new rtn
 s rtn=""
 f  s rtn=$o(^GIT(rtn)) q:rtn=""  do
 .D CMP(rtn)
 .quit
 quit
 
CMP(rtn) ;
 new l,diff
 set l="",diff=0
 if '$data(^ME(rtn)) w !,"environment does not contain ",rtn quit
 f  s l=$o(^GIT(rtn,l)) q:l=""  do
 .set git=^GIT(rtn,l)
 .set me=$get(^ME(rtn,l))
 .if me="" quit
 .if git'=me do
 ..;w !,git
 ..;w !,me
 ..;read *y
 ..set diff=1
 ..quit
 .quit
 
 if diff do
 .write !,rtn," is different"
 .D DUMP("^GIT",rtn)
 .D DUMP("^ME",rtn)
 .quit
 
 quit
 
DUMP(g,rtn) 
 new l,d
 set d="/tmp/git/diffs/"
 i g="^GIT" S f=d_rtn_".git"
 i g="^ME" set f=d_rtn_".me"
 ;w !,f r *y
 close f
 o f:(newversion:stream:nowrap:chset="M")
 
 s l=""
 f  s l=$o(@g@(rtn,l)) q:l=""  do
 .use f w @g@(rtn,l),!
 .quit
 
 close f
 quit
 
LOAD ;
 new x,z,a,ro
 
 kill ^GIT,^ME
 ;s a="/tmp/git/*.c"
 s x=$zsearch("/tmp/git/*.c")
 f  s x=$zsearch("/tmp/git/*.m") q:x=""  do
 .D SAVE(x,"^GIT")
 .quit
 
 s ro=$p($p($p($zro,"(",2)," "),")")
 s a=ro_"/*.m"
 s x=$zsearch("/tmp/git/*.c")
 f  s x=$zsearch(a) q:x=""  do
 .set z=$l(x,"/")
 .set rtn=$p(x,"/",z)
 .if $e(rtn,1,2)="XV" quit
 .do SAVE(x,"^ME")
 .w !,rtn
 .quit
 quit
 
SAVE(f,glob) ;
 new l,rtn,z
 s l=1
 w !,f
 set z=$l(f,"/")
 set rtn=$p(f,"/",z)
 w !,rtn
 close f
 o f:(readonly:nowrap:chset="M")
 f  u f r str q:$zeof  do
 .use 0 w !,str
 .set str=$$TR^LIB(str,$c(9),"")
 .set str=$$TR^LIB(str,$c(13),"")
 .set str=$$LT^LIB(str)
 .S @glob@(rtn,l)=str
 .s l=l+1
 .quit
 close f
 quit
