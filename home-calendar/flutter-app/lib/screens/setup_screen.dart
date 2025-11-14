import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_calendar/device_calendar.dart';
import '../services/calendar_service.dart';
import '../services/storage_service.dart';
import '../models/calendar_model.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  List<Calendar> _availableCalendars = [];
  List<String> _selectedCalendarIds = [];
  bool _isLoading = false;

  final List<Color> _calendarColors = [
    const Color(0xFF3788d8),
    const Color(0xFFe74c3c),
    const Color(0xFF2ecc71),
    const Color(0xFFf39c12),
    const Color(0xFF9b59b6),
    const Color(0xFF1abc9c),
    const Color(0xFFe91e63),
    const Color(0xFFff5722),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadCalendars();
  }

  Future<void> _checkPermissionsAndLoadCalendars() async {
    final calendarService = Provider.of<CalendarService>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final hasPermission = await calendarService.requestPermissions();

      if (!hasPermission) {
        _showPermissionDialog();
        setState(() => _isLoading = false);
        return;
      }

      final calendars = await calendarService.getDeviceCalendars();

      setState(() {
        _availableCalendars = calendars;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading calendars: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Permission Required'),
        content: const Text(
          'This app needs access to your device calendars to display events. '
          'Please grant permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkPermissionsAndLoadCalendars();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSetup() async {
    final storageService = Provider.of<StorageService>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      // Save selected calendars
      int colorIndex = 0;
      for (final calendarId in _selectedCalendarIds) {
        final deviceCalendar = _availableCalendars.firstWhere(
          (cal) => cal.id == calendarId,
        );

        final calendar = CalendarModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + colorIndex.toString(),
          name: deviceCalendar.name ?? 'Unnamed Calendar',
          type: deviceCalendar.accountType ?? 'device',
          accountId: calendarId,
          colorValue: _calendarColors[colorIndex % _calendarColors.length].value,
          createdAt: DateTime.now(),
        );

        await storageService.addCalendar(calendar);
        colorIndex++;
      }

      // Mark first launch as complete
      await storageService.completeFirstLaunch();

      setState(() => _isLoading = false);

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error completing setup: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 48, color: Color(0xFF3788d8)),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Home Calendar',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2c3e50),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Let\'s get your calendar set up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildStepContent(),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () => setState(() => _currentStep--),
                          child: const Text('Back'),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton(
                        onPressed: _currentStep == 1
                            ? (_selectedCalendarIds.isNotEmpty ? _completeSetup : null)
                            : () => setState(() => _currentStep++),
                        child: Text(_currentStep == 1 ? 'Finish' : 'Next'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildCalendarSelectionStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcomeStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 120,
              color: Color(0xFF3788d8),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Family Calendar Hub',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Display everyone\'s schedules in one beautiful place.\n'
              'Syncs with Google Calendar, Apple Calendar, and more.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 48,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: const [
                _FeatureItem(
                  icon: Icons.sync,
                  title: 'Auto-Sync',
                  description: 'Updates every 5 minutes',
                ),
                _FeatureItem(
                  icon: Icons.family_restroom,
                  title: 'Multi-Calendar',
                  description: 'Everyone\'s events together',
                ),
                _FeatureItem(
                  icon: Icons.touch_app,
                  title: 'Touch-Friendly',
                  description: 'Easy to navigate',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Calendars to Display',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which calendars you want to show on your display',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _availableCalendars.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No calendars found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make sure you have calendars set up on your device',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _availableCalendars.length,
                    itemBuilder: (context, index) {
                      final calendar = _availableCalendars[index];
                      final isSelected = _selectedCalendarIds.contains(calendar.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedCalendarIds.add(calendar.id!);
                              } else {
                                _selectedCalendarIds.remove(calendar.id);
                              }
                            });
                          },
                          title: Text(
                            calendar.name ?? 'Unnamed Calendar',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            calendar.accountName ?? calendar.accountType ?? 'Device Calendar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          secondary: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _calendarColors[index % _calendarColors.length]
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: _calendarColors[index % _calendarColors.length],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_selectedCalendarIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3788d8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF3788d8)),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedCalendarIds.length} calendar(s) selected',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3788d8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3788d8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: const Color(0xFF3788d8)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
