GAWK ; ; 8/20/20 9:53am
 W !,"Enter EPOC (e.g. 76): "
 R e
 I e="." G OUT
 S sevenzip="7z"
 S output="/tmp/output/"
 S installzip="/tmp/install-zips/"
 s epoch="/tmp/install-zips/COU_Epoch"_e_".zip"
 I $$10^ZOS(epoch)>1 W !,"COU_Epoch"_e_".zip does not exist" Q
 s zipepoch="/tmp/output/COU_Epoch"_e_"/*.zip"
 s zipepochd="/tmp/output/COU_Epoch"_e_"/"
 
 S cmd=sevenzip_" x "_epoch_" -o"_output_"* -r -y"
 W !,cmd
 zsystem cmd
 ;quit
 ;
 ;
 ;
 ; do a list of zipepoch
 s cmd="ls "_zipepoch_" > "_output_"dir.txt"
 W !,cmd
 zsystem cmd
 ; 
 s f=output_"dir.txt"
 c f
 o f:(readonly)
 f  u f r str q:$zeof  do
 .;
 .S cmd="7z e -o"_output_" "_str_" -y"
 .;
 .zsystem cmd
 .quit
 C f
 s cmd="cp "_installzip_"AddressBasePremium_GawkSplitScript.bat "_output
 zsystem cmd
 s cmd="cp "_installzip_"gawk.exe "_output
 zsystem cmd
 s cmd="cp "_installzip_"*.csv "_output
 zsystem cmd
 s cmd=output_"AddressBasePremium_GawkSplitScript.bat"
 ;
 w !,"copy the contents of ",output," to a folder on a windows machine,then run ",cmd
OUT ;
 W !
 H
