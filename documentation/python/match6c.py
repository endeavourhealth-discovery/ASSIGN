import yottadb
import os

def match6c(tpost,tstreet,tbno,tbuild,tflat):
 ZONE = tpost[:1]
 if tbuild != b'' or tflat != b'': return 0
 print(str(ZONE)+" "+str(tstreet)+" "+str(tbno)+" "+str(tpost))
 if yottadb.data("^UPRNX", ("X3", ZONE, tstreet, tbno, tpost)) == 0: return 0
 print(yottadb.data("^UPRNX", ("X3", ZONE, tstreet, tbno, tpost)))
 uprn = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, ""))
 # check there is only one possible match
 try:
  if yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn)): return 0
 except yottadb.YDBNodeEnd:
  pass
 table = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn, ""))
 key = yottadb.subscript_next("^UPRNX", (b"X3", ZONE, tstreet, tbno, tpost, uprn, table, ""))
 print(str(uprn) + " " + str(table) + " " + str(key))
 return uprn

# Set up environment variables
os.environ['ydb_dist'] = '/usr/local/lib/yottadb/current/'
os.environ['ydb_gbldir'] = '/home/scot/.yottadb/r2.00_x86_64/g/yottadb.gld'
os.environ['ydb_dir'] = '/home/scot/.yottadb'
os.environ['ydb_rel'] = 'r2.00_x86_64'
os.environ['ydb_routines'] = '/home/scot/.yottadb/r2.00_x86_64/r'

x = match6c(b"g838ey",b"haldane court",b"14/10",b"",b"")
if type(x)!=int: print(str(x, "utf-8"))
else:
 print(x)
