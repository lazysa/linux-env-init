#!/bin/sh
# Linux env init
# Linux系统环境初始化

#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH

. include/main.sh 
. include/init.sh

#if [ "$#" -ne 0 ]; then
#    EchoRed "Usage: $0"
#    exit 1
#fi

# Check if user is root
if [ "0" != $(id -u) ]; then
    echo "Error: You must be root to run this script, Please use root to install it"
    exit 1
fi


GetDistName
if [ "$distRO" == "unknow" ]; then
    EchoRed "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1 
fi


clear
echo "+------------------------------------------------------------------------+"
echo "|               Initialize the Linux environment                         |" 
echo "+------------------------------------------------------------------------+"
echo "|                                                                        |" 
echo "+------------------------------------------------------------------------+"
echo "|                                                                        |" 
echo "+------------------------------------------------------------------------+"

ModifyYumSource()
{
    if [[ "$distRO" == "RHEL" || "$distRO" == "CentOS" ]]; then
        RHELModifySource
    elif [ "$distRO" == "Debian" ]; then
        DebianModifySource
    elif [ "$distRO" == "Ubuntu" ]; then
        UbuntuModifySource 
    fi
}

InitInstall()
{
    #PressInstall
    GetDistName
    PrintSysInfo
    CheckNetwork
#    set -x
    ModifyYumSource
#    set +x
    SetTimeZone
    if [ "$distPM" == "yum" ]; then
        RHELInstallNtp 
    elif [ "$distPM" == "apt" ]; then
        DebInstallNtp
    fi
    DisableSelinux
    DisableIptables
    LinuxOpt 
#    UpdateLinux 
}


action=$1 
case "$action" in 
    all)
        InitInstall 2>&1 | tee /root/linux-env-init.log
        ;;
    mys)
        ModifyYumSource 2>&1 | tee /root/linux-env-init.log
        ;;
    opt)
        LinuxOpt 2>&1 | tee /root/linux-env-init.log
        ;;
    *)
        EchoRed "Usage: $0 {all|mys|opt}"
        ;; 
esac 
