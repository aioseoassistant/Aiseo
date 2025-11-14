import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String calendarId;
  final String title;
  final String? description;
  final String? location;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final Color color;
  final String calendarName;

  EventModel({
    required this.id,
    required this.calendarId,
    required this.title,
    this.description,
    this.location,
    required this.start,
    required this.end,
    this.isAllDay = false,
    required this.color,
    required this.calendarName,
  });

  bool isSameDay(DateTime date) {
    return start.year == date.year &&
        start.month == date.month &&
        start.day == date.day;
  }

  String get timeString {
    if (isAllDay) return 'All day';

    final startTime = TimeOfDay.fromDateTime(start);
    final endTime = TimeOfDay.fromDateTime(end);

    return '${startTime.format(null as BuildContext)} - ${endTime.format(null as BuildContext)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'calendarId': calendarId,
        'title': title,
        'description': description,
        'location': location,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'isAllDay': isAllDay,
        'colorValue': color.value,
        'calendarName': calendarName,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'],
        calendarId: json['calendarId'],
        title: json['title'],
        description: json['description'],
        location: json['location'],
        start: DateTime.parse(json['start']),
        end: DateTime.parse(json['end']),
        isAllDay: json['isAllDay'] ?? false,
        color: Color(json['colorValue']),
        calendarName: json['calendarName'],
      );

  EventModel copyWith({
    String? id,
    String? calendarId,
    String? title,
    String? description,
    String? location,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    Color? color,
    String? calendarName,
  }) {
    return EventModel(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      calendarName: calendarName ?? this.calendarName,
    );
  }
}
