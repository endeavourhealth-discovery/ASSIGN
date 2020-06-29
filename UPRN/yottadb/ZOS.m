10(sd) ; file exists
 set $ECODE=""
 set $ETRAP=""
 set $zstatus="1"
 open sd:(readonly:exception="goto B^ZOS")
 use sd:exception="goto EOF^ZOS"
 use sd read x ; use $principal write !,x
EOF;
 close sd
 quit $P($zstatus,",")
B;
  QUIT $P($zstatus,",")
  
6(dir) ; make dir
	zsystem "mkdir "_dir
	quit
	
8(dir) ; directory exists
	; delete
	; zsystem "rm /tmp/echo"_$j_".txt > /tmp/dump"_$j_".txt"
	; dir file.xxx 1> output.msg 2>&1
	
	zsystem "rm /tmp/echo"_$j_".txt > /tmp/dump"_$j_".txt 2>&1"
	; test dir exists
	zsystem "[ ! -d "_dir_" ]  && echo 'Directory not found' > /tmp/echo"_$j_".txt"
	; exists
	S res=$$10("/tmp/echo"_$j_".txt")
	set:res=1 res=0
	quit res