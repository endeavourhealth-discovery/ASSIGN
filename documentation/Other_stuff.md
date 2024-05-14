# Other stuff

## Cannot get into YottDB?

%YDBENV-F-NOTBEFOREIMAGEJOURNAL backward rollback/recover not possible because region "DEFAULT" does not have before-image journaling
$ZSTATUS="150379506,Robustify+101^%YDBENV,%YDB-E-SETECODE, Non-empty value assigned to $ECODE (user-defined error trap)"
Sourcing /opt/mumps/ydb_env_set returned status 248

If you encounter such errors, try running the command below (make sure you have exported your $ydb environment variables before running the command):
```
$ydb_dist/mupip rundown -REGION DEFAULT
```

Additionally, you should receive the following message if the rundown is successful:
```
%YDB-I-MUFILRNDWNSUC, File /root/.yottadb/r1.38_x86_64/g/yottadb.dat successfully rundown
````