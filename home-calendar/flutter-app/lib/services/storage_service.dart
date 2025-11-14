import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_model.dart';

class StorageService {
  static const String _calendarsBoxName = 'calendars';
  static const String _settingsKey = 'settings';
  static const String _isFirstLaunchKey = 'isFirstLaunch';

  late Box<CalendarModel> _calendarsBox;
  late SharedPreferences _prefs;

  /// Initialize storage
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CalendarModelAdapter());
    }

    // Open boxes
    _calendarsBox = await Hive.openBox<CalendarModel>(_calendarsBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if this is the first launch
  bool isFirstLaunch() {
    return _prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    await _prefs.setBool(_isFirstLaunchKey, false);
  }

  /// Get all calendars
  List<CalendarModel> getCalendars() {
    return _calendarsBox.values.toList();
  }

  /// Add a calendar
  Future<void> addCalendar(CalendarModel calendar) async {
    await _calendarsBox.put(calendar.id, calendar);
  }

  /// Update a calendar
  Future<void> updateCalendar(CalendarModel calendar) async {
    await _calendarsBox.put(calendar.id, calendar);
  }

  /// Delete a calendar
  Future<void> deleteCalendar(String id) async {
    await _calendarsBox.delete(id);
  }

  /// Get a calendar by ID
  CalendarModel? getCalendar(String id) {
    return _calendarsBox.get(id);
  }

  /// Save settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, settings.toString());
  }

  /// Get settings
  Map<String, dynamic> getSettings() {
    final settingsString = _prefs.getString(_settingsKey);
    if (settingsString == null) {
      return _defaultSettings();
    }

    // Parse settings (simplified - in production use JSON)
    return _defaultSettings();
  }

  Map<String, dynamic> _defaultSettings() {
    return {
      'refreshInterval': 5, // minutes
      'timeFormat': '12h',
      'firstDayOfWeek': 0, // Sunday
      'showLocation': true,
      'showDescription': false,
      'kioskMode': false,
    };
  }

  /// Get specific setting
  T getSetting<T>(String key, T defaultValue) {
    final settings = getSettings();
    return settings[key] ?? defaultValue;
  }

  /// Save specific setting
  Future<void> saveSetting(String key, dynamic value) async {
    final settings = getSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _calendarsBox.clear();
    await _prefs.clear();
  }

  /// Export calendars
  List<Map<String, dynamic>> exportCalendars() {
    return getCalendars().map((cal) => cal.toJson()).toList();
  }

  /// Import calendars
  Future<void> importCalendars(List<Map<String, dynamic>> calendarsJson) async {
    for (final json in calendarsJson) {
      final calendar = CalendarModel.fromJson(json);
      await addCalendar(calendar);
    }
  }
}
