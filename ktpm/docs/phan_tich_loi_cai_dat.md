# Báo cáo Phân tích Chuyên sâu 3 Sự cố Khi Cài đặt Môi trường Snipe-IT

**Người phụ trách:** Phan Văn Nhật Trường (`@Girrint` - MSSV: 2014503)  
**Học phần:** Kiểm thử phần mềm - Đề tài R03-K06

---

## 1. Sự cố #1: `db:seed` sập do sai tên cột trong `SettingsSeeder.php`

- **Hiện tượng:** Chạy `php artisan db:seed --force` trên máy sạch gặp exception:
  ```text
  SQLSTATE[42S22]: Column not found: 1054 Unknown column 'enable_sound' in 'SET'
  (Connection: mysql, SQL: update `users` set `enable_sound` = 1 where `id` = 1)
  ```
- **Vị trí mã nguồn:** `database/seeders/SettingsSeeder.php:71`
- **Nguyên nhân gốc (Root Cause):**
  - Migration tạo cột `2024_08_07_204014_add_play_sounds_to_profile.php:15` đặt tên là `enable_sounds` (có chữ `s` ở cuối).
  - Trong `SettingsSeeder.php:71`, tác giả viết:
    ```php
    $user->enable_sound = 1; // Sai chính tả
    ```
- **Cơ chế kích hoạt:** Chỉ xảy ra khi user `admin` đã được tạo trước (`$user = User::where('username','=','admin')->first()`).
- **Giải pháp xử lý:**
  - Trong script tự động: chạy seed trước khi tạo tài khoản admin cá nhân, hoặc sửa dòng mã thành:
    ```php
    $user->enable_sounds = 1;
    ```

---

## 2. Sự cố #2: `snipeit:create-admin` không lưu mật khẩu được chỉ định

- **Hiện tượng:** Chạy lệnh:
  ```bash
  php artisan snipeit:create-admin --username=admin --password="Admin12345!" ...
  ```
  Lệnh thông báo hoàn tất nhưng khi đăng nhập qua web form lại thất bại (`Invalid credentials`).
- **Nguyên nhân gốc:**
  - Quá trình chạy seed sau đó (`UserSeeder.php`) gọi `User::truncate()` và tạo lại user mặc định với mật khẩu `password`.
  - Hoặc cờ `--password` của command không mã hóa bcrypt đúng chuẩn của Laravel Auth.
- **Giải pháp xử lý:**
  - Dùng lệnh `tinker` để hash lại mật khẩu đúng chuẩn sau cùng:
    ```bash
    php artisan tinker --execute='$u = App\Models\User::where("username","admin")->first(); $u->password = Hash::make("Admin12345!"); $u->save();'
    ```

---

## 3. Sự cố #3: Lỗi tạo API Key bằng Passport

- **Hiện tượng:** Chạy `php artisan snipeit:make-api-key --user_id=1` gặp lỗi không tìm thấy Personal Access Client.
- **Nguyên nhân gốc:** Tầng Laravel Passport chưa được khởi tạo khóa mã hóa và bản ghi OAuth client trong CSDL (`oauth_personal_access_clients`).
- **Giải pháp xử lý:**
  - Chạy `php artisan passport:keys` và `php artisan passport:client --personal`.
