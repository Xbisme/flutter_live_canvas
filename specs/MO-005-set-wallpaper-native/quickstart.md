# Quickstart — Nghiệm thu MO-005 Set Wallpaper Native

**Spec**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md)

Phần lớn giá trị của spec này chỉ chứng minh được **trên máy thật** (hình nền sống qua reboot, quyền thư viện Ảnh, màn chọn hình nền của hệ thống). Test tự động phủ tầng Dart; bảng cuối liệt kê phần buộc phải nghiệm thu tay.

---

## Chuẩn bị

```bash
# Flutter SDK không nằm trong PATH mặc định — dùng đường dẫn tuyệt đối như các spec trước
flutter pub get
dart run lean_builder build          # regen DI sau khi thêm @injectable/@lazySingleton
```

Backend local phải chạy và phục vụ được media cho máy thật:

```bash
# ở repo livecanvas-backend
python manage.py runserver 0.0.0.0:8000
```

Chạy app trên máy thật (theo cơ chế `API_HOST` đã dựng ở MO-003):

```bash
flutter run --flavor development -t lib/main_development.dart \
  --dart-define=API_HOST=<IP LAN của máy dev>
```

---

## US1 — Android đặt hình nền động (P1)

1. Mở tab **Khám phá** → chạm một wallpaper **miễn phí** (không có nhãn PRO) → màn Detail.
2. Chạm **"Đặt làm hình nền"**.
   - ✅ Sheet trượt lên, tiêu đề "Đặt làm hình nền", câu giải thích dành cho Android, nút chính **"Tải & đặt hình nền"**.
   - ✅ **Không** có bộ chuyển đổi Android/iPhone (FR-002).
3. Chạm nút chính.
   - ✅ Có rung phản hồi (FR-010).
   - ✅ Tiến trình tải hiển thị và tăng dần; có nút huỷ (FR-007).
   - ⏱️ **Bấm giờ SC-002**: file mẫu ~5 MB phải xong **dưới 10 giây** trên Wi-Fi ổn định. Ghi số đo thật vào PR.
4. Đợi tải xong.
   - ✅ Sheet chuyển sang biểu tượng thành công + **"Đã tải xuống"** + nút **"Đặt làm hình nền"** (FR-003).
5. Chạm **"Đặt làm hình nền"**.
   - ✅ Màn xem trước hình nền động **của hệ thống Android** mở ra, đang phát đúng video vừa tải (FR-011).
6. Bấm **quay lại** (không áp dụng).
   - ✅ Về app bình thường, **không có thông báo lỗi nào** (FR-016).
   - ✅ Chạm lại "Đặt làm hình nền" mở lại được ngay, **không tải lại từ đầu**.
7. Lặp bước 5, lần này **xác nhận áp dụng**.
   - ✅ Hình nền động chạy lặp trên màn hình chính, **không có tiếng** (FR-012).
   - ✅ Có rung phản hồi khi thành công.
8. **Thoát hẳn app** (vuốt khỏi danh sách gần đây) → về màn hình chính.
   - ✅ Hình nền vẫn chuyển động.
9. **Khởi động lại máy** → mở khoá.
   - ✅ Hình nền vẫn chuyển động **mà không cần mở lại app** (FR-013) — đây là bài kiểm chứng thật của [research.md](research.md) R6.
10. Đặt một wallpaper **khác** theo cùng luồng.
    - ✅ Hình nền mới thay hình cũ.
    - ✅ Kiểm dung lượng: `adb shell run-as com.livecanvas.livecanvas.dev ls -l files/wallpapers/` (hoặc tương đương) → **chỉ còn một file** (FR-015, SC-007).

> **Lưu ý flavor**: bản `development` có package `com.livecanvas.livecanvas.dev`. Nếu hình nền đặt được ở bản production mà hỏng ở bản dev (hoặc ngược lại), nghi ngay `ComponentName` bị hardcode — xem [research.md](research.md) R5.

---

## US2 — iOS lưu video + hướng dẫn Shortcuts (P2)

Chạy trên **iPhone thật** (simulator không có app Phím tắt và thư viện Ảnh chỉ là bản giả).

1. Mở một wallpaper miễn phí → Detail → **"Đặt làm hình nền"**.
   - ✅ Câu giải thích nói rõ iOS **không cho app tự đặt** video làm hình nền (FR-018).
   - ✅ Nút chính ghi **"Lưu video vào Ảnh"** (FR-004).
2. Chạm nút chính (lần đầu).
   - ✅ Hệ thống hỏi quyền thư viện Ảnh, mô tả bằng **tiếng Việt** đúng mục đích.
3. **Từ chối** quyền.
   - ✅ Thông báo tiếng Việt giải thích cần cấp quyền + lối tắt mở Cài đặt; **không sập app** (FR-020).
4. Cấp quyền ở Cài đặt → quay lại → chạm lại nút chính.
   - ✅ Tải + lưu thành công, sheet chuyển sang **"Đã tải xuống"** với **3 bước** hướng dẫn Shortcuts + nút **"Mở Shortcuts"** (FR-021).
5. Mở app **Ảnh**.
   - ✅ Video vừa lưu nằm trong thư viện, **là video thường** — không phải Live Photo (FR-019, quyết định Q1/A).
6. Quay lại app → chạm **"Mở Shortcuts"**.
   - ✅ App Phím tắt của hệ thống mở lên (FR-022).

---

## US3 — Lịch sử tải ghi nhận thật (P3)

1. Sau khi đã tải ở US1 hoặc US2, mở tab **Bạn** → **"Lịch sử tải"**.
   - ✅ Wallpaper vừa tải nằm **đầu** danh sách (FR-023).
2. Tải lại đúng wallpaper đó → mở lại màn Lịch sử tải.
   - ✅ Vẫn **chỉ một mục** cho wallpaper đó, và nó ở đầu danh sách (FR-024).
3. Bắt đầu tải một wallpaper khác rồi **bấm huỷ** giữa chừng → mở lại màn Lịch sử tải.
   - ✅ Wallpaper bị huỷ **không** xuất hiện (FR-024).
4. Bật chế độ máy bay rồi thử tải → lỗi mạng → mở lại màn Lịch sử tải.
   - ✅ Không có mục mới.

---

## US4 — Chặn premium (P4)

1. Mở một wallpaper **có nhãn PRO** → **"Đặt làm hình nền"** → chạm nút chính.
   - ✅ **Không** có tiến trình tải nào chạy (FR-026).
   - ✅ Thông báo cần gói Premium bằng tiếng Việt + nút đi tới Paywall (FR-026).
2. Chạm nút của thông báo.
   - ✅ Điều hướng tới màn Paywall (bản tạm của MO-005).
3. Mở **Lịch sử tải**.
   - ✅ Wallpaper premium đó không được ghi.

> Backend `BE-005` (IAP) **chưa merge** nên mọi wallpaper premium đều trả `402`. Đây là hành vi đúng của MO-005; luồng mua thật thuộc MO-006.

---

## Bố cục tablet (FR-031)

Chạy trên iPad hoặc máy tính bảng Android:

1. Mở một wallpaper bất kỳ → Detail → **"Đặt làm hình nền"**.
   - ✅ Sheet hiển thị dạng **hộp thoại giữa màn hình** (theo [ipad.html](../../.claude/livecanvas-detail-screens/project/livecanvas/ipad.html)), **không** phải sheet trượt kín từ đáy như trên điện thoại.
   - ✅ Nội dung bên trong giữ nguyên bố cục prototype, không tràn hay bị cắt.

> Không có thiết bị tablet thì ghi rõ **defer, không chặn merge** — giống cách MO-003 xử lý T056.

---

## Kịch bản lỗi

| Tình huống | Cách dựng | Kỳ vọng |
|---|---|---|
| Mất mạng giữa chừng | Bật chế độ máy bay khi thanh tiến trình đang chạy | Lỗi mạng tiếng Việt, có nút thử lại, không còn file rác |
| Đóng sheet khi đang tải | Vuốt sheet xuống lúc đang tải | Tải dừng, không có tiến trình chạy ngầm, không ghi lịch sử (FR-008) |
| Liên kết hết hạn | Mở sheet, đợi >5 phút rồi mới bấm tải | Vẫn tải được — vì hệ thống **xin liên kết mới** lúc bấm, không dùng lại liên kết cũ (FR-005) |
| Wallpaper bị gỡ | Quản trị xoá mềm wallpaper rồi bấm tải | Báo "hình nền không còn khả dụng", không phải lỗi quyền |
| Hết dung lượng | Làm đầy bộ nhớ máy test rồi tải | Báo lỗi ghi file rõ ràng, không sập app |
| Máy không hỗ trợ hình nền động | Máy ảo/ROM không có màn chọn live wallpaper | Báo "thiết bị không hỗ trợ" (FR-017) |

Ở **mọi** tình huống trên: ✅ không có mã lỗi kỹ thuật, tên ngoại lệ, hay nội dung phản hồi máy chủ nào lọt ra giao diện (FR-029, SC-004).

---

## Cổng kiểm tra bắt buộc (Pre-Commit Checklist hiến pháp)

```bash
dart format .
flutter analyze                       # 0 warning
very_good test --test-randomize-ordering-seed random
dart run bloc_tools:bloc lint .       # 0 vi phạm
```

---

## Phần buộc nghiệm thu tay (không tự động hoá được)

| # | Hạng mục | Vì sao không tự động được |
|---|---|---|
| M1 | Hình nền sống qua reboot (US1 bước 9) | Cần khởi động lại máy thật; Flutter engine không chạy lúc đó |
| M2 | Màn xem trước hình nền của hệ thống | UI của hệ điều hành, nằm ngoài cây widget của app |
| M3 | Hộp thoại quyền thư viện Ảnh (US2 bước 2–4) | UI của hệ điều hành |
| M4 | Video xuất hiện trong app Ảnh | Ứng dụng khác |
| M5 | Dung lượng chỉ giữ một file (SC-007) | Cần quan sát hệ thống tệp trên máy thật |
| M6 | SC-001 (≤4 chạm, <60s), **SC-002 (~5 MB dưới 10s)** và SC-006 (<30s, <2 phút) | Đo trải nghiệm/thời gian thật trên mạng thật |
| M7 | Nghiệm thu trên **2 máy Android khác nhau** (SC-003) | Khác nhà sản xuất/ROM là điểm dễ vỡ nhất của live wallpaper |
| M8 | Bố cục tablet dạng hộp thoại giữa màn hình (FR-031) | Cần thiết bị tablet thật; có thể defer như MO-003 T056 |
