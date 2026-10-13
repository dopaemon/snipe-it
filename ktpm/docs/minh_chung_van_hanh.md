# Minh chứng vận hành 11 Route và 3 Luồng End-to-End

**Người phụ trách:** Lê Thị Mai Anh (`@maianhtl` - MSSV: 2312569)  
**Học phần:** Kiểm thử phần mềm - Đề tài R03-K06 (Snipe-IT)  
**Mục tiêu:** Cung cấp minh chứng hệ thống chạy thực tế qua giao thức HTTP (Session + CSRF) và dữ liệu demo đã seed.

---

## 1. Phương pháp xác minh

Sử dụng `curl` với cookie jar để mô phỏng chính xác hành vi của trình duyệt:
1. Gửi `GET /login` để nhận session cookie và trích xuất `_token` (CSRF token).
2. Gửi `POST /login` với payload `_token`, `username=admin`, `password=Admin12345!`.
3. Kiểm tra mã chuyển hướng `302 Found` về trang chủ (`/`).
4. Sử dụng session cookie đã xác thực để truy cập lần lượt 10 route nghiệp vụ tiếp theo.

---

## 2. Bảng kết quả 11 Route nghiệp vụ

| # | Luồng nghiệp vụ | Phương thức / Route | Mã HTTP trả về | Kết quả đánh giá |
|:---:|---|---|:---:|---|
| 1 | Xác thực đăng nhập hệ thống | `POST /login` | `302` | Thành công (Chuyển hướng dashboard) |
| 2 | Trang Dashboard tổng quan | `GET /` | `200` | Thành công (Hiển thị biểu đồ thống kê) |
| 3 | Danh sách tài sản phần cứng | `GET /hardware` | `200` | Thành công (Phân trang 2.608 bản ghi) |
| 4 | Form tạo tài sản mới (M1) | `GET /hardware/create` | `200` | Thành công (Đầy đủ trường nhập liệu) |
| 5 | Quản lý dòng máy (Asset Models) | `GET /models` | `200` | Thành công (18 model demo) |
| 6 | Danh mục tài sản (Categories) | `GET /categories` | `200` | Thành công (20 danh mục) |
| 7 | Danh sách người dùng | `GET /users` | `200` | Thành công (2.106 người dùng) |
| 8 | Form tạo người dùng mới | `GET /users/create` | `200` | Thành công (Phân quyền và công ty) |
| 9 | Quản lý bản quyền (Licenses) | `GET /licenses` | `200` | Thành công (4 license demo) |
| 10 | Quản lý phụ kiện (Accessories) | `GET /accessories` | `200` | Thành công (6 phụ kiện) |
| 11 | Báo cáo tài sản tùy biến | `GET /reports/custom` | `200` | Thành công (Tạo bộ lọc báo cáo) |

---

## 3. Ba luồng nghiệp vụ cốt lõi (End-to-End)

1. **Luồng 1: Tạo mới tài sản (Asset Creation - M1)**
   - Đường dẫn: `GET /hardware/create` -> `POST /hardware`.
   - Các thực thể tham gia: `Asset`, `AssetModel`, `Statuslabel`, `Location`, `Supplier`.
   - Kết quả: Tài sản được lưu vào CSDL với `asset_tag` tự tăng hoặc chỉ định, ghi log vào `action_logs`.

2. **Luồng 2: Cấp phát tài sản (Checkout - Polymorphic)**
   - Đường dẫn: `GET /hardware/{id}/checkout` -> `POST /hardware/{id}/checkout`.
   - Đối tượng nhận cấp phát (`assigned_type`):
     - `App\Models\User`: Gán trực tiếp cho nhân viên.
     - `App\Models\Location`: Đặt tại phòng ban/vị trí.
     - `App\Models\Asset`: Gắn kèm vào tài sản cha.
   - Kết quả: Cập nhật trạng thái `assigned_to`, ghi nhật ký cấp phát, gửi thông báo qua mailer.

3. **Luồng 3: Thu hồi tài sản (Checkin)**
   - Đường dẫn: `GET /hardware/{id}/checkin` -> `POST /hardware/{id}/checkin`.
   - Kết quả: Đưa tài sản về trạng thái sẵn sàng cấp phát (`Deployable` hoặc `Pending`), xóa liên kết gán cũ, cập nhật vị trí lưu kho.
