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
echo "=========================================================================="


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

echo -n "Nhap ten mien (Vi du: matbao.com) :  "
read tenmien
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
echo "Ten mien: $tenmien"
echo "========================================================================="
echo "Server SMTP: $sv_smtp"
echo "-------------------------------------------------------------------------"
echo "SMTP user: $smtp_user"
echo "SMTP password: $smtp_pass"
echo "========================================================================="

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
printf "Cai Dat Hoan Tat, Vui long nhap cau hinh ket noi SMTP... \n"
printf "=========================================================================\n"
sleep 3


############# chay cau hinh file ssmtp ###################

rm -rf /etc/ssmtp/ssmtp.conf
    cat > "/etc/ssmtp/ssmtp.conf" <<END
root=postmaster
root=$smtp_user
mailhub=$sv_smtp
AuthUser=$smtp_user
AuthPass=$smtp_pass
UseTLS=YES
AuthMethod=LOGIN
RewriteDomain=$tenmien
Hostname=clamav
FromLineOverride=yes
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
END
##cau hinh file Quet virus
mkdir /var/log/clamav
wget https://raw.githubusercontent.com/nkyo/clamAV/master/scan.sh
chmod +x scan.sh
echo -n "Nhap dia chi mail nhan thong bao :  "
read MAILDEN
echo -n "Thu muc scan (Vi du: home) :  "
read SUATHUMUCSCAN
sed -i -e "s/MAILDI/$smtp_user/" scan.sh
sed -i -e "s/MAILDEN/$MAILDEN/" scan.sh
sed -i -e "s/SUATHUMUCSCAN/$SUATHUMUCSCAN/" scan.sh

crontab <<EOF
2 * * * * /root/scan.sh
EOF

printf "=========================================================================\n"
printf "Dang kiem tra he thong gui email\n"
printf "=========================================================================\n"

echo "Qua trinh cai dat ClamAV da hoan tat tren may chu $svip " | mail -v -s "[THONG BAO] Cai dat ClamAV hoan tat" "$MAILDEN"
clear
printf "=========================================================================\n"
printf "Cai Dat Hoan Tat\n"
printf "=========================================================================\n"

clear
clear
printf "=========================================================================\n"
printf "Vui long kiem tra email $MAILDEN \n"
printf "=========================================================================\n"
exit
;;
