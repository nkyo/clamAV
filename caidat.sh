#!/bin/bash
svip=$(wget http://ipecho.net/plain -O - -q ; echo)
echo "=========================================================================="
echo "He thong antivirus ClamAV "
echo "--------------------------------------------------------------------------"
echo "Quy khach vui long dien cac thong tin chinh xac trong qua trinh cai dat."
echo "--------------------------------------------------------------------------"
cpuname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cpucores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
cpufreq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
svram=$( free -m | awk 'NR==2 {print $2}' )
svhdd=$( df -h | awk 'NR==2 {print $2}' )
svswap=$( free -m | awk 'NR==4 {print $2}' )
echo "=========================================================================="
echo "Thong Tin Server:  "
echo "---------------------------------------------------------------------------"
echo "VPS Type: $(virt-what | awk 'NR==1 {print $NF}')"
echo "CPU Type: $cpuname"
echo "CPU Core: $cpucores"
echo "CPU Speed: $cpufreq MHz"
echo "Memory: $svram MB"
echo "Disk: $svhdd"
echo "IP: $svip"

read -p "Nhan [Enter] de tiep tuc ..."


##########update OS
yum update -y
yum upgrade -y
yum -y install epel-release
yum clean all
#############cai dat clamav

yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd cla
setsebool -P antivirus_can_scan_system 1
setsebool -P clamd_use_jit 1
#####cau hinh clamAV

sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf
sed -i -e "s/^#LocalSocket/LocalSocket/" /etc/clamd.d/scan.conf
sed -i -e "s/^Example/#Example/" /etc/freshclam.conf
echo "Dang Cap Nhat CSDL Virus"
freshclam
systemctl start clamd@scan
systemctl enable clamd@scan
######cai dat ssmtp & mailx
yum install ssmtp mailx
##########cau hinh ssmtp
echo -n "Nhap server SMTP (Vi du: smtp.gmail.com:465) :  "
read sv_smtp
echo -n "Nhap user SMTP(Vi du: admin@matbao.com): "
read smtp_user
echo -n "Nhap Mat khau smtp: "
read smtp_pass

clear
echo "========================================================================="
echo "Thong Tin Ban Da Nhap:"
echo "========================================================================="
echo "Server SMTP: $sv_smtp"
echo "-------------------------------------------------------------------------"
echo "SMTP user: $smtp_user"
echo "SMTP password: $smtp_pass"
echo "========================================================================="
read -r -p "Thong Tin Tren La Chinh Xac ? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 

read -p "Nhan [Enter] de tiep tuc ..."

service sendmail stop
chkconfig sendmail off
service xinetd stop
chkconfig xinetd off
service saslauthd stop
chkconfig saslauthd off
service rsyslog stop
chkconfig rsyslog off
service postfix stop
chkconfig postfix off


yum -y remove sendmail*
yum -y remove postfix*



clear
printf "=========================================================================\n"
printf "Cai Dat Hoan Tat, Bat Dau Qua Trinh Cau Hinh... \n"
printf "=========================================================================\n"
sleep 3


############# chay cau hinh file ssmtp ###################

rm -rf /etc/ssmtp/ssmtp.conf
    cat > "/etc/ssmtp/ssmtp.conf" <<END
root=$smtp_user
mailhub=$sv_smtp
AuthUser=$smtp_user
AuthPass=$smtp_pass
UseTLS=YES
AuthMethod=LOGIN
RewriteDomain=$sv_smtp
Hostname=$sv_smtp
FromLineOverride=yes
END

##cau hinh file Quet virus
mkdir /var/log/clamav
wget https://github.com/nkyo/clamAV/raw/master/scan.sh
exit
;;
