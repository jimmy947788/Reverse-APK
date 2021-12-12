#!/bin/bash

ADB="nox_adb.exe"
DEVICENAME="127.0.0.1:62001" 
IDA_DBGSRV_NAME="android_x86_server"
IDA_DBGSRV_TARGET_FOLDER="/data/local/tmp"
IDA_DBGSRV_LOCAL_FOLDER="C:\Program Files\IDA 7.6 SP1\dbgsrv"
IDA_DBGSRV_PORT=23915

$ADB connect $DEVICENAME
# $ADB devices

echo "change ADB user to root."
$ADB root 

DBGSRV_EXISTS=$($ADB  shell  "test -f $IDA_DBGSRV_TARGET_FOLDER/$IDA_DBGSRV_NAME && echo \"$IDA_DBGSRV_NAME file exists.\" ")
if [ -z "$DBGSRV_EXISTS" ]
then
    echo "copy $IDA_DBGSRV_NAME to device."
    cd "$IDA_DBGSRV_LOCAL_FOLDER"
    ./
    #echo "$ADB push $IDA_DBGSRV_NAME $IDA_DBGSRV_TARGET_FOLDER"
    MSYS_NO_PATHCONV=1  $ADB push $IDA_DBGSRV_NAME $IDA_DBGSRV_TARGET_FOLDER

    echo "change $IDA_DBGSRV_NAME permission mode to 777."
    $ADB  shell  "chmod -R 777 $IDA_DBGSRV_TARGET_FOLDER/$IDA_DBGSRV_NAME"
else
    echo "$DBGSRV_EXISTS"
fi

echo "start $IDA_DBGSRV_NAME user port:$IDA_DBGSRV_PORT"
$ADB shell "$IDA_DBGSRV_TARGET_FOLDER/$IDA_DBGSRV_NAME -p$IDA_DBGSRV_PORT &" 
DBGSRV_LISTEN=$($ADB shell "netstat -tulpn | grep 'LISTEN.*$IDA_DBGSRV_NAME'")
if [ -z "$DBGSRV_LISTEN" ]
then
    echo "start $IDA_DBGSRV_NAME was failed."
    exit 1
fi

echo "forward $IDA_DBGSRV_NAME target port:$IDA_DBGSRV_PORT to host port:$IDA_DBGSRV_PORT "
$ADB forward tcp:$IDA_DBGSRV_PORT tcp:$IDA_DBGSRV_PORT