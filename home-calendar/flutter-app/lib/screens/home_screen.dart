import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/calendar_service.dart';
import '../services/storage_service.dart';
import '../models/calendar_model.dart';
import '../models/event_model.dart';
import '../widgets/day_column.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentWeekStart = DateTime.now();
  List<EventModel> _events = [];
  bool _isLoading = false;
  DateTime? _lastSynced;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(DateTime.now());
    _loadEvents();

    // Auto-refresh every 5 minutes
    Future.delayed(Duration.zero, () {
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _loadEvents();
        _startAutoRefresh();
      }
    });
  }

  DateTime _getWeekStart(DateTime date) {
    final firstDayOfWeek = Provider.of<StorageService>(context, listen: false)
        .getSetting<int>('firstDayOfWeek', 0);

    int daysToSubtract = date.weekday % 7 - firstDayOfWeek;
    if (daysToSubtract < 0) daysToSubtract += 7;

    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final storageService = Provider.of<StorageService>(context, listen: false);
      final calendarService = Provider.of<CalendarService>(context, listen: false);

      final calendars = storageService.getCalendars();

      if (calendars.isEmpty) {
        setState(() {
          _events = [];
          _isLoading = false;
        });
        return;
      }

      final startDate = _currentWeekStart;
      final endDate = startDate.add(const Duration(days: 7));

      final events = await calendarService.fetchAllEvents(
        calendars: calendars,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _events = events;
        _lastSynced = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    _loadEvents();
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    _loadEvents();
  }

  void _goToToday() {
    setState(() {
      _currentWeekStart = _getWeekStart(DateTime.now());
    });
    _loadEvents();
  }

  List<DateTime> _getWeekDates() {
    return List.generate(
      7,
      (index) => _currentWeekStart.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthYear = DateFormat.yMMMM().format(_currentWeekStart);
    final weekDates = _getWeekDates();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Month/Year
                Expanded(
                  child: Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2c3e50),
                    ),
                  ),
                ),

                // Navigation
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  onPressed: _previousWeek,
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _goToToday,
                  child: const Text('Today'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  onPressed: _nextWeek,
                ),

                const SizedBox(width: 32),

                // Sync Status
                Row(
                  children: [
                    Icon(
                      Icons.sync,
                      size: 20,
                      color: _isLoading ? Colors.blue : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading
                          ? 'Syncing...'
                          : _lastSynced != null
                              ? 'Synced ${_formatSyncTime(_lastSynced!)}'
                              : 'Not synced',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Settings Button
                IconButton(
                  icon: const Icon(Icons.settings, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ).then((_) => _loadEvents());
                  },
                ),
              ],
            ),
          ),

          // Calendar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: weekDates.map((date) {
                  final isToday = _isToday(date);
                  final dayEvents = _events.where((e) => e.isSameDay(date)).toList();

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DayColumn(
                        date: date,
                        events: dayEvents,
                        isToday: isToday,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
