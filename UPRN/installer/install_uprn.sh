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
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/r126/yottadb.dat
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/r126/yottadb.gld
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/r126/yottadb.mjl
fi

cp yottadb.* /root/.yottadb/r1.26_x86_64/g

# read -p "Pause : " n1

FILE=/tmp/mumps/G.m
if [ ! -f "$FILE" ]; then
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/G.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/LIB.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/NUPRN.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/NUPRN.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN1.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN2.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN3.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN4.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN5.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNA.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNHOOK.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNHOOK2.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNL.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNL1.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNMGR.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNONS.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNU.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNUI.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNW.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNX.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UTILS.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/ZOS.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/START.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/BASE64.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/EWEBRC4.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/ADDEXT.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/CURL.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/PS.m
	# Indexing
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNIND.m

	# Bench testing
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/BENCH.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/LIBDAT.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/STDDATE.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/LIB.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/DAT.m
	
	# M web-server routines
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJREQ.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJRSP.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJRUT.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSON.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSOND.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSONE.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJ01.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJ02.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJD.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJE.m
	wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/_WHOME.m
fi

# tls-config
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/tls/gtmcrypt_config.libconfig

# service
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/installer/MSTU

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