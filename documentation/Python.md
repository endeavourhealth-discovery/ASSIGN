# Installing and using the Python YottaDB plug-in

```
su fred (ensure that you switch to the same linux user that was used to install YottaDB)
sudo apt install python3-pip
sudo apt-get install libffi-dev
// export the yottadb environment variables before running the pip3 install.
pip3 install yottadb
```

Below is an example of how we could convert match6c^UPRN to Python, using the existing mumps Global structures:

```
import yottadb

def match6c(tpost,tstreet,tbno,tbuild,tflat):
 ZONE = tpost[:1]
 if tbuild != b'' or tflat != b'': return 0
 print(str(ZONE)+" "+str(tstreet)+" "+str(tbno)+" "+str(tpost))
 if yottadb.data("^UPRNX", ("X3", ZONE, tstreet, tbno, tpost)) == 0: return 0
 print(yottadb.data("^UPRNX", ("X3", ZONE, tstreet, tbno, tpost)))
 uprn = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, ""))
 try:
  if yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn)): return 0
 except yottadb.YDBNodeEnd:
  pass
 table = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn, ""))
 key = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn, table, ""))
 print(str(uprn) + " " + str(table) + " " + str(key))
 return uprn

x = match6c(b"g838ey",b"haldane court",b"14/10",b"",b"")
if type(x)!=int: print(str(x, "utf-8"))
else:
 print(x)
```

Traversing down a global in Mumps:
```
PS  ; 5/13/24 2:07pm
	;
UPRN(uprn) ;
	set uprn=$order(^UPRN("U",uprn))
	quit uprn
	;		
TABLE(uprn,table)
	set table=$order(^UPRN("U",uprn,table))
	quit table
	;	
KEY(uprn,table,key)
	set key=$order(^UPRN("U",uprn,table,key))
	quit key
	;	
STT ;
	new uprn,table,key
	set (uprn,table,key)=""
	for  set uprn=$$UPRN(uprn) quit:uprn=""  do
	. for  set table=$$TABLE(uprn,table) quit:table=""  do
	. . for  set key=$$KEY(uprn,table,key) quit:key=""  do
	. . . write !,^UPRN("U",uprn,table,key)
	quit
```

Python equivalent:
```
import yottadb

def next_uprn(uprn):
    try:
        return yottadb.subscript_next("^UPRN", (b"U", uprn))
    except yottadb.YDBNodeEnd:
        return b''

def next_table(uprn, table):
    try:
        return yottadb.subscript_next("^UPRN", (b"U", uprn, table))
    except yottadb.YDBNodeEnd:
        return b''

def next_key(uprn, table, key):
    try:
        return yottadb.subscript_next("^UPRN", (b"U", uprn, table, key))
    except yottadb.YDBNodeEnd:
        return b''

uprn = b''
while True:
    uprn = next_uprn(uprn)
    if uprn == b'':
        break
    table = b''
    while True:
        table = next_table(uprn, table)
        if table == b'':
            break
        print(str(uprn) + " " + str(table))
        key = b''
        while True:
          key = next_key(uprn, table, key)
          if key == b'':
            break
          data = str(yottadb.get("^UPRN",[b"U", uprn, table, key]),'utf-8')
          print(data)
```