import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'calendar_model.g.dart';

@HiveType(typeId: 0)
class CalendarModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // 'google', 'apple', 'device'

  @HiveField(3)
  String? accountId; // For device calendar

  @HiveField(4)
  int colorValue; // Store color as int

  @HiveField(5)
  bool isVisible;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastSyncedAt;

  CalendarModel({
    required this.id,
    required this.name,
    required this.type,
    this.accountId,
    required this.colorValue,
    this.isVisible = true,
    required this.createdAt,
    this.lastSyncedAt,
  });

  Color get color => Color(colorValue);

  set color(Color value) {
    colorValue = value.value;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'accountId': accountId,
        'colorValue': colorValue,
        'isVisible': isVisible,
        'createdAt': createdAt.toIso8601String(),
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  factory CalendarModel.fromJson(Map<String, dynamic> json) => CalendarModel(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        accountId: json['accountId'],
        colorValue: json['colorValue'],
        isVisible: json['isVisible'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.parse(json['lastSyncedAt'])
            : null,
      );

  CalendarModel copyWith({
    String? id,
    String? name,
    String? type,
    String? accountId,
    int? colorValue,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
  }) {
    return CalendarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      colorValue: colorValue ?? this.colorValue,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
