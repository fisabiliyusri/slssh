#!/bin/bash
#created : 


# Aktifkan Root
sudo su
cd


# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0'`;
MYIP2="s/xxxxxxxxx/$MYIP/g";

# detail nama perusahaan
country=ID
state=Nusantara
locality=SumateraJawaSulawesiPapua
organization=SLSSH
commonname=telkomsel.com

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# set time GMT +7 jakarta
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

echo "=================  install neofetch  ===================="
echo "========================================================="
# install neofetch
apt-get update -y
apt-get -y install gcc
apt-get -y install make
apt-get -y install cmake
apt-get -y install git
apt-get -y install screen
apt-get -y install unzip
apt-get -y install curl
apt-get -y install neofetch
cd
echo "neofetch" >> .bashrc_profile

# instal php5.6 ubuntu 16.04 64bit
apt-get -y update

# set repo webmin
#sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
#wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

# setting port ssh
cd
sed -i '/Port 22/a Port 1078' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 8000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 400' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo "================  install Dropbear ======================"
echo "========================================================="

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=44/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 450 -p 550 -p 9000 -p 77 "/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart

echo "=================  install Squid3  ======================"
echo "========================================================="

# setting dan install vnstat debian 9 64bit
apt-get -y install vnstat
systemctl start vnstat
systemctl enable vnstat
chkconfig vnstat on
chown -R vnstat:vnstat /var/lib/vnstat

# saya matikan install squid3
# cd
# apt-get -y install squid3
# wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/squid3.conf"
# sed -i $MYIP2 /etc/squid/squid.conf;
# /etc/init.d/squid restart

echo "=================  saya matikan install Webmin  ======================"
echo "========================================================="

# saya matikan install webmin
cd
#wget http://prdownloads.sourceforge.net/webadmin/webmin_1.910_all.deb
#dpkg --install webmin_1.910_all.deb;
#apt-get -y -f install;
#sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
#rm -f webmin_1.910_all.deb
#/etc/init.d/webmin restart

echo "=================  install stunnel  ====================="
echo "========================================================="

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[sslopenssh]
accept = 222
connect = 127.0.0.1:22
[sslopenssh]
accept = 43
connect = 127.0.0.1:143
[sshsslssr]
accept = 69
connect = 127.0.0.1:6969
[sslopenssh]
accept = 600
connect = 127.0.0.1:400
[sshopenssh]
accept = 700
connect = 127.0.0.1:200
[sshopenssh]
accept = 800
connect = 127.0.0.1:1078
[sshopenssh]
accept = 900
connect = 127.0.0.1:8000
[ssldropbear]
accept = 444
connect = 127.0.0.1:44
[ssldropbear]
accept = 777
connect = 127.0.0.1:77
[ssldropbear]
accept = 540
connect = 127.0.0.1:450
[ssldropbear]
accept = 551
connect = 127.0.0.1:550
[ssldropbear]
accept = 9900
connect = 127.0.0.1:9000



END

echo "=================  membuat Sertifikat OpenSSL ======================"
echo "========================================================="
#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# common password debian 
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/common-password-deb9"
chmod +x /etc/pam.d/common-password

# instal sslh untuh ssh ssl
cd
apt-get -y install sslh

#configurasi sslh
wget -O /etc/default/sslh "https://raw.githubusercontent.com/idtunnel/sshtunnel/master/sslh-conf"
service sslh restart

echo "=================  Install BadVPN UDPGW (VC and Game) ======================"
echo "========================================================="

# buat directory badvpn
echo "================= Auto Installer BadVPN UDPGW  ======================"
# buat directory badvpn
cd /usr/bin
mkdir build
cd build
wget https://github.com/ambrop72/badvpn/archive/1.999.130.tar.gz
tar xvzf 1.999.130.tar.gz
cd badvpn-1.999.130
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1
make install
make -i install

# auto start badvpn single port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500 --max-connections-for-client 20 &
cd

# auto start badvpn second port
#cd /usr/bin/build/badvpn-1.999.130
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500 --max-connections-for-client 20 &
cd

# auto start badvpn second port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500 --max-connections-for-client 20 &
cd

# auto start badvpn second port
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 1000 --max-connections-for-client 10' /etc/rc.local
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500 --max-connections-for-client 20 &
cd

# permition
chmod +x /usr/local/bin/badvpn-udpgw
chmod +x /usr/local/share/man/man7/badvpn.7
chmod +x /usr/local/bin/badvpn-tun2socks
chmod +x /usr/local/share/man/man8/badvpn-tun2socks.8
chmod +x /usr/bin/build
chmod +x /etc/rc.local

# Custom Banner SSH
wget -O /etc/issue.net "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/banner-custom.conf"
chmod +x /etc/issue.net

echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
echo "DROPBEAR_BANNER="/etc/issue.net"" >> /etc/default/dropbear

# install fail2ban
apt-get -y install fail2ban
service fail2ban restart

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# colored text
apt-get -y install ruby
gem install lolcat
# xml parser
cd
apt-get install -y libxml-parser-perl
# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/thekillers123/auto/master/null/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>JohnKeR-VPN</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/thekillers123/auto/master/null/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install mrtg
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/ForNesiaFreak/FNS_Debian7/fornesia.com/null/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/ForNesiaFreak/FNS_Debian7/fornesia.com/null/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/ForNesiaFreak/FNS_Debian7/fornesia.com/null/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd
# install vnstat gui
cd /home/vps/public_html/
wget https://github.com/ForNesiaFreak/FNS/raw/master/go/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
# 
cd

# download script
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/menu.sh"
wget -O usernew "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/trial.sh"
wget -O hapus "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/hapus.sh"
wget -O cek "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/user-login.sh"
wget -O member "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/user-list.sh"
wget -O jurus69 "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/info.sh"
wget -O about "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/about.sh"
wget -O delete "https://raw.githubusercontent.com/fisabiliyusri/sulaimanssh/master/debian9/delete.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x jurus69
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x delete

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
# service squid restart
# /etc/init.d/nginx restart
# /etc/init.d/openvpn restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo "Script"      | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "menu      : Menampilkan daftar perintah yang tersedia"  | tee -a log-install.txt
echo "usernew   : Membuat Akun SSH"  | tee -a log-install.txt
echo "trial     : Membuat Akun Trial"  | tee -a log-install.txt
echo "hapus     : Menghapus Akun SSH"  | tee -a log-install.txt
echo "cek       : Cek User Login"  | tee -a log-install.txt
echo "member    : Cek Member SSH"  | tee -a log-install.txt
echo "jurus69   : Restart Service dropbear, squid3, stunnel4, vpn, ssh)"  | tee -a log-install.txt
echo "reboot    : Reboot VPS"  | tee -a log-install.txt
echo "speedtest : Speedtest VPS"  | tee -a log-install.txt
echo "info      : Menampilkan Informasi Sistem"  | tee -a log-install.txt
echo "delete    : auto Delete user expired"  | tee -a log-install.txt
echo "about     : Informasi tentang script auto install"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt

echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/ (Cek Bandwith)"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone  : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "IPv6      : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Modified by SL SSH"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "VPS AUTO REBOOT TIAP JAM 00:00"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd

# auto Delete Acount SSH Expired
wget -O /usr/local/bin/userdelexpired "https://www.dropbox.com/s/cwe64ztqk8w622u/userdelexpired?dl=1" && chmod +x /usr/local/bin/userdelexpired


rm -f /root/openssh.sh

echo "================  install OPENVPN  saya disable======================"
echo "========================================================="
# install openvpn debian 9 ( openvpn port 1194 dan 443 )
#wget https://raw.githubusercontent.com/idtunnel/sshtunnel/master/debian9/openvpn.sh && chmod +x openvpn.sh && bash openvpn.sh

echo "==================== Restart Service ===================="
echo "========================================================="
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
# /etc/init.d/squid restart
/etc/init.d/nginx restart
service vnstat restart
# /etc/init.d/php5.6-fpm restart
# /etc/init.d/openvpn restart

# Delete script
#rm -f /root/openvpn.sh
