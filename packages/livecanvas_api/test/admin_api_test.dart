import 'package:test/test.dart';
import 'package:livecanvas_api/livecanvas_api.dart';

/// tests for AdminApi
void main() {
  final instance = LivecanvasApi().getAdminApi();

  group(AdminApi, () {
    // Danh sách bộ sưu tập (meta + wallpaper_count, không nhúng items, không phân trang)
    //
    //Future<List<Collection>> adminCollectionsGet() async
    test('test adminCollectionsGet', () async {
      // TODO
    });

    // Xóa bộ sưu tập (không xóa wallpaper thành viên)
    //
    //Future adminCollectionsIdDelete(int id) async
    test('test adminCollectionsIdDelete', () async {
      // TODO
    });

    // Sửa meta hoặc thêm/bớt/sắp xếp wallpaper (wallpaper_ids thay thế toàn bộ danh sách)
    //
    //Future<Collection> adminCollectionsIdPatch(int id, AdminCollectionUpdateRequest adminCollectionUpdateRequest) async
    test('test adminCollectionsIdPatch', () async {
      // TODO
    });

    // Tạo bộ sưu tập — wallpaper_ids có thứ tự, phải trỏ tới wallpaper đã tồn tại
    //
    //Future<Collection> adminCollectionsPost(AdminCollectionCreateRequest adminCollectionCreateRequest) async
    test('test adminCollectionsPost', () async {
      // TODO
    });

    // Danh sách tag kèm wallpaper_count, để admin quyết định xóa tag nào
    //
    //Future<List<Tag>> adminTagsGet() async
    test('test adminTagsGet', () async {
      // TODO
    });

    // Xóa tag (chặn nếu vẫn còn wallpaper đang dùng — trả 409)
    //
    //Future adminTagsIdDelete(int id) async
    test('test adminTagsIdDelete', () async {
      // TODO
    });

    // Tạo tag mới (curated — đây là cách DUY NHẤT để thêm tag)
    //
    //Future<Tag> adminTagsPost(AdminTagCreateRequest adminTagCreateRequest) async
    test('test adminTagsPost', () async {
      // TODO
    });

    //Future<PresignedUploadResponse> adminUploadsPresignPost(PresignedUploadRequest presignedUploadRequest) async
    test('test adminUploadsPresignPost', () async {
      // TODO
    });

    //Future<WallpaperCursorPage> adminWallpapersGet({ String cursor, int limit, String status }) async
    test('test adminWallpapersGet', () async {
      // TODO
    });

    //Future adminWallpapersIdDelete(int id) async
    test('test adminWallpapersIdDelete', () async {
      // TODO
    });

    // Tạo wallpaper — tag_ids phải trỏ tới tag đã tồn tại (curated, xem /admin/tags)
    //
    //Future<Wallpaper> adminWallpapersPost(AdminWallpaperCreateRequest adminWallpaperCreateRequest) async
    test('test adminWallpapersPost', () async {
      // TODO
    });
  });
}
