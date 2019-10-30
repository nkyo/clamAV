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
cat > "./scan.sh" <<END
#!/bin/bash
#
LOGFILE="/var/log/clamav/clamav-log-$(TZ=Asia/Ho_Chi_Minh date +'%Y-%m-%d_%H-%M-%S').log"; 
FOUNDFILE="/var/log/clamav/clamav-found-$(TZ=Asia/Ho_Chi_Minh date +'%Y-%m-%d_%H-%M-%S').log"; 
SVIP=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}');
EMAIL_MSG="Kính thưa Quý khách,
Hệ thống giám sát bảo mật trên máy chủ "$svip" được đăng kí tại Mắt Bão đã phát hiện một (hoặc nhiều) tập tin có khả năng bị nhiễm mã độc (còn gọi là malware, virus).
Hiện tại, những tập tin không an toàn đã được phần mềm bảo mật ClamAV tự động ngăn chặn thực thi nhằm đảm bảo an toàn kịp thời cho hệ thống và dữ liệu đang vận hành trên máy chủ "$svip".
Quý khách vui lòng kiểm tra và loại bỏ những đoạn mã độc (hoặc tập tin) này để máy chủ tiếp tục hoạt động an toàn. Quý khách có thể xem hướng dẫn xử lý mã độc để loại bỏ toàn bộ mã độc trên website tại liên kết sau:
https://wiki.matbao.net/kb/huong-dan-xu-ly-ma-doc
Sau đây là danh sách những tập tin được phát hiện bị nhiễm mã độc trên server "$SVIP" cần Quý khách kiểm tra và khắc phục nhanh chóng:"; 
EMAIL_FROM="abuse@web.root.dns.server.namkyo.jp";
EMAIL_TO="nam@dam.vc";
DIRTOSCAN="/home";

# Update ClamAV database
echo "Dang cap nhat CSDL virus...";
freshclam --quiet;

TODAY=$(date +%u);

if [ "$TODAY" == "1" ];then
 echo "Bat dau quet virus.";

 # be nice to others while scanning the entire root
 nice -n5 clamscan -ri / --exclude-dir=/sys/ &>"$LOGFILE";
else
 DIRSIZE=$(du -sh "$DIRTOSCAN" 2>/dev/null | cut -f1);

 echo "Bat dau quet virus hang ngay thu muc "$DIRTOSCAN"
 dung luong file can quet la "$DIRSIZE".";

 clamscan -ri "$DIRTOSCAN" &>"$LOGFILE";
fi

MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3); 
FOUND=$(grep FOUND $LOGFILE >> $FOUNDFILE );
MADOC=$(sed -i -e 's/:/ - Loại mã độc - /' $FOUNDFILE );
MADOC=$(sed -i -e 's/FOUND/ /' $FOUNDFILE );
MADOC=$(sed -i 's/^/Tập tin: /' $FOUNDFILE );
if [ "$MALWARE" -ne "0" ];then 
  echo -e "$EMAIL_MSG \n $(cat $FOUNDFILE)"|mail -a "$FOUNDFILE" -s "[CẢNH BÁO NGUY HIỂM]Phát hiện các tập tin có chứa virus trên máy chủ "$SVIP"" -r "$EMAIL_FROM" "$EMAIL_TO";
fi 
exit 0
END
exit
;;
