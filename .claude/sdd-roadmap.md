# LiveCanvas Backend v1.0 — Spec Roadmap

> Repo: `livecanvas-backend`. Track song song bên repo `livecanvas-mobile` (spec `MO-NNN`) — không sống trong repo này, chỉ tham chiếu tại các điểm đồng bộ contract.
>
> **Vai trò file này**: pure planning cho track backend. Trạng thái hiện tại → [`project-context.md`](project-context.md). Ship history → [`changelog.md`](changelog.md).
>
> Last updated: 2026-07-23 (Chưa có spec nào merge · contract v0.3.0 — thêm resource Collection)
> Full requirements: `docs/PRD.md`

---

## SDD Workflow For Each Spec

```
/speckit.specify → /speckit.clarify → /speckit.plan → /speckit.tasks → /speckit.implement
```

Branch: `BE-NNN-feature-name`, folder `specs/BE-NNN-feature-name/`

---

## Dependency Graph

```
Spec #000: API Contract Freeze                    ← SHARED — phối hợp với repo mobile
           (contracts/openapi.yaml +
            .claude/api-context.md v1.0)
    │
    ▼
BE-001: Backend Foundation
(Django+DRF skeleton, PostgreSQL,
 S3+CDN config, env dev/staging/prod, CI)
    │
    ▼
BE-002: Core Content API                          ⇄ Điểm đồng bộ: repo mobile cần API này
(Category, Wallpaper models,                          thật (thay mock) trước khi merge MO-002
 public list/detail/filter/search)
    │
    ▼
BE-003: Admin Upload Pipeline
(Presigned upload 2 bước, Celery+Redis,
 transcode ffmpeg, thumbnail, malware scan,
 Admin CRUD)
    │
    ▼
BE-004: IAP Verify & Entitlement                  ⇄ Điểm đồng bộ: repo mobile cần endpoint
(verify-receipt, webhook Apple/Google,                này hoạt động thật trước khi merge MO-005
 subscription-status, entitlement gate
 trên download-url)
    │
    ▼
BE-005: Security Hardening & Production Readiness
(Rate limit, WAF, audit log, Sentry, load test)
    │
    ▼
BE-006: Deploy & Launch Support                   ⇄ Điểm đồng bộ: repo mobile chờ backend
(Staging→Production deploy, backup, runbook)          production trước khi submit store (MO-006)
```

---

## Spec Details

### Spec #000: API Contract Freeze

- **Status**: 🟡 In progress (v0.3.0 — thêm resource `Collection`, chờ xác nhận cuối)
- **Không tạo branch riêng** — review trực tiếp `contracts/openapi.yaml` + `.claude/api-context.md`, phối hợp với repo `livecanvas-mobile`.
- **Thứ tự bắt buộc**: `docs/screen-inventory.md` (màn hình cần gì) → mới tới contract. Không sửa contract trực tiếp mà không cập nhật screen-inventory trước.
- **Checklist**: xem bản đầy đủ trong `api-context.md` §Quy ước chung; xác nhận error code catalog đã cover hết case; xác nhận entitlement luôn quyết ở `download-url` (kể cả bộ sưu tập premium — "Tải tất cả" chỉ lặp gọi download-url); xác nhận cursor pagination đã áp dụng đúng cho mọi list endpoint lớn; xác nhận tag + collection là curated (không free-form); xác nhận `GET /collections` không phân trang còn `GET /collections/{id}` nhúng items đúng thứ tự.
- **v0.3.0 — Collection**: resource mới `Collection` (bộ sưu tập curated, many-to-many có thứ tự với `Wallpaper`) + `GET /collections`, `GET /collections/{id}`; `Wallpaper.collections: CollectionRef[]`; admin `POST/GET/PATCH/DELETE /admin/collections`; error `COLLECTION_SLUG_CONFLICT`, `WALLPAPER_NOT_FOUND`.

### BE-001: Backend Foundation

- **Status**: ⬜ Not started
- **Branch**: `BE-001-backend-foundation`
- **Depends on**: #000
- **Scope**: Django+DRF skeleton, `apps/wallpapers`, `apps/uploads`, `apps/iap`; PostgreSQL + `django-environ`; S3 (`django-storages`) + CDN; CI (`ruff`, `pytest-django`); middleware `X-App-Key`.

### BE-002: Core Content API

- **Status**: ⬜ Not started
- **Branch**: `BE-002-core-content-api`
- **Depends on**: BE-001
- **Scope**: Model `Category`/`Tag`/`Wallpaper`/`Collection` (many-to-many Wallpaper↔Tag; many-to-many **có thứ tự** Collection↔Wallpaper qua bảng nối `position`) đúng `openapi.yaml`; `GET /categories`, `GET /tags`, `GET /wallpapers` (cursor pagination), `GET /wallpapers/{id}` (populate `collections`), `POST /wallpapers/batch`; `GET /collections` (không phân trang), `GET /collections/{id}` (nhúng `items` đúng thứ tự); `POST/GET/DELETE /admin/tags` (curated tag management); seed script Pixabay/Pexels/Mixkit (lưu `source_url`, `license_type`); `download-url` trả mock/`501` tạm — hoàn thiện thật ở BE-004.
- **⚠️ Điểm đồng bộ**: báo repo mobile khi merge — họ cần chuyển từ mock server sang API thật (MO-002).

### BE-003: Admin Upload Pipeline

- **Status**: ⬜ Not started
- **Branch**: `BE-003-admin-upload-pipeline`
- **Depends on**: BE-002
- **Scope**: `POST /admin/uploads/presign`, `POST /admin/wallpapers` (validate `tag_ids` tồn tại → `TAG_NOT_FOUND` nếu sai), `GET/DELETE /admin/wallpapers` (cursor pagination); `POST/GET/PATCH/DELETE /admin/collections` (curated collection management — validate `wallpaper_ids` tồn tại → `WALLPAPER_NOT_FOUND`, `slug` trùng → `COLLECTION_SLUG_CONFLICT`, cover ảnh qua presign → `cover_upload_key`, `wallpaper_ids` giữ thứ tự); Celery worker (validate MIME thật, scan malware ClamAV, transcode ffmpeg, thumbnail + preview watermark); `AdminBearer` JWT riêng; audit log.

### BE-004: IAP Verify & Entitlement

- **Status**: ⬜ Not started
- **Branch**: `BE-004-iap-verify-entitlement`
- **Depends on**: BE-002
- **Scope**: `POST /iap/verify-receipt` (App Store Server API / Google Play Developer API); `POST /iap/webhook/apple` + `/google` (verify chữ ký JWS/Pub-Sub); `GET /iap/subscription-status`; hoàn thiện entitlement check thật ở `download-url`; presigned URL premium hết hạn ≤5 phút.
- **⚠️ Điểm đồng bộ**: báo repo mobile khi merge — họ cần endpoint này hoạt động thật để test MO-005 end-to-end.

### BE-005: Security Hardening & Production Readiness

- **Status**: ⬜ Not started
- **Branch**: `BE-005-security-hardening`
- **Depends on**: BE-003, BE-004
- **Scope**: Rate limiting, WAF/CDN rules, Sentry, load test (Locust) cho presigned URL + verify-receipt, OWASP Top 10 review (đặc biệt IDOR ở `download-url`).

### BE-006: Deploy & Launch Support

- **Status**: ⬜ Not started
- **Branch**: `BE-006-deploy-launch`
- **Depends on**: BE-005
- **Scope**: Staging → Production deploy, backup định kỳ, runbook vận hành.
- **⚠️ Điểm đồng bộ**: báo repo mobile khi production sẵn sàng — họ cần trước khi submit store (MO-006).
