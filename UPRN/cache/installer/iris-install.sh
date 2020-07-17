#!/bin/bash -xl
##########################
## Change node hostname ##
##########################
export AWS_DEFAULT_REGION=eu-west-2
INSTANCE_ID=$(ec2metadata --instance-id)
SHORT_NODE_NAME=$(aws ec2 describe-tags --filter "Name=resource-id,Values=$INSTANCE_ID" | jq -r '.Tags[] | select(.Key == "Name") | .Value')
NODE_DNS_NAME="$SHORT_NODE_NAME"
echo $NODE_DNS_NAME > /etc/hostname
echo "127.0.0.1 $NODE_DNS_NAME" >> /etc/hosts
hostname $NODE_DNS_NAME
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
# Prep
mkdir /tmp/iriskit
chmod og+rx /tmp/iriskit
# Download git code
rm -r /tmp/MGIT
mkdir /tmp/MGIT
git clone https://github.com/endeavourhealth-discovery/M /tmp/MGIT/
# Download install package
aws s3 cp s3://live-deployment-endeavour/APIUPRN/IRISHealth-2020.1.0.217.1-lnxubuntux64.tar.gz /tmp/IRISHealth-2020.1.0.217.1-lnxubuntux64.tar.gz
# unzip
gunzip -c /tmp/IRISHealth-2020.1.0.217.1-lnxubuntux64.tar.gz | ( cd /tmp/iriskit ; tar xf - )
# unattended install
cd /tmp/iriskit/IRISHealth-2020.1.0.217.1-lnxubuntux64
ISC_PACKAGE_INSTANCENAME="IRIS" \
	 ISC_PACKAGE_INSTALLDIR="/opt/IRIS" \
	 ISC_PACKAGE_UNICODE="Y" \
 	 ISC_PACKAGE_INITIAL_SECURITY="Normal" \
 	 ISC_PACKAGE_USER_PASSWORD="BLAH" \
	 ./irisinstall_silent
# Download license file
aws s3 cp s3://live-deployment-endeavour/APIUPRN/iris.key /opt/IRIS/mgr/iris.key
# Download empty database
mkdir -p /opt/IRIS/mgr/DISCOVERY/stream
aws s3 cp s3://live-deployment-endeavour/APIUPRN/IRIS.DAT /opt/IRIS/mgr/DISCOVERY/.
# restart iris instance
iris restart IRIS
touch ./.rnd
touch /root/.rnd
sleep 10
irissession IRIS <<EOFF
_blah
BLAH
ZN "BLAH"
do \$System.OBJ.Load("/tmp/MGIT/UPRN/cache/mac/INSTALLER.xml","ck")
do ^INSTALLER
halt
EOFF