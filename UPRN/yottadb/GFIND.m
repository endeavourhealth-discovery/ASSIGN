GFIND ; ; 4/29/21 2:38pm
	N glb,str,query
	R "Which global? ",glb,!
	R "String? ",str,!
	F  S glb=$q(@glb) Q:glb=""  D
	. I glb[str!(@glb[str) W !,glb,"=",@glb
	. QUIT
	QUIT
	;