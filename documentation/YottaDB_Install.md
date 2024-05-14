# YottaDB install

``` linux
cd /tmp/
mkdir /tmp/tmp ; wget -P /tmp/tmp https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
cd /tmp/tmp/
chmod +x ydbinstall.sh
sudo ./ydbinstall.sh --octo --gui --encplugin --installdir /usr/local/lib/yottadb/latest
```