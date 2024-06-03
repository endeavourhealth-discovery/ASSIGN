# Installing ASSIGN and the mumps web services

Some of the instructions in this guide are derived from:
```
https://docs.yottadb.com/Plugins/ydbwebserver.html#tls-set-up-on-yottadb
```

```
adduser fred
adduser fred sudo
```

```
su fred
cd /home/fred/ (you usually always need to cd into this directory before running the next command that gets you to a mumps prompt)
/usr/local/lib/yottadb/latest/ydb (test that you can access mumps)
H (hang out of mumps)
```

```
mkdir /home/fred/apiuprn/
mkdir /home/fred/apiuprn/certs/

openssl genrsa -aes128 -passout pass:monkey1234 -out /home/fred/apiuprn/certs/mycert.key 2048
openssl req -new -key /home/fred/apiuprn/certs/mycert.key -passin pass:monkey1234 -subj '/C=UK/ST=Yorkshire/L=Leeds/CN=dummy' -out /home/fred/apiuprn/certs/mycert.csr
openssl req -x509 -days 3660 -sha256 -in /home/fred/apiuprn/certs/mycert.csr -key /home/fred/apiuprn/certs/mycert.key -passin pass:monkey1234 -out /home/fred/apiuprn/certs/mycert.pem
```

Create a file called ydbcrypt_config_fred.libconfig that defines the encryption strength and SSL version:
```
/home/fred/apiuprn/ydbcrypt_config_fred.libconfig:

tls: {
  dev: {
    format: "PEM";
    cert: "/home/fred/apiuprn/certs/mycert.pem";
    key:  "/home/fred/apiuprn/certs/mycert.key";
    ssl-options: "SSL_OP_NO_SSLv2:SSL_OP_NO_SSLv3:SSL_OP_NO_TLSv1:SSL_OP_NO_TLSv1_1";
    cipher-list: "ECDH+AESGCM:ECDH+CHACHA20:ECDH+AES256:!aNULL:!SHA1:!AESCCM";
  };
}
```

Run the commands to suppoort null subscripts in the mumps database, turn off journalling and make the access method MM:
```
export ydb_dist=/usr/local/lib/yottadb/latest/
export ydb_gbldir=/home/fred/.yottadb/r2.00_x86_64/g/yottadb.gld
export ydb_dir=/home/fred/.yottadb
export ydb_rel=r2.00_x86_64
export ydb_routines=/home/fred/.yottadb/r2.00_x86_64/r
export ydb_icu_version=70.1
export ydb_crypt_config="/home/fred/apiuprn/ydbcrypt_config_fred.libconfig"

$ydb_dist/mupip SET -NULL_SUBSCRIPTS=true -region DEFAULT
$ydb_dist/mupip set - journal=off -region 'DEFAULT'
$ydb_dist/mupip set -access_method=mm -region DEFAULT
$ydb_dist/mupip set -key_size=510 -region DEFAULT
```

Restore the ASSIGN code by downloading WGET.m from the ASSIGN github repository:
```
cd /tmp/
wget -q "https://raw.githubusercontent.com/endeavourhealth-discovery/uprn-match/master/UPRN/yottadb/WGET.m"
cp WGET.m /home/fred/.yottadb/r2.00_x86_64/r
cd /home/fred/
/usr/local/lib/yottadb/latest/ydb
D STT^WGET
H (hang out of mumps)
```

Find out the hash of your key password using the maskpass utility:
```
$ydb_dist/plugin/ydbcrypt/maskpass <<< 'monkey1234' | cut -d ":" -f2 | tr -d ' '
4CFFF47AA338C3AA24E0
export ydb_tls_passwd_dev="4CFFF47AA338C3AA24E0"
```

Start the mumps web services:
```
/usr/local/lib/yottadb/latest/ydb
job START^VPRJREQ(9080,"","dev")
```

To test that the web services are running OK:

In a browser navigate to:
```
https://192.168.0.41:9080/
```

Or, at a linux prompt run this curl command:
```
curl -i --insecure https://127.0.0.1:9080/
```
