START ;
	D SETUP^UPRNHOOK2
	D ^UPRNUI2
	D ^REG2
	w !,"starting web server"
	j START^VPRJREQ(9080,"","dev")
	w !,"started"
	quit

STOP	K ^VPRHTTP
	w !,"stopped"
	QUIT
