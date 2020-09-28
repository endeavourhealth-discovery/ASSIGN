#!/bin/bash -xl

##########################
## Change node hostname ##
##########################
#export AWS_DEFAULT_REGION=eu-west-2
#INSTANCE_ID=$(ec2metadata --instance-id)
#SHORT_NODE_NAME=$(aws ec2 describe-tags --filter "Name=resource-id,Values=$INSTANCE_ID" | jq -r '.Tags[] | select(.Key == "Name") | .Value')
#NODE_DNS_NAME="$SHORT_NODE_NAME"
#echo $NODE_DNS_NAME > /etc/hostname
#echo "127.0.0.1 $NODE_DNS_NAME" >> /etc/hosts
#hostname $NODE_DNS_NAME

###################
## Install Yotta ##
###################

#cd ~
#wget https://raw.githubusercontent.com/robtweed/qewd/master/installers/install_yottadb.sh#source
#source install_yottadb.sh

# ***** MUST BE ROOT BEFORE RUNNING INSTALL ****

sudo apt-get install libgpgme11-dev
sudo apt-get install libgcrypt11-dev libgcrypt20-dev
sudo apt-get install libconfig-dev
# ui pops up
sudo apt-get install libssl-dev

mkdir /tmp/tmp ; wget -P /tmp/tmp https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
cd /tmp/tmp
chmod +x ydbinstall.sh
#sudo ./ydbinstall.sh --utf8 default --verbose
#sudo ./ydbinstall.sh
#install yotta 1.26
sudo ./ydbinstall.sh --installdir /usr/local/lib/yottadb/r126 r1.26

mkdir /root/.yottadb
mkdir /root/.yottadb/r1.26_x86_64
mkdir /root/.yottadb/r1.26_x86_64/g
mkdir /root/.yottadb/r1.26_x86_64/r
mkdir /root/.yottadb/r1.26_x86_64/o
mkdir /root/.yottadb/r1.26_x86_64/o/utf8

mkdir /tmp/mumps
cd /tmp/mumps

FILE=/tmp/yottadb.dat
if [ ! -f "$FILE" ]; then
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/r126/yottadb.dat
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/r126/yottadb.gld
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/r126/yottadb.mjl
fi

cp yottadb.* /root/.yottadb/r1.26_x86_64/g

# read -p "Pause : " n1

FILE=/tmp/mumps/G.m
if [ ! -f "$FILE" ]; then
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
fi

# tls-config
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/tls/gtmcrypt_config.libconfig

# service
wget https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/installer/MSTU

export ydb_dist=/usr/local/lib/yottadb/r126
export ydb_gbldir=/root/.yottadb/r1.26_x86_64/g/yottadb.gld
export ydb_dir=/root/.yottadb
export ydb_rel=r1.26_x86_64

mkdir /opt/apiuprn
mkdir /opt/apiuprn/certs

cp gtmcrypt_config.libconfig /opt/apiuprn

cp /tmp/mumps/*.m /root/.yottadb/r1.26_x86_64/r/

cd /usr/local/lib/yottadb/r126/plugin/gtmcrypt
tar x < source.tar
make && make install && make clean

uuidgen > /tmp/uuid.txt
uuid=$(cat '/tmp/uuid.txt')

./maskpass <<< $uuid > '/tmp/monkey.txt'

cut -d':' -f2- /tmp/monkey.txt > /tmp/monkey2.txt
cut -d' ' -f2- /tmp/monkey2.txt > /tmp/monkey3.txt

# required for MSTU service 
cp /tmp/monkey3.txt /opt/apiuprn/certs/monkey3.txt

monkey=$(cat '/tmp/monkey3.txt')

openssl genrsa -aes128 -passout pass:$uuid -out /opt/apiuprn/certs/mycert.key 2048
openssl req -new -key /opt/apiuprn/certs/mycert.key -passin pass:$uuid -subj '/C=UK/ST=Yorkshire/L=Leeds/CN=dummy' -out /opt/apiuprn/certs/mycert.csr
openssl req -x509 -days 3660 -sha256 -in /opt/apiuprn/certs/mycert.csr -key /opt/apiuprn/certs/mycert.key -passin pass:$uuid -out /opt/apiuprn/certs/mycert.pem

export ydb_dist=/usr/local/lib/yottadb/r126
export ydb_gbldir=/root/.yottadb/r1.26_x86_64/g/yottadb.gld
export ydb_dir=/root/.yottadb
export ydb_rel=r1.26_x86_64

$ydb_dist/mupip SET -NULL_SUBSCRIPTS=true -region DEFAULT

$ydb_dist/mupip set - journal=off -region '*'

$ydb_dist/mupip set -access_method=mm -region DEFAULT

monkey=$(cat '/tmp/monkey3.txt')

export gtmtls_passwd_dev=$monkey
export gtmcrypt_config="/opt/apiuprn/gtmcrypt_config.libconfig"
export ydb_routines=/root/.yottadb/r1.26_x86_64/r/

cd /root/.yottadb/r1.26_x86_64/r/
/usr/local/lib/yottadb/r126/mumps -run ^START

cp /tmp/mumps/MSTU /etc/init.d/MSTU
chmod +x /etc/init.d/MSTU
update-rc.d MSTU defaults

#reboot