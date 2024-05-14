import yottadb
import os

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

# Set up environment variables
os.environ['ydb_dist'] = '/usr/local/lib/yottadb/current/'
os.environ['ydb_gbldir'] = '/home/scot/.yottadb/r2.00_x86_64/g/yottadb.gld'
os.environ['ydb_dir'] = '/home/scot/.yottadb'
os.environ['ydb_rel'] = 'r2.00_x86_64'
os.environ['ydb_routines'] = '/home/scot/.yottadb/r2.00_x86_64/r'

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
