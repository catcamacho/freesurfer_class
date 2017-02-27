#! /bin/csh

set configpath = /home/catcam1/FS_Class/subjDir6.0

trac-all -c $configpath/tracula_config.txt -prep 
trac-all -c $configpath/tracula_config.txt -bedp 
trac-all -c $configpath/tracula_config.txt -path 
trac-all -c $configpath/tracula_config.txt -stat