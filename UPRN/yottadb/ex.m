ex	;
5	;
	W !,"posr code : " r post
	i post="" q
	K ^x
	M ^x=^UPRNX("X5",$$lc^UPRNL($tr(post," ")))
	d ^G
	g 5
	Q
x1(post)	;
	K ^x
	n uprn
	M ^x=^UPRNX("X1",$$lc^UPRNL($tr(post," ")))
	s uprn=""
	for  s uprn=$O(^X(uprn)) q:uprn=""  d
	. M ^X(uprn)=^UPRN("U",uprn)
	D ^G
	Q
	;	