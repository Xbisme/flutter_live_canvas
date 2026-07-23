// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_tag_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTagCreateRequest _$AdminTagCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminTagCreateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['slug', 'name']);
  final val = AdminTagCreateRequest(
    slug: $checkedConvert('slug', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AdminTagCreateRequestToJson(
  AdminTagCreateRequest instance,
) => <String, dynamic>{'slug': instance.slug, 'name': instance.name};
