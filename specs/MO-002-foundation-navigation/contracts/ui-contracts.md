# UI Contracts: Foundation, Navigation & Design System (MO-002)

> MO-002 **không tạo/sửa HTTP API** (contract mạng nằm ở `contracts/openapi.yaml` v0.3.2, đồng bộ với backend). "Contract" của spec này là **giao diện UI** mà các spec sau (MO-003+) dựa vào: API widget dùng chung + bảng route + hợp đồng mock server. Thay đổi các contract dưới đây = có thể phá vỡ màn nghiệp vụ về sau → coi như bề mặt ổn định.

## A. Shared Widget Contracts (`lib/core/widgets/`)

Mỗi widget phải render **khớp thị giác prototype** (SC-005) và chỉ lấy giá trị từ token (FR-002/003/005). Bề mặt public (constructor params) là hợp đồng cho MO-003+.

```
AppButton({ required String label, required VoidCallback? onPressed,
            ButtonVariant variant = primary, bool gradient = false })
  // primary: nền accent/aurora, cao AppSpacing.btnH; ghost: viền borderSubtle.

AppIconButton({ required IconData icon, required VoidCallback? onPressed,
                IconButtonVariant variant = ghost })
  // tròn AppSpacing.iconBtn; icon là PhosphorIcons* (FR-005).

FilterChip({ required String label, required bool selected, required VoidCallback onTap })
  // cao chipH, bo rPill; selected → nền accent.

MetaChip({ required String text })   // Space Mono, xs; duration/res/size/count.

PremiumBadge()   // "PRO" bằng aurora gradient text — KHÔNG icon khoá.

WallpaperCard({ required Widget preview,          // MO-002: placeholder gradient; MO-003: video 9:16
                required Color auraColor,          // Aura glow hue (mock/tĩnh ở MO-002)
                required String title, required String author,
                bool premium = false,
                WallpaperMeta? meta,               // {duration,res,size}
                VoidCallback? onTap, VoidCallback? onFav, bool isFav = false })
  // tile wallRatio 9/16, bo rLg; PremiumBadge nếu premium; favorite dùng blush500.

TopBar({ String? title, bool wordmark = false, Widget? trailing })
  // wordmark = Clash Display + aurora; glass blur blurBar.

AppTabBar({ required List<TabItem> items, required int currentIndex,
            required ValueChanged<int> onTap })
  // cao tabbarH; icon active dùng weight fill.

EmptyState({ required IconData icon, required String title,
             required String message, Widget? action })

AppSheet({ required Widget child, EdgeInsets? padding })
  // bo rXl, shadowSheet, blur blurSheet. Đóng-rồi-mở qua addPostFrameCallback (FR-010).

Toast({ required String text })   // nổi ngắn hạn.
```

**Bất biến toàn cục**:
- Không param màu/khoảng cách/typography dạng raw ở call site — widget tự lấy token (FR-002).
- Không lẫn `Icons`/`CupertinoIcons` cho icon nội dung — chỉ `PhosphorIcons*` (FR-005, SC-004).
- Widget thuần trình bày, không business logic (Principle III).

## B. Route Contract (`AppRoutes` + go_router shell — Principle X)

| Route const | Path | Hành vi | MO-002 |
|---|---|---|---|
| `browse` | `/browse` | tab branch 0 | placeholder body |
| `search` | `/search` | tab branch 1 | placeholder body |
| `collections` | `/collections` | tab branch 2 | placeholder body |
| `favorites` | `/favorites` | tab branch 3 | placeholder body |
| `profile` | `/profile` | tab branch 4 | shell rỗng "Bạn" |
| `wallpaperDetail` | `/wallpaper/:id` | push phủ tab | placeholder page |
| `collectionDetail` | `/collection/:id` | push phủ tab | placeholder page |
| `devGallery` | `/dev/gallery` | dev-only | gallery demo widget |

**Bất biến**:
- Điều hướng chỉ qua `context.go/push/pop` (cấm `Navigator.of` — Principle X).
- 5 tab dùng `StatefulShellRoute.indexedStack`; mỗi branch giữ state riêng (SC-001).
- Detail/Collection là route top-level (ngoài shell) → phủ TabBar; back về đúng tab nguồn (FR-008).
- `devGallery` KHÔNG xuất hiện trong luồng người dùng production (FR-006a).

## C. Mock Server Contract (dev-time)

| Khía cạnh | Hợp đồng |
|---|---|
| Nguồn | `contracts/openapi.yaml` v0.3.2 (đồng bộ backend) |
| Chạy | `scripts/mock_server.sh` → `npx @stoplight/prism-cli@5.16.0 mock contracts/openapi.yaml -p 4010` |
| Endpoint chính | `GET /wallpapers`, `GET /wallpapers/{id}`, `GET /collections`, `GET /collections/{id}`, `GET /tags` (trả response mẫu đúng schema — SC-007) |
| App dùng | flavor `development` trỏ `apiBaseUrl` → `http://localhost:4010` (Android emulator `http://10.0.2.2:4010`) |
| Ràng buộc | dev-time only; không đóng vào bundle production |

## D. Nghiệm thu contract

- Widget: render trong **gallery demo dev-only** khớp prototype tương ứng (SC-005); widget test giữ bề mặt public ổn định.
- Route: test điều hướng 5 tab giữ state (SC-001) + push/pop Detail placeholder sạch.
- Mock: `scripts/mock_server.sh` khởi động 1 lệnh, `curl` endpoint chính trả payload đúng schema (SC-007).
