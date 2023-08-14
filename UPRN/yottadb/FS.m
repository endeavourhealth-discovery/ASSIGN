FS ; ; 8/10/23 8:46am
 quit
 
SETUP ;
 set ^%W(17.6001,"B","GET","srv","STT^POUR4",650387)=""
 quit
 
STT ; serve js form file system
 ; root folder is always /srv/
 ; /srv/hangman contains the hangman game
 ;if $zsearch("index.html")'="" quit
 set path=$extract(httpreq("path"),2,9999)
 ;
 quit
 
FILESYS ; 
 ;S HTTPOPTIONS("directory")="/srv/"
 
 new $etrap set $etrap="goto FILESYSE"
 
 K HTTPRSP
 
 S HTTPRSP("auth")="Basic realm="""_HTTPREQ("header","host")_""""
 
 N AUTHEN S AUTHEN=$$AUTHEN^VPRJRSP($G(HTTPREQ("header","authorization")),2)
 I 'AUTHEN D SETERROR^VPRJRUT(401) quit
 
 new path
 
 set path=HTTPREQ("path")
 I $E(path,$L(path),$l(path))="/" s path=path_"index.html"
 ;S ^PATH($O(^PATH(""),-1)+1)=path
 ;I $P(path,"/",$l(path,"/"))="" s path=path_"/index.html"
 
 open path:(rewind:readonly:fixed:chset="M")
 new mime
 set mime("aif")="audio/aiff"
 set mime("aiff")="audio/aiff"
 set mime("au")="audio/basic"
 set mime("avi")="video/avi"
 set mime("css")="text/css; charset=utf-8"
 set mime("csv")="text/csv; charset=utf-8"
 set mime("doc")="application/msword"
 set mime("gif")="image/gif"
 set mime("htm")="text/html; charset=utf-8"
 set mime("html")="text/html; charset=utf-8"
 set mime("ico")="image/x-icon"
 set mime("jpe")="image/jpeg"
 set mime("jpeg")="image/jpeg"
 set mime("jpg")="image/jpeg"
 set mime("js")="application/javascript"
 set mime("kid")="text/x-mumps-kid; charset=utf-8"
 set mime("m")="text/x-mumps; charset=utf-8"
 set mime("mov")="video/quicktime"
 set mime("mp3")="audio/mpeg3"
 set mime("pdf")="application/pdf"
 set mime("png")="image/png"
 set mime("ppt")="application/vnd.ms-powerpoint"
 set mime("ps")="application/postscript"
 set mime("qt")="video/quicktime"
 set mime("svg")="image/svg+xml"
 set mime("tex")="application/x-tex"
 set mime("tif")="image/tiff"
 set mime("tiff")="image/tiff"
 set mime("log")="text/plain; charset=utf-8"
 set mime("txt")="text/plain; charset=utf-8"
 set mime("wav")="audio/wav"
 set mime("xls")="application/vnd.ms-excel"
 set mime("zip")="application/zip"
 set mime("woff")="font/woff"
 set mime("woff2")="font/woff2"
 set mime("ttf")="font/ttf"
 set mime("eot")="font/eot"
 set mime("otf")="font/otf"
 new ext set ext=$zpiece(path,".",$length(path,"."))
 if $data(mime(ext)) set HTTPRSP("mime")=mime(ext)
 else  set HTTPRSP("mime")=mime("txt")
 use path
 new c set c=1
 new x for  read x#4079:0 set HTTPRSP(c)=x,c=c+1 quit:$zeof
 close path
 ; create ETag
 new etag set etag=""
 for c=0:0 set c=$order(HTTPRSP(c)) quit:'c  set etag=$zyhash(etag_HTTPRSP(c))
 set HTTPRSP("ETag")=etag
 quit
 
FILESYSE ;
 set $ecode=""
 do SETERROR^VPRJRUT("500",$zstatus)
 quit
