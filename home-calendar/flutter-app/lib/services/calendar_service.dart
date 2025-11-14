import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/calendar_model.dart';
import '../models/event_model.dart';

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Request calendar permissions
  Future<bool> requestPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();

    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return false;
      }
    }

    return true;
  }

  /// Get all available calendars from device
  Future<List<Calendar>> getDeviceCalendars() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Calendar permissions not granted');
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

    if (!calendarsResult.isSuccess) {
      throw Exception('Failed to retrieve calendars');
    }

    return calendarsResult.data ?? [];
  }

  /// Fetch events from a specific calendar
  Future<List<EventModel>> fetchEventsForCalendar({
    required String calendarId,
    required DateTime startDate,
    required DateTime endDate,
    required Color calendarColor,
    required String calendarName,
  }) async {
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    if (!eventsResult.isSuccess) {
      throw Exception('Failed to fetch events');
    }

    final events = eventsResult.data ?? [];

    return events.map((event) {
      return EventModel(
        id: event.eventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        calendarId: calendarId,
        title: event.title ?? 'Untitled Event',
        description: event.description,
        location: event.location,
        start: event.start ?? DateTime.now(),
        end: event.end ?? DateTime.now().add(const Duration(hours: 1)),
        isAllDay: event.allDay ?? false,
        color: calendarColor,
        calendarName: calendarName,
      );
    }).toList();
  }

  /// Fetch events from multiple calendars
  Future<List<EventModel>> fetchAllEvents({
    required List<CalendarModel> calendars,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allEvents = <EventModel>[];

    for (final calendar in calendars) {
      if (!calendar.isVisible || calendar.accountId == null) continue;

      try {
        final events = await fetchEventsForCalendar(
          calendarId: calendar.accountId!,
          startDate: startDate,
          endDate: endDate,
          calendarColor: calendar.color,
          calendarName: calendar.name,
        );

        allEvents.addAll(events);
      } catch (e) {
        debugPrint('Error fetching events for ${calendar.name}: $e');
      }
    }

    // Sort by start time
    allEvents.sort((a, b) => a.start.compareTo(b.start));

    return allEvents;
  }

  /// Get events for a specific day
  List<EventModel> getEventsForDay(List<EventModel> allEvents, DateTime day) {
    return allEvents.where((event) => event.isSameDay(day)).toList();
  }

  /// Get events grouped by day for a date range
  Map<DateTime, List<EventModel>> groupEventsByDay(
    List<EventModel> events,
    DateTime startDate,
    DateTime endDate,
  ) {
    final grouped = <DateTime, List<EventModel>>{};

    // Initialize all days in range
    var current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final normalized = DateTime(current.year, current.month, current.day);
      grouped[normalized] = [];
      current = current.add(const Duration(days: 1));
    }

    // Group events
    for (final event in events) {
      final eventDate =
          DateTime(event.start.year, event.start.month, event.start.day);

      if (grouped.containsKey(eventDate)) {
        grouped[eventDate]!.add(event);
      }
    }

    return grouped;
  }

  /// Check if calendar permissions are granted
  Future<bool> checkPermissions() async {
    final result = await _deviceCalendarPlugin.hasPermissions();
    return result.isSuccess && (result.data ?? false);
  }
}
