## RALFs (Residential Anonymised Linkage Fields)

RALFs (Residential Anonymised Linkage Fields) can be used to link data with external sources, usually for research purposes. RALFs are generated from UPRNs (Unique Property Reference Numbers) using an encryption key.

An encryption key can be created and downloaded from OpenPseudonymiser (https://www.openpseudonymiser.org/). After uploading an encryption key using the REST interface, all subsequent file uploads will use the encryption key to create a RALF in the output. Note: The encryption key that you upload using the API must have an EncryptedSalt extension.  RALFs (Residential Anonymised Linkage Fields) can be used to link data with external sources, usually for research purposes.  RALFs are generated from UPRNs (Unique Property Reference Numbers) using an encryption key.

An encryption key can be created and downloaded from OpenPseudonymiser (https://www.openpseudonymiser.org/). After uploading an encryption key using the REST interface, all subsequent file uploads will use the encryption key to create a RALF in the output. Note: The encryption key that you upload using the API must have an EncryptedSalt extension.

## Uploading an Encryption Key
```
curl -u {username}:{password} -i -X POST -H "Content-Type: multipart/form-data" -F "file=@C:\Users\Paul\Downloads\uprn-match.EncryptedSalt" https://{url}/api2/fileupload2
```
- Example Response

```
HTTP/1.1 201 Created
Date: Thu, 06 Jun 2024 09:31:31 GMT
Content-Type: text/html
Content-Length: 33
Connection: keep-alive
Location: = la la la
WWW-Authenticate: Basic realm="=la la la"
Access-Control-Allow-Origin: *

{"upload": { "status": "SALTOK"}}
```

- Uploading a File

```
curl -u {username}:{password} -i -X POST -H "Content-Type: multipart/form-data" -F "file=@D:\Desktop dump\paul.txt" https://{url}/api2/fileupload2
```

- Example Response
```
HTTP/1.1 201 Created
Date: Thu, 06 Jun 2024 09:59:23 GMT
Content-Type: text/html
Content-Length: 29
Connection: keep-alive
Location: = la la la
WWW-Authenticate: Basic realm="la la la"
Access-Control-Allow-Origin: *

{"upload": { "status": "OK"}}
```

- Downloading the Output
```
curl -u {username}:{password} "https://{url}/api2/download3?filename=paul.txt" --output "d:\temp\zps-live.txt"
```

- Example Response
```
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   895  100   895    0     0   3483      0 --:--:-- --:--:-- --:--:--  3509
```

The code that creates the RALFs is written in Java. The Java source code can be found in the GitHub ASSIGN repository:
```
https://github.com/endeavourhealth-discovery/ASSIGN/tree/master/UPRN/java/LHSPseudonymise
```

- Deploying the Java Software

The JAR file that needs to be deployed after compiling the Java code is:
Generator-1.0-SNAPSHOT-jar-with-dependencies.jar.

The back-end MUMPS code (GETRALFS^RALF) uses a bash script to launch the JAR. The bash script needs to be called ralfs.sh.

```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
java -Xmx1024m -jar /tmp/Generator-1.0-SNAPSHOT-jar-with-dependencies.jar "$1" "$2" "$3" "$4"
```

- Steps to Deploy

1. Copy ralfs.sh and Generator-1.0-SNAPSHOT-jar-with-dependencies.jar to /tmp/.
2. Make ralfs.sh executable by running the following command:

```
cd /tmp/
chmod +x ralfs.sh
```
