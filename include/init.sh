#!/bin/sh
# Init env of linux

CheckNetwork()
{
    EchoBlue "Starting Check network..."
    pingResult=$(ping -c3 www.baidu.com 2>&1)
    echo $pingResult
    if [ $? != 0 ] || echo $pingResult | grep -qe 'unknown host' -e '未知的名称或服务'; then
        echo 'DNS...fail'
        echo "Writing nameserver to /etc/resolv.conf ..."
        echo -e "nameserver 114.114.114.114\nnameserver 8.8.8.8" > /etc/resolv.conf
    else
        echo "DNS...ok" 
    fi 
}

SetTimeZone()
{
    EchoBlue "Setting timezone..."
    [ -f "/etc/localtime" ] && rm -f /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

DisableSelinux()
{
    EchoBlue "Disabling Selinux..."
    [ -s "/etc/selinux/config" ] && sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
}

DisableIptables()
{
    GetRHELVersion 
    EchoBlue "Disabling Iptables..."
    iptables-save > /etc/sysconfig/iptables
    if [[ "$rhelVersion" = 5 || "$rhelVersion" = 6 ]]; then
        service iptables stop
        chkconfig iptables off
    else
        systemctl stop firewalld
        systemctl disable firewalld 
    fi 
}



RHELInstallNtp()
{
    EchoBlue "[+] Installing ntp..."
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
    startTime=$(date +%s) 
}

DebInstallNtp()
{ 
    EchoBlue "[+] Installing ntp..."
    apt-get update -y
    apt install -y ntp
    ntpdate -u pool.ntp.org
    date
    startTime=$(date +%s) 
}

RHELModifySource()
{
    EchoBlue "Starting modfiy RHEL source"
    GetRHELVersion 
    [ -s "/etc/yum.repos.d/CentOS-Base.repo.default" ] || mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.default
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-"$rhelVersion".repo
    yum makecache 
}

DebianModifySource()
{
    EchoBlue "Starting modfiy Debian source"
    GetDebianVersion
    if [ "$debianVersion" == 7 ]; then
        deb http://mirrors.aliyun.com/debian/ wheezy main non-free contrib
        deb http://mirrors.aliyun.com/debian/ wheezy-proposed-updates main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ wheezy main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ wheezy-proposed-updates main non-free contrib
    elif [ "$debianVersion" == 8 ]; then
        deb http://mirrors.aliyun.com/debian/ jessie main non-free contrib
        deb http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ jessie main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ jessie-proposed-updates main non-free contrib
    elif [ "$debianVersion" == 9 ]; then
        deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib
        deb http://mirrors.aliyun.com/debian-security stretch/updates main
        deb-src http://mirrors.aliyun.com/debian-security stretch/updates main
        deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib
        deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib
        deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib 
    fi 
}

UbuntuModifySource()
{
    EchoBlue "Starting modfiy Ubuntu source"
    GetUbuntuVersion
    if [ "$ubuntuVersion" == 14 ]; then
        deb https://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
        deb-src https://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
        deb https://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
        deb-src https://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse

        deb https://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
        deb-src https://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse

        deb https://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
        deb-src https://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse 
    elif [ "$ubuntuVersion" == 16 ]; then
        deb http://mirrors.aliyun.com/ubuntu/ xenial main
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial main

        deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main

        deb http://mirrors.aliyun.com/ubuntu/ xenial universe
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial universe
        deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates universe

        deb http://mirrors.aliyun.com/ubuntu/ xenial-security main
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main
        deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
        deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security universe
    elif [ "$ubuntuVersion" == 18 ]; then
        deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

        deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

        deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

        deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

        deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    fi 
}

LinuxOpt()
{
    EchoBlue "Staring Linux opt..."
    [ -e "/etc/security/limits.conf.default" ] || \cp -a /etc/security/limits.conf{,.default}
    cat >/etc/security/limits.conf<<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
    [ -e "/etc/sysctl.conf.default" ] || \cp -a /etc/sysctl.conf{,.default}
    echo "fs.file-max=65535" > /etc/sysctl.conf 
    sysctl -p 
    stopTime=$(date +%s)
    echo "Takes $((stopTime-startTime)) second."
    #echo "Taks $(((stopTime-startTime)/60)) minutes."
}

UpdateLinux()
{
    EchoBlue "Staring update linux..."
    GetDistName
    if [ "$distPM" ==  "yum" ]; then
        yum -y update
    elif [ "$distPM" == "apt" ]; then
        apt-get -y update
    fi 
    date
    stopTime=$(date +%s)
    echo "Takes $((stopTime-startTime)) second."
    #echo "Taks $(((stopTime-startTime)/60)) minutes."
}


PressInstall()
{
    echo ''
    EchoGreen "Press any key to install...or Press Ctrl+c to cancel"    
    oldConfig=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty $oldConfig 
}
