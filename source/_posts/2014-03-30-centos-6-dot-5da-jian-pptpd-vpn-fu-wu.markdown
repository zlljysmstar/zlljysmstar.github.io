---
layout: post
title: "CentOS 6.5搭建pptpd(VPN)服务"
date: 2014-03-30 14:01:56 +0800
comments: true
categories: pptpd vpn 
---

##1. 安装PPP组件，PPTP需要PPP支持<br/>
```bash Command Line
yum -y install gcc gcc-c++ rpm-build make wget automake
yum -y install ppp
```
<!--more-->
##2. 更新yum源，为安装pptpd提供支持
```plain /etc/yum.repos.d/Doylenet.repo
[doylenet]
me=Doylenet custom repository for CentOS
baseurl=http://files.doylenet.net/linux/yum/centos/5/i386/doylenet/
gpgcheck=1
gpgkey=http://files.doylenet.net/linux/yum/centos/RPM-GPG-KEY-rdoyle
enabled=1
```
##3. 安装pptpd<br/>
```bash Command Line
yum install pptpd
```
##4. 配置pptpd与ppp<br/>
```plain /etc/pptpd.conf
ppp /usr/sbin/pppd
option /etc/ppp/options.pptpd
localip 192.168.1.202
remoteip 192.168.0.100-199
```
```plain /etc/ppp/chap-secrets
# Secrets for authentication using CHAP
# client    server  secret      IP address
zhuliang11  pptpd   123456789   *
```
```plain /etc/ppp/options.pptpd
ms-dns 8.8.8.8
ms-dns 4.4.4.4
```
##5. 配置snat服务，以便VPN成功连接后可以访问Internet<br/>
配置脚本如下：
{% include_code shell/snat.sh %}
##6. 启动VPN及相关服务<br/>
```bash Start VPN service
cd /root/
./snat.sh
service pptpd start | service pptpd restart-kill
pptpd
```
##7. 相关说明<br/>
7.1&nbsp;&nbsp;VPN连接类型建议选择：点对点隧道协议（PPTP）<br/>
7.2&nbsp;&nbsp;IP设置里面，不要选择“在远程网络上使用默认网关”<br/>
