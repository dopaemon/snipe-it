# Phân tích Luồng Dữ liệu 4 Nghiệp vụ Trọng tâm

**Người phụ trách:** Nguyễn Minh Anh (`@MinhAnhhhhhh` - MSSV: 2312571)  
**Học phần:** Kiểm thử phần mềm - Đề tài R03-K06

---

## 1. Luồng 1: Xác thực người dùng (Authentication Flow)

```text
HTTP POST /login
  │
  ▼
app/Http/Controllers/Auth/LoginController.php @ login()
  │
  ├── Validate CSRF token và thông tin credentials
  │
  ▼
app/Models/User.php (Eloquent Query: username / email)
  │
  ├── Kiểm tra Hash::check($password, $user->password)
  ├── Kiểm tra cờ activated == 1
  │
  ▼
Session Store (Khởi tạo session ID và gắn vào cookie)
  │
  ▼
Redirect / (Dashboard)
```

---

## 2. Luồng 2: Tạo mới tài sản (Asset Creation Flow - M1 Target)

```text
HTTP POST /hardware
  │
  ▼
app/Http/Requests/AssetRequest.php
  │
  ├── Rules: asset_tag (required|unique), model_id (required|exists),
  │          status_id (required|exists), rtd_location_id (nullable)
  │
  ▼
app/Http/Controllers/Assets/AssetsController.php @ store()
  │
  ├── Gate::authorize('create', Asset::class)
  │
  ▼
app/Models/Asset.php @ create()
  │
  ├── Xử lý custom fields theo AssetModel fieldset
  ├── Lưu vào bảng `assets`
  │
  ▼
app/Models/Actionlog.php (Log hành động tạo tài sản)
  │
  ▼
Redirect /hardware/{id} hoặc /hardware
```

---

## 3. Luồng 3: Cấp phát tài sản đa hình (Polymorphic Checkout Flow - M2 Target)

```text
HTTP POST /hardware/{id}/checkout
  │
  ▼
app/Http/Requests/AssetCheckoutRequest.php
  │
  ├── Rules: checkout_to_type (required|in:user,location,asset),
  │          assigned_user / assigned_location / assigned_asset
  │
  ▼
app/Http/Controllers/Assets/AssetsController.php @ checkout()
  │
  ├── app/Policies/CheckoutablePermissionsPolicy.php @ checkout()
  │     Kiểm tra quyền actor đối với tài sản và đối tượng đích (FMCS Scope)
  │
  ▼
app/Models/Asset.php @ checkOut()
  │
  ├── Cập nhật assigned_to = $targetId
  ├── Cập nhật assigned_type = $targetClass
  ├── Gán last_checkout = now()
  │
  ▼
app/Notifications/CheckoutAssetNotification.php (Gửi mail qua hàng đợi MailHog)
  │
  ▼
app/Models/Actionlog.php (Lưu bản ghi checkout vào bảng `action_logs`)
```

---

## 4. Luồng 4: Thu hồi tài sản (Checkin Flow)

```text
HTTP POST /hardware/{id}/checkin
  │
  ▼
app/Http/Controllers/Assets/AssetsController.php @ checkin()
  │
  ├── Gate::authorize('checkin', $asset)
  │
  ▼
app/Models/Asset.php @ checkin()
  │
  ├── assigned_to = null
  ├── assigned_type = null
  ├── status_id = $newStatus (hoặc giữ nguyên status mặc định)
  │
  ▼
app/Models/Actionlog.php (Ghi nhận checkin và tình trạng thiết bị)
```
