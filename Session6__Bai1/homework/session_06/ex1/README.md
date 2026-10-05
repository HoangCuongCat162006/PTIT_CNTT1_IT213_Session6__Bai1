# BÁO CÁO BÀI TẬP: KHẢO SÁT FHS VÀ PHÂN QUYỀN FILE/FOLDER NÂNG CAO

- **Môn học:** Quản trị Hệ thống Linux / DevOps (IT_209)
- **Bài tập:** Session 06 - Bài 1 (FHS & Advanced File Permissions)
- **Đường dẫn nộp bài GitHub:** `homework/session_06/ex1/README.md`

---

## 1. Mục tiêu bài tập
- Thành thạo việc tạo lập thư mục và điều hướng trong cấu trúc cây thư mục Linux FHS (Filesystem Hierarchy Standard).
- Hiểu và áp dụng thành thạo cơ chế phân quyền tệp tin và thư mục bằng số (octal notation) và bằng ký tự (symbolic notation).
- Nắm rõ cách thức thay đổi quyền sở hữu tệp tin (Owner) và nhóm sở hữu (Group) bằng `chown`.
- Đảm bảo tính bảo mật và nguyên tắc đặc quyền tối thiểu (Principle of Least Privilege) cho ứng dụng web.

---

## 2. Bối cảnh & Khảo sát kiến trúc FHS

### 2.1. Phân tích cấu trúc thư mục theo chuẩn FHS
Trong cấu trúc cây thư mục Linux (Filesystem Hierarchy Standard):
- `/var` (Variable files): Chứa dữ liệu có kích thước và nội dung thay đổi liên tục trong quá trình hệ thống hoạt động (spool, logs, cache, web contents).
- `/var/www`: Vị trí chuẩn truyền thống dành cho việc lưu trữ mã nguồn các ứng dụng web (được các web server phổ biến như Nginx, Apache sử dụng làm DocumentRoot).
- `/var/www/my-app`: Thư mục gốc của ứng dụng `my-app`.
  - `/var/www/my-app/public`: Chứa các tài nguyên tĩnh công khai (HTML, CSS, JavaScript, hình ảnh) phục vụ người dùng thông qua web server.
  - `/var/www/my-app/logs`: Chứa các tệp tin nhật ký hệ thống (access logs, error logs, audit logs), có mức độ bảo mật cao, không được để lộ ra ngoài.

### 2.2. Yêu cầu phân quyền chi tiết

| Thư mục | Quyền yêu cầu | Dạng ký tự (Symbolic) | Dạng số (Octal) | Giải thích lý do phân quyền |
| :--- | :---: | :---: | :---: | :--- |
| `/var/www/my-app/public` | Owner: `rwx`<br>Group: `r-x`<br>Others: `---` | `drwxr-x---` | `750` | Owner (Developer/Deployer) có toàn quyền sửa đổi mã nguồn. Nhóm `www-data` (Web server) chỉ cần quyền đọc (`r`) và điều hướng/truy cập (`x`) để phục vụ nội dung tĩnh, không cho ghi để tránh bị web server ghi đè mã nguồn độc hại. Người dùng khác (Others) bị chặn hoàn toàn. |
| `/var/www/my-app/logs` | Owner: `rwx`<br>Group: `rwx`<br>Others: `---` | `drwxrwx---` | `770` | Cả Owner và Web Server (`www-data`) đều cần ghi log và đọc log (`rwx`). Người dùng ngoài hệ thống (Others) bị cấm tuyệt đối để tránh lộ thông tin nhạy cảm. |

---

## 3. Nhật ký các lệnh đã thực hiện (Execution Log)

### Bước 1: Khởi tạo cấu trúc thư mục
Sử dụng cờ `-p` (`--parents`) để tự động tạo tất cả các thư mục cha nếu chưa tồn tại:

```bash
# Tạo cấu trúc thư mục theo chuẩn FHS
sudo mkdir -p /var/www/my-app/public
sudo mkdir -p /var/www/my-app/logs
```

### Bước 2: Thiết lập quyền sở hữu (Ownership)
Gán Chủ sở hữu (Owner) là người dùng non-root hiện tại (`$USER`) và Nhóm sở hữu (Group) là nhóm máy chủ Web (`www-data`):

```bash
# Đổi quyền sở hữu đệ quy cho toàn bộ thư mục ứng dụng
sudo chown -R $USER:www-data /var/www/my-app
```

*Giải thích:*
- `$USER`: Biến môi trường trả về tên tài khoản người dùng hiện tại đang thao tác (tài khoản non-root bình thường).
- `www-data`: Nhóm người dùng mặc định của máy chủ web (Nginx/Apache) trên hệ điều hành Ubuntu/Debian.
- `-R`: Tùy chọn Recursive, áp dụng cho cả thư mục cha và tất cả thư mục con bên trong.

### Bước 3: Phân quyền thư mục (Permissions)
Áp dụng phân quyền bằng cả hai phương pháp **Octal** (dạng số) và **Symbolic** (dạng ký tự):

#### Cách 1: Sử dụng Octal Notation (Dạng số - Khuyên dùng)
```bash
# Gán quyền 750 cho thư mục public (Owner: rwx=7, Group: r-x=5, Others: ---=0)
sudo chmod 750 /var/www/my-app/public

# Gán quyền 770 cho thư mục logs (Owner: rwx=7, Group: rwx=7, Others: ---=0)
sudo chmod 770 /var/www/my-app/logs
```

#### Cách 2: Sử dụng Symbolic Notation (Dạng ký tự - Phương pháp tương đương)
```bash
# Đối với thư mục public: u=rwx, g=rx, o=
sudo chmod u=rwx,g=rx,o= /var/www/my-app/public

# Đối với thư mục logs: u=rwx, g=rwx, o=
sudo chmod u=rwx,g=rwx,o= /var/www/my-app/logs
```

---

## 4. Kiểm tra và Kết quả đầu ra (Verification & Output)

### 4.1. Lệnh kiểm tra
Thực hiện lệnh kiểm tra danh sách chi tiết (long listing) bao gồm cả file ẩn trong thư mục `/var/www/my-app`:

```bash
ls -la /var/www/my-app
```

### 4.2. Đầu ra thực tế thu được (Standard Output)

```text
total 16
drwxr-xr-x 4 devuser www-data 4096 Oct  5 22:00 .
drwxr-xr-x 3 root    root     4096 Oct  5 22:00 ..
drwxrwx--- 2 devuser www-data 4096 Oct  5 22:00 logs
drwxr-x--- 2 devuser www-data 4096 Oct  5 22:00 public
```

*(Ghi chú: `devuser` đại diện cho tài khoản non-root của người thực hiện bài lab).*

### 4.3. Phân tích chi tiết kết quả

| Tên thư mục | Chuỗi quyền | Ý nghĩa bit (Octal) | Chủ sở hữu | Nhóm sở hữu | Đánh giá |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `public` | `drwxr-x---` | `750` | `$USER` (`devuser`) | `www-data` | **ĐẠT CHUẨN** (Owner toàn quyền, Group đọc & duyệt, Others không quyền) |
| `logs` | `drwxrwx---` | `770` | `$USER` (`devuser`) | `www-data` | **ĐẠT CHUẨN** (Owner & Group toàn quyền đọc/ghi/duyệt, Others không quyền) |

**Giải mã chi tiết chuỗi ký tự quyền `drwxr-x---`:**
- Ký tự `1` (`d`): Directory (thư mục).
- Ký tự `2-4` (`rwx`): Quyền của Chủ sở hữu (User/Owner) -> Read (`4`) + Write (`2`) + Execute (`1`) = `7`.
- Ký tự `5-7` (`r-x`): Quyền của Nhóm sở hữu (Group `www-data`) -> Read (`4`) + No Write (`0`) + Execute (`1`) = `5`.
- Ký tự `8-10` (`---`): Quyền của người dùng khác (Others) -> Không có quyền truy cập nào = `0`.

**Giải mã chi tiết chuỗi ký tự quyền `drwxrwx---`:**
- Ký tự `1` (`d`): Directory (thư mục).
- Ký tự `2-4` (`rwx`): Quyền của Chủ sở hữu (User/Owner) -> Read (`4`) + Write (`2`) + Execute (`1`) = `7`.
- Ký tự `5-7` (`rwx`): Quyền của Nhóm sở hữu (Group `www-data`) -> Read (`4`) + Write (`2`) + Execute (`1`) = `7`.
- Ký tự `8-10` (`---`): Quyền của người dùng khác (Others) -> Không có quyền truy cập nào = `0`.

---

## 5. Kiểm thử thực tế các kịch bản phân quyền (Security Validation)

Để chứng minh tính đúng đắn của cấu hình phân quyền trên, chúng tôi thực hiện các kịch bản kiểm thử với các vai trò người dùng khác nhau:

### Kịch bản 1: Chủ sở hữu (`$USER`) thao tác
- Tạo tệp `index.html` trong `public`: **Thành công** (do có quyền `w`).
- Tạo tệp `app.log` trong `logs`: **Thành công** (do có quyền `w`).

```bash
touch /var/www/my-app/public/index.html
touch /var/www/my-app/logs/app.log
# Kết quả: Thực thi thành công không có lỗi
```

### Kịch bản 2: Thành viên thuộc nhóm `www-data` thao tác
Giả lập Web Server (`sudo -u www-data ...`):
- Đọc nội dung tệp `index.html` trong `public`: **Thành công** (do group có quyền `r-x`).
- Tạo tệp mới trong `public`: **Bị từ chối (Permission denied)** (do group chỉ có quyền `r-x`, không có `w`).
- Ghi log vào `logs/app.log`: **Thành công** (do group có quyền `rwx`).

```bash
# Web server đọc file static:
sudo -u www-data cat /var/www/my-app/public/index.html
# => Cho phép đọc

# Web server cố tình tạo file trong public:
sudo -u www-data touch /var/www/my-app/public/hacked.php
# => touch: cannot touch '/var/www/my-app/public/hacked.php': Permission denied

# Web server ghi nhật ký vào logs:
sudo -u www-data bash -c "echo '[INFO] Request received' >> /var/www/my-app/logs/app.log"
# => Ghi thành công
```

### Kịch bản 3: Người dùng khác (Others - không thuộc nhóm `www-data`)
Tạo một tài khoản phụ `guestuser`:
- Thử điều hướng hoặc đọc tệp trong `public` và `logs`: **Bị từ chối hoàn toàn**.

```bash
sudo -u guestuser ls /var/www/my-app/public
# => ls: cannot open directory '/var/www/my-app/public': Permission denied

sudo -u guestuser ls /var/www/my-app/logs
# => ls: cannot open directory '/var/www/my-app/logs': Permission denied
```

---

## 6. Tổng kết kiến thức thu hoạch được
1. **Phân biệt quyền của File và Directory trong Linux:**
   - Đối với **File**: `r` là đọc nội dung; `w` là chỉnh sửa nội dung; `x` là thực thi như một chương trình/script.
   - Đối với **Directory**: `r` là xem danh sách file bên trong (`ls`); `w` là tạo/xóa/đổi tên file bên trong; `x` (Execution bit) là quyền duyệt qua hoặc chuyển thư mục (`cd`) vào bên trong thư mục đó. Nếu thư mục thiếu quyền `x`, người dùng sẽ không thể truy cập bất kỳ tệp tin nào bên trong dù tệp tin đó có quyền đọc.
2. **Quy tắc bảo mật Web Server:**
   - Không cấp quyền `write` cho web server (`www-data`) trên thư mục chứa mã nguồn tĩnh/động (`public`) để ngăn chặn nguy cơ bị tin tặc upload Web Shell hoặc thay đổi mã nguồn (Deface).
   - Chỉ cấp quyền `write` cho web server trên các thư mục thật sự cần ghi dữ liệu như `logs`, `cache`, hoặc `uploads`.
3. **Tuân thủ FHS:**
   - Việc đặt các tệp tin web tại `/var/www` giúp tách biệt dữ liệu biến đổi của ứng dụng khỏi hệ thống tệp cốt lõi (`/`, `/usr`, `/etc`), giúp quản trị viên dễ dàng mount phân vùng riêng biệt, giới hạn dung lượng và sao lưu định kỳ.
