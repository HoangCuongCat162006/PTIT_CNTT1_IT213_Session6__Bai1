#!/usr/bin/env bash
# ==============================================================================
# Script thực thi Bài 1: Khảo sát FHS và Phân quyền File/Folder nâng cao
# ==============================================================================
set -e

echo "=== [1/4] Khởi tạo cấu trúc thư mục ứng dụng web ==="
sudo mkdir -p /var/www/my-app/public
sudo mkdir -p /var/www/my-app/logs
echo "-> Đã tạo /var/www/my-app/public và /var/www/my-app/logs"

echo ""
echo "=== [2/4] Thiết lập quyền sở hữu (Owner: \$USER, Group: www-data) ==="
# Kiểm tra nếu nhóm www-data tồn tại, nếu chưa có thì tạo
if ! getent group www-data > /dev/null 2>&1; then
    echo "Nhóm www-data chưa tồn tại, đang tạo nhóm www-data..."
    sudo groupadd www-data
fi

sudo chown -R "$USER":www-data /var/www/my-app
echo "-> Đã gán quyền sở hữu: $USER:www-data cho /var/www/my-app"

echo ""
echo "=== [3/4] Phân quyền cho từng thư mục con ==="
# /var/www/my-app/public: Owner (rwx), Group (r-x), Others (---) -> 750
sudo chmod 750 /var/www/my-app/public
echo "-> Đã phân quyền 750 (drwxr-x---) cho /var/www/my-app/public"

# /var/www/my-app/logs: Owner (rwx), Group (rwx), Others (---) -> 770
sudo chmod 770 /var/www/my-app/logs
echo "-> Đã phân quyền 770 (drwxrwx---) cho /var/www/my-app/logs"

echo ""
echo "=== [4/4] Kiểm tra kết quả cấu trúc và phân quyền ==="
echo "Lệnh thực thi: ls -la /var/www/my-app"
echo "--------------------------------------------------------"
ls -la /var/www/my-app
echo "--------------------------------------------------------"
echo "Hoàn thành thiết lập thành công!"
