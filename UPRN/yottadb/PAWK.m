PAWK ; ; 9/15/23 12:53pm
 quit
 
STT ;
 kill
 
 s f(32)="/mnt/f/pawk/ID32_Class_Records.csv"
 s f(15)="/mnt/f/pawk/ID15_StreetDesc_Records.csv"
 s f(21)="/mnt/f/pawk/ID21_BLPU_Records.csv"
 s f(28)="/mnt/f/pawk/ID28_DPA_Records.csv"
 s f(24)="/mnt/f/pawk/ID24_LPI_Records.csv"
 
 s q="/mnt/d/GB0923/*.csv"
 for  set x=$zsearch(q) quit:x=""  do
 .s name=$zparse(x,"NAME")
 .s dir=$zparse(x,"DIRECTORY")
 .s type=$zparse(x,"TYPE")
 .s f=dir_name_type
 .s result(f)=""
 .w !,dir,name,type
 .quit
 
 s i=""
 f  s i=$o(f(i)) q:i=""  do
 .s file=f(i)
 .close file
 .o file:(newversion)
 .use file
 .w "header",$c(10)
 .quit
 
 s f=""
 f  s f=$o(result(f)) q:f=""  do
 .use 0 w !,f
 .close f
 .o f:(readonly)
 .s c=1
 .f  u f r str q:$zeof  do
 ..i c#10000=0 u 0 w !,c
 ..s id=$p(str,",",1)
 ..s file=$get(f(id))
 ..i file="" quit
 ..u file w str,$c(10)
 ..s c=c+1
 ..quit
 .close f
 .quit
 
 s i=""
 f  s i=$o(f(i)) q:i=""  do
 .s file=f(i)
 .close file
 .quit
 
 quit
