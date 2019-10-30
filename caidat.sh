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


##########update OS
yum update -y
yum upgrade -y
#############cai dat clamav



######cai dat ssmtp & mailx


#####cau hinh clamAV


##########cau hinh ssmtp



echo -n "Nhap server ket noi SMTP:PORT Vi du: smtp.gmail.com:465 ) " 
read sv_smtp
echo -n "Nhap user SMTP: Vi du admin@matbao.com" 
read smtp_user
echo -n "Nhap Mat khau smtp" 
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

rm -rf ssmtp conf
    cat > "/etc/nginx/conf.d/sim.$svdomain.conf" <<END
###noi dung cua ssmtp

END

####cau hinh file Quet virus
rm -f 
    cat > "/etc" <<END

END
