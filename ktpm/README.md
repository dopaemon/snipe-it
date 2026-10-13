# KTPM R03-K06 – Kiểm thử tổ hợp Pairwise cho Snipe-IT

Thư mục này chứa toàn bộ tài liệu và mã kiểm thử của nhóm cho đề tài **R03 – K06**
(học phần Kiểm thử phần mềm, Khoa CNTT, Trường Đại học Đà Lạt).
Phần còn lại của repo là mã nguồn Snipe-IT gốc, giữ nguyên tại commit đã pin.

| Mục | Giá trị |
|---|---|
| Hệ thống kiểm thử | [grokability/snipe-it](https://github.com/grokability/snipe-it) – quản lý tài sản CNTT |
| Kỹ thuật | K06 – Combinatorial / Pairwise Testing |
| Commit pin | `81586d0b830c3a50d867b4382a0784f1ee705207` (tag `ktpm-baseline`) |
| Phiên bản ứng dụng | v8.8.0 – build 25378 |
| Quản lý công việc | GitHub Project "Kiểm thử phần mềm" + Issues của repo |

## Thành viên

| Thành viên | GitHub |
|---|---|
| Trần Nguyễn Tuấn Anh | [@dopaemon](https://github.com/dopaemon) |
| Nguyễn Minh Anh | [@MinhAnhhhhhh](https://github.com/MinhAnhhhhhh) |
| Nguyễn Ngọc Hân | [@Ericismee](https://github.com/Ericismee) |
| Phan Văn Nhật Trường | [@Girrint](https://github.com/Girrint) |
| Lê Thị Mai Anh | [@maianhtl](https://github.com/maianhtl) |

## Cấu trúc thư mục

```text
ktpm/
  README.md                 # Tài liệu on-boarding (file này)
  scripts/setup_snipeit.sh  # Dựng hệ thống từ máy sạch
  models/
    m1.pict                 # Mô hình M1 – form tạo tài sản
    m2.pict                 # Mô hình M2 – quyền checkout
    pairwise_estimate.py    # Sinh bộ ca pairwise sơ bộ và kiểm tra độ phủ cặp
    m1_pairwise_draft.tsv   # 20 ca pairwise sơ bộ của M1
    m2_pairwise_draft.tsv   # 16 ca pairwise sơ bộ của M2
  docs/
    figures/                # Sơ đồ use case, kiến trúc, luồng checkout
```

## Môi trường

- Máy host chỉ cần **Docker Desktop** (Compose v2) và **Git**; không cần cài PHP, Composer, MariaDB hay Node.
- Các cổng **8000**, **3306**, **8025** phải trống.

| Thành phần | Phiên bản | Nguồn |
|---|---|---|
| PHP / Laravel | 8.4.21 / 12.69.3 | `php -v`, `composer.lock` |
| MariaDB | 11.4.7 | `dev.docker-compose.yml` |
| Redis | 7.4.3 | `dev.docker-compose.yml` |
| MailHog | v1.0.1 | `dev.docker-compose.yml` |
| Biến môi trường | `.env.dev.docker` | dùng chung cho `snipeit` và `mariadb` |

## Cài đặt nhanh

```bash
git clone https://github.com/dopaemon/snipe-it.git
cd snipe-it
git checkout ktpm-baseline
bash ktpm/scripts/setup_snipeit.sh
```

Sau khi chạy xong:

- Ứng dụng: http://localhost:8000 – tài khoản `admin` / `Admin12345!`
- Hộp thư dev (MailHog): http://localhost:8025

### Lưu ý quan trọng

1. **Seed trước, đặt mật khẩu sau.** `UserSeeder` gọi `User::truncate()` rồi tạo lại user `admin`
   với mật khẩu mặc định `password`, nên mọi tài khoản tạo trước khi seed đều bị ghi đè.
2. **Lỗi seed `enable_sound`.** Nếu đã có user `admin` trước khi chạy `db:seed`,
   `SettingsSeeder.php:71` ghi cột `enable_sound` trong khi migration tạo `enable_sounds` → lỗi
   `Unknown column`. Chạy seed trên CSDL mới (như script) thì không gặp.
3. **API token.** `php artisan snipeit:make-api-key` hiện thất bại; giả thuyết là môi trường dev chưa
   sinh khóa Passport (đang theo dõi trong issue tương ứng). Các minh chứng hiện dùng nhánh web.
4. Dự án dùng **Laravel Mix**, không có `npm run build`; dùng `npm run dev` / `npm run prod`.

## Mô hình pairwise

Hai mô hình tham số đang dùng ở giai đoạn giữa kỳ:

| Mô hình | Đối tượng | Tham số | Tổ hợp hợp lệ | Ca pairwise (sơ bộ) |
|---|---|---|---|---|
| M1 | Form tạo tài sản (`POST /hardware`) | 8 | 1.512 | 20 |
| M2 | Quyền checkout | 5 | 120 | 16 |

Sinh lại bộ ca sơ bộ và kiểm tra độ phủ cặp (chỉ cần Python 3, không cần thư viện ngoài):

```bash
python3 ktpm/models/pairwise_estimate.py
```

Sinh bộ ca bằng [Microsoft PICT](https://github.com/microsoft/pict) (giai đoạn 2):

```bash
pict ktpm/models/m1.pict          # pairwise (2-way)
pict ktpm/models/m1.pict /o:3     # 3-way để so sánh
```

## Tiến độ

| Phần | Nội dung | Trạng thái |
|---|---|---|
| A–C | Phân tích hệ thống, kiến trúc, môi trường | Hoàn thành (giữa kỳ) |
| D | Kế hoạch kỹ thuật pairwise | Sơ bộ |
| E | Mô hình tham số, bộ ca | Bản nháp |
| F–H | Script tự động, kết quả, tái lập | Cuối kỳ |

Chi tiết từng việc xem trong Issues và GitHub Project của repo.
