#!/usr/bin/env bash
# fix_admin_password.sh - Khắc phục sự cố mật khẩu admin sau khi seed dữ liệu
# Người thực hiện: Phan Văn Nhật Trường (Girrint)

set -euo pipefail

NEW_PASSWORD="${1:-Admin12345!}"

echo "Đang cập nhật lại mật khẩu cho tài khoản admin..."
docker compose -f dev.docker-compose.yml exec -T snipeit \
  php artisan tinker --execute="
    \$u = App\\Models\\User::where('username', 'admin')->first();
    if (\$u) {
        \$u->password = Illuminate\\Support\\Facades\\Hash::make('$NEW_PASSWORD');
        \$u->save();
        echo 'Cập nhật mật khẩu thành công cho user: ' . \$u->username . PHP_EOL;
    } else {
        echo 'Không tìm thấy user admin!' . PHP_EOL;
        exit(1);
    }
  "

echo "Hoàn tất! Mật khẩu mới: $NEW_PASSWORD"
