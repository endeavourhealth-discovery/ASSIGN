#!/bin/bash -xl
cd /tmp/
TMPDIR=$(mktemp -d)
cd $TMPDIR
cp /root/.yottadb/r1.26_x86_64/r/*.m .
mkdir /tmp/git
cd /tmp/git
rm *
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/G.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/LIB.m
#wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/NUPRN.m
#wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/NUPRN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN1.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN3.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN4.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN5.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNA.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNHOOK.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNHOOK2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNL.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNL1.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNMGR.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNONS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNU.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNUI.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNW.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNX.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UTILS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/ZOS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/START.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/BASE64.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/EWEBRC4.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/ADDEXT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/CURL.m
#wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/PS.m
# UPRNTEST.m - important routine (services pipeline)
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNTEST.m
# Indexing
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNIND.m
# new stuff
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNUI2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/REG2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRNACT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN58.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UPRN59.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/THOU.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/UN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/BASELINE.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/GAWK.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/THOU.m

# Bench testing
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/BENCH.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/LIBDAT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/STDDATE.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/LIB.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/DAT.m

# M web-server routines
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJREQ.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJRSP.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJRUT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJSON.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJSOND.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJSONE.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJUJ01.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJUJ02.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJUJD.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/VPRJUJE.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/_WHOME.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/XLFUTL.m

service MSTU stop
cp -u *.m /root/.yottadb/r1.26_x86_64/r/
service MSTU start
