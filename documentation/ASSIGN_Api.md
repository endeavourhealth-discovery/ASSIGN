# UPRN-ASSIGN API

## An interface that allows a user to post an address candidate, that reponds with a UPRN and other meta data.

```
curl -u {username}:{password} {endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA
{"Address_format":"good","Postcode_quality":"good","Matched":true,"UPRN":"100023336956","Qualifier":"Best (residential) match","Classification":"RD04","ClassTerm":"Terraced","Algorithm":"10-match1","ABPAddress":{"Number":"10","Street":"Downing Street","Town":"City Of Westminster","Postcode":"SW1A 2AA"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}
```

```
>>> import requests
>>> resp = requests.get('{endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA', auth=({username}, {password}))
>>> resp_dict = resp.json()
>>> print(resp_dict.get('UPRN'))
100023336956
>>> resp
<Response [200]>
>>> resp.text
'{"Address_format":"good","Postcode_quality":"good","Matched":true,"UPRN":"100023336956","Qualifier":"Best (residential) match","Classification":"RD04","ClassTerm":"Terraced","Algorithm":"10-match1","ABPAddress":{"Number":"10","Street":"Downing Street","Town":"City Of Westminster","Postcode":"SW1A 2AA"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}\n'
```

## An interface that allows a user to upload a file of address candidates, that are processed immediately, after the file has been uploaded.

The address file to be uploaded must contain two columns separated by a single tab character with a .txt extension

The first line must not contain any header information

The first column is a unique numeric row id

The second column is an address string including a postcode at the end with a comma separating the address from the postcode

The third column is the postal region (not mandatory, but useful when you don't know the address candidates postcode)

Example records:-
```
1[tab]10 Downing St,Westminster,London,SW1A2AA
2[tab]10 Downing St,Westminster,London[tab]SW
3[tab]Bridge Street,London,SW1A 2LW
4[tab]221b Baker St,Marylebone,London,NW1 6XE
5[tab]3 Abbey Rd,St John's Wood,London,NW8 9AY
```

```
curl -u {username}:{password} -i -X POST -H "Content-Type: multipart/form-data" -F "file=@D:\test_in.txt" {endpoint}/api2/fileupload2
```

```
>>> url = '{endpoint}/api2/fileupload2'
>>> files = {'file': ('test.txt', open('D://test_in.txt', 'rb'), 'text/plain')} 
>>> r = requests.post(url, files=files, auth=('{username}', '{password}'))
>>> r.text
'{"upload": { "status": "OK"}}\n'
```

## An interface that allows a user to download a previously uploaded file.

```
curl -u {username}:{password} "{endpoint}/api2/download3?filename=paul.txt" --output "d:\test_out.txt"
```

```
>>> r = requests.get('{endpoint}/api2/download3?filename=test.txt', auth=('{username}', '{password}'))
>>> text_file = open("d:\\test_out.txt", "w")
>>> text_file.write(r.text)
>>> text_file.close()
```