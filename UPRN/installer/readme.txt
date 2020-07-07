https://blog.frd.mn/how-to-set-up-proper-startstop-services-ubuntu-debian-mac-windows/

cp MSTU /etc/init.d/MSTU
chmod +x /etc/init.d/MSTU
update-rc.d MSTU defaults

service MSTU start
service MSTU stop
service MSTU restart

Warning: The unit file, source configuration file or drop-ins of MSTU.service changed on disk. Run 'systemctl daemon-reload' to reload units.

systemctl status MSTU.service
? MSTU.service - LSB: M Web Server
   Loaded: loaded (/etc/init.d/MSTU; generated)
   Active: active (running) since Wed 2019-07-17 12:14:22 UTC; 59s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 7087 ExecStop=/etc/init.d/MSTU stop (code=exited, status=0/SUCCESS)
  Process: 7092 ExecStart=/etc/init.d/MSTU start (code=exited, status=0/SUCCESS)
    Tasks: 1 (limit: 1081)
   CGroup: /system.slice/MSTU.service
           +-6919 /usr/local/lib/yottadb/r126/mumps -direct
