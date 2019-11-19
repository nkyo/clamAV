#!/bin/bash
#
LOGFILE="/var/log/clamav/clamav-log-$(TZ=Asia/Ho_Chi_Minh date +'%Y-%m-%d_%H-%M-%S').log"; 
FOUNDFILE="/var/log/clamav/clamav-found-$(TZ=Asia/Ho_Chi_Minh date +'%Y-%m-%d_%H-%M-%S').log"; 
SVIP=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}');
EMAIL_MSG="Kinh thua Quy khach,

He thong giam sat bao mat tren may chu "$svip" duoc dang ki tai Mat Bao da phat hien mot (hoac nhieu) tap tin co kha nang bi nhiem ma doc (con goi la malware, virus).

Hien tai, nhung tap tin khong an toan da duoc phan mem bao mat ClamAV tu dong ngan chan thuc thi nham dam bao an toan kip thoi cho he thong va du lieu dang van hanh tren may chu "$svip".

Quy khach vui long kiem tra va loai bo nhung doan ma doc (hoac tap tin) nay de may chu tiep tuc hoat dong an toan. Quy khach co the xem huong dan xu ly ma doc de loai bo toan bo ma doc tren website tai lien ket sau:

https://wiki.matbao.net/kb/huong-dan-xu-ly-ma-doc

Sau day la danh sach nhung tap tin duoc phat hien bi nhiem ma doc tren server "$SVIP" can Quy khach kiem tra va khac phuc nhanh chong:"; 
EMAIL_FROM="MAILDI";
EMAIL_TO="MAILDEN";
DIRTOSCAN="/SUATHUMUCSCAN";

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
MADOC=$(sed -i -e 's/:/ - Loai ma doc - /' $FOUNDFILE );
MADOC=$(sed -i -e 's/FOUND/ /' $FOUNDFILE );
MADOC=$(sed -i 's/^/Tap tin: /' $FOUNDFILE );
if [ "$MALWARE" -ne "0" ];then 
  echo -e "$EMAIL_MSG \n $(cat $FOUNDFILE)"|mail -a "$FOUNDFILE" -s "[CANH BAO NGUY HIEM]Phat hien cac tap tin co chua virus tren may chu "$SVIP"" -r "$EMAIL_FROM" "$EMAIL_TO";
fi 
exit 0
