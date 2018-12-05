#!/bin/sh
# Check linux version

[ -f '/etc/issue' ] && issueFile='/etc/issue'

redhatReleaseFile='/etc/redhat-release'
debianReleaseFile='/etc/debian_version'
releaseFiles='/etc/*-release' 
which grep >> /dev/null 2>&1 || exit 1 

GetDistName()
{
    # RedHat etc
    if grep -Eqi 'CentOS' $issueFile || grep -Eq 'CentOS' $releaseFiles; then
        distRO='CentOS'
        distPM='yum' 
    elif grep -Eqi 'Red Hat Enterprise Linux Server' $issueFile || grep -Eq 'Red Hat Enterprise Linux Server' $releaseFiles; then
        distRO='RHEL'
        distPM='yum'
    elif grep -Eqi 'Fedora' $issueFile || grep -Eq 'Fedora' $releaseFiles; then 
        distRO='Fedora'
        distPM='yum'
    elif grep -Eqi 'Amazon Linux' $issueFile || grep -Eq 'Amazon Linux' $releaseFiles; then
        distRO='Amazon'
        distPM='yum'
    elif grep -Eqi 'Aliyun' $issueFile || grep -Eq 'Aliyun' $releaseFiles; then
        distRO='Aliyun'
        distPM='yum'
    # Debian etc
    elif grep -Eqi 'Debian' $issueFile || grep -Eq 'Debian' $releaseFiles; then
        distRO='Debian'
        distPM='apt'
    elif grep -Eqi 'Ubuntu' $issueFile || grep -Eq 'Ubuntu' $releaseFiles; then
        distRO='Ubuntu'
        distPM='apt'
    elif grep -Eqi 'Mint' $issueFile || grep -Eq 'Mint' $releaseFiles; then
        distRO='Mint'
        distPM='apt'
    elif grep -Rqi 'Deepin' $issueFile || grep -Eq 'Deepin' $releaseFiles; then
        distRO='Deepin'
        distPM='apt'
    elif grep -Rqi 'Kali' $issueFile || grep -Eq 'Kali' $releaseFiles; then 
        distRO='Kali'
        distPM='apt'
    else
        distRO='unknow'
        distPM='unknow'
fi
    GetOSBit 
}

GetRHELVersion()
{
    GetDistName
    if [[ "$distRO" == "RHEL" || "$distRO" == "CentOS" ]]; then
        if grep -Eqi 'release 5.' $redhatReleaseFile; then
            echo 'Current Version: RHEL/CentOS Ver 5' 
            rhelVersion='5'
        elif grep -Eqi 'release 6.' $redhatReleaseFile; then
            echo 'Current Version: RHEL/CentOS Ver 6' 
            rhelVersion='6'
        elif grep -Eqi 'release 7.' $redhatReleaseFile; then
            echo 'Current Version: RHEL/CentOS Ver 7' 
            rhelVersion='7'
        fi
    fi 
}

GetDebianVersion()
{
    GetDistName
    if [ "distRO" == "Debian" ]; then
        if grep -Eqi 'Debian 7' $debianReleaseFile; then
            echo "Current Version: Debian Ver 7.x"
            debianVersion='7'
        elif grep -Eqi 'Debian 8' $debianReleaseFile; then
            echo "Current Version: Debian Ver 8.x"
            debianVersion='9'
        elif grep -Eqi 'Debian 9' $debianReleaseFile; then
            echo "Current Version: Debian Ver 9.x"
            debianVersion='9' 
        fi
    fi
}

GetUbuntuVersion()
{
    GetDistName
    if [ "distRO" == "Ubuntu" ]; then
        if grep -Eqi 'Ubuntu 14' $issueFile; then
            echo "Current Version: Debian Ver 14.x"
            ubuntuVersion='14'
        elif grep -Eqi 'Ubuntu 16' $issueFile; then
            echo "Current Version: Debian Ver 16.x"
            ubuntuVersion='16'
        elif grep -Eqi 'Ubuntu 16' $issueFile; then
            echo "Current Version: Debian Ver 18.x"
            ubuntuVersion='18' 
        fi 
    fi
}


GetOSBit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        is64Bit='y'
    else
        is64Bit='n'
    fi 
}

PrintSysInfo()
{
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat $issueFile
    cat $releaseFiles
    uname -a
    memTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo "Memory is: ${memTotal} MB "
    df -h 
}

# Define color of output info 
ColorText()
{
    echo -e " \e[0;$2m$1\e[0m"
}

EchoRed()
{
    echo $(ColorText "$1" "31")
}

EchoGreen()
{
    echo $(ColorText "$1" "32")
}

EchoYellow()
{
    echo $(ColorText "$1" "33")
}

EchoBlue()
{
    echo $(ColorText "$1" "34") 
}


