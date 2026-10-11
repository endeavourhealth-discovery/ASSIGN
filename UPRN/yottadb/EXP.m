EXP ; ; 9/4/23 9:49am
STT 
	;W !,$h
	;	
	S adrec="188 Lordship Road,Hackney,London,N16"
	s adrec=",5,Flat 1 Consort House,Albert Road,,London,NW7 4RX"
	s adrec="Flat 4,2,,Lewis Crescent,,London,NW10 0NR"
	s adrec="Apex Lodge,,Flat 9,Lyonsdown Road,New Barnet,Barnet,EN5 1JF"
	s adrec=",39,Room Flat c ,Park Road,High Barnet,Barnet,EN5 5SE"
	s adrec="Garrowsfield,,56,Dollis Valley Drive,,Barnet,EN5 2TY"
	S adrec="Garrowsfield,,68,Dollis Valley Drive,,Barnet,EN5 2TY"
	S adrec=",Room 3 7a,Queens Road,,London,NW4 2TH"
	S adrec=",,Room 2 44a,Station Road,,London,NW4 3SX"
	s adrec="Flat 2 ,,Lotus House,21-23 Lodge Lane,North Finchley,London,N12 8JG"
	S adrec="Basement Flat,236,,East Barnet Road,,Barnet,EN4 8TF"
	s adrec="Barbara Langstone House,,Room 101 315-317,Ballards Lane,,London,N12 8LZ"
	S adrec="Flat 3,2,,Tunley Road,,London,NW10 9JS"
	s adrec="Layron Court,,Room Flat 1 2a,Linden Road,,London,N11 1ER"
	s adrec="Flat 19,3,Sanderson Building,Wilkinson Close,,London,NW2 6GR"
	s adrec=",16,Room Flat 5 ,Woodstock Avenue,,London,NW11 9SL"
	S adrec="1 Gillender Street,,,,London,E33JW"
	S adrec="46B Odessa Road,,,,London,E79BH"
	s adrec="191A Milton Avenue,,,,London,E61BN"
	s adrec="142 Whitechapel Road,,,,London,E11HJ"
	s adrec="101 Selby Road,,,,London,E113ES"
	s adrec="82 Stileman House,Ackroyd Drive,,,London,E34AS"
	W !,adrec,!
	D SETSWAPS^UPRNU
	S ^TPARAMS($J,"neutral")=1
	D GETUPRN^UPRNMGR(adrec,"","","","","")
	s apiuprn=$O(^TUPRN($J,"MATCHED",""))
	;d tomatch^UPRN(adno,"5.5.1") ;Match 1 address
	;s directuprn=$O(^TUPRN($J,"MATCHED",""))
	w !,"getuprn : ",apiuprn
	I apiuprn="" q
	S rec=$q(^UPRN("U",apiuprn))
	W !,@rec
	f i=1:1:4 d
	. s rec=$q(@rec)
	. w !,@rec
	;w !,"tomatch : ",directuprn,!
	q