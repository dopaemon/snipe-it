# Bảng Quy tắc Kiểm thử Oracle cho Mô hình M1 và M2

**Người phụ trách:** Nguyễn Minh Anh (`@MinhAnhhhhhh` - MSSV: 2312571)  
**Học phần:** Kiểm thử phần mềm - Đề tài R03-K06

---

## 1. Test Oracle cho Mô hình M1 (Form Tạo Tài Sản)

Mô hình M1 kiểm thử việc gửi dữ liệu đến `POST /hardware`.

### Quy tắc xác định kết quả mong đợi (Oracle Rules):
1. **Trạng thái cấp phát ngay khi tạo (`Status` & `Checkout`):**
   - Chỉ trạng thái `Deployable` mới cho phép gán đích cấp phát (`Checkout != "Khong"`).
   - Nếu `Status` thuộc `[Pending, Archived, Undeployable]` mà `Checkout != "Khong"`:
     - **Oracle:** Hệ thống báo lỗi validation (`Status must be deployable to be checked out`). Form trả về lỗi HTTP 422 hoặc redirect kèm error flash session.
2. **Trường bắt buộc theo Model Fieldset:**
   - Nếu `Model` có `FieldsetBatBuoc` mà custom field tương ứng bị bỏ trống:
     - **Oracle:** Validation failure trên trường custom field.
3. **Giá thành (`Cost`):**
   - `Cost == "Am"`: Validation failure (`The cost must be positive`).
   - `Cost == "HopLe"` hoặc `Cost == "Trong"`: Thành công (200 / 302).
4. **Mã thẻ tài sản (`Tag`):**
   - Trùng lặp `asset_tag` đã tồn tại trong CSDL: Báo lỗi `Asset tag must be unique`.

---

## 2. Test Oracle cho Mô hình M2 (Quyền Cấp phát & Checkoutable Policy)

Mô hình M2 kiểm thử quyền hạn người dùng và khả năng cấp phát giữa các thực thể (`Asset`, `License`, `Accessory`, `Consumable`, `Component`) theo FMCS (Full Multiple Company Support).

### Ma trận đối tượng đích hợp lệ:
- `Asset` -> Hỗ trợ đích: `User`, `Location`, `Asset`.
- `Accessory` -> Hỗ trợ đích: `User`, `Location`, `Asset`.
- `License` -> Hỗ trợ đích: `User`, `Asset`. (Không hỗ trợ `Location`).
- `Consumable` -> Hỗ trợ đích: `User` duy nhất.
- `Component` -> Hỗ trợ đích: `Asset` duy nhất.

### Quy tắc kiểm tra phân quyền và FMCS:
1. **Vai trò (`VaiTro`):**
   - `Superuser`: Luôn vượt qua kiểm tra quyền (Policy return `true`).
   - `AdminCoQuyen`: Được phép checkout nếu nằm trong phạm vi công ty được gán.
   - `UserKhongQuyen`: Trả về `403 Forbidden` (`This action is unauthorized`).
2. **Phạm vi công ty (`FMCS` & `CongTy`):**
   - Khi `FMCS == Bat`: Người dùng thuộc Company A **không thể** thao tác trên tài sản hoặc cấp phát cho đối tượng thuộc Company B. Vi phạm trả về `403 Forbidden` hoặc không tìm thấy bản ghi theo query scope.
   - Khi `FMCS == Tat`: Bỏ qua giới hạn công ty chéo giữa các bên.
