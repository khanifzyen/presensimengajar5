import 'package:pocketbase/pocketbase.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // info, success, warning, error
  final bool isRead;
  final Map<String, dynamic>? data;
  final String created;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.data,
    required this.created,
  });

  factory NotificationModel.fromRecord(RecordModel record) {
    return NotificationModel(
      id: record.id,
      userId: record.getStringValue('user_id'),
      title: record.getStringValue('title'),
      message: record.getStringValue('message'),
      type: record.getStringValue('type'),
      isRead: record.getBoolValue('is_read'),
      data: record.data['data'] is Map<String, dynamic>
          ? record.data['data']
          : null,
      created: record.getStringValue('created'),
    );
  }
}

class SettingModel {
  final String id;
  final String key;
  final String value;
  final String type; // text, number, boolean, json
  final String description;
  final String category;

  SettingModel({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
    required this.description,
    required this.category,
  });

  factory SettingModel.fromRecord(RecordModel record) {
    return SettingModel(
      id: record.id,
      key: record.getStringValue('key'),
      value: record.getStringValue('value'),
      type: record.getStringValue('type'),
      description: record.getStringValue('description'),
      category: record.getStringValue('category'),
    );
  }
}
