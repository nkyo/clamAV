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
EMAIL_FROM="SUAMAILDI";
EMAIL_TO="SUAMAILDEN";
DIRTOSCAN="SUATHUMUCSCAN";

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
