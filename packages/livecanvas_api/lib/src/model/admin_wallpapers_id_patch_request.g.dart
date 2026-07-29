// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_wallpapers_id_patch_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminWallpapersIdPatchRequest _$AdminWallpapersIdPatchRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminWallpapersIdPatchRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['description']);
  final val = AdminWallpapersIdPatchRequest(
    description: $checkedConvert('description', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AdminWallpapersIdPatchRequestToJson(
  AdminWallpapersIdPatchRequest instance,
) => <String, dynamic>{'description': instance.description};
