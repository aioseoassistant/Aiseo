import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/calendar_service.dart';
import '../models/calendar_model.dart';
import 'package:device_calendar/device_calendar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendars', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Preferences', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CalendarsTab(),
          _PreferencesTab(),
        ],
      ),
    );
  }
}

class _CalendarsTab extends StatefulWidget {
  const _CalendarsTab();

  @override
  State<_CalendarsTab> createState() => _CalendarsTabState();
}

class _CalendarsTabState extends State<_CalendarsTab> {
  List<CalendarModel> _calendars = [];

  @override
  void initState() {
    super.initState();
    _loadCalendars();
  }

  void _loadCalendars() {
    final storageService = Provider.of<StorageService>(context, listen: false);
    setState(() {
      _calendars = storageService.getCalendars();
    });
  }

  Future<void> _addCalendar() async {
    final calendarService = Provider.of<CalendarService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);

    try {
      final hasPermission = await calendarService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calendar permission denied')),
          );
        }
        return;
      }

      final deviceCalendars = await calendarService.getDeviceCalendars();

      if (!mounted) return;

      // Show dialog to select calendar
      final selected = await showDialog<Calendar>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Calendar'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: deviceCalendars.length,
              itemBuilder: (context, index) {
                final cal = deviceCalendars[index];
                final isAlreadyAdded = _calendars.any(
                  (c) => c.accountId == cal.id,
                );

                return ListTile(
                  title: Text(cal.name ?? 'Unnamed'),
                  subtitle: Text(cal.accountName ?? ''),
                  enabled: !isAlreadyAdded,
                  trailing: isAlreadyAdded
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: isAlreadyAdded
                      ? null
                      : () => Navigator.pop(context, cal),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selected != null) {
        final colors = [
          const Color(0xFF3788d8),
          const Color(0xFFe74c3c),
          const Color(0xFF2ecc71),
          const Color(0xFFf39c12),
          const Color(0xFF9b59b6),
          const Color(0xFF1abc9c),
        ];

        final calendar = CalendarModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: selected.name ?? 'Unnamed Calendar',
          type: selected.accountType ?? 'device',
          accountId: selected.id,
          colorValue: colors[_calendars.length % colors.length].value,
          createdAt: DateTime.now(),
        );

        await storageService.addCalendar(calendar);
        _loadCalendars();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${calendar.name} added')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteCalendar(CalendarModel calendar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Calendar'),
        content: Text('Remove ${calendar.name} from display?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storageService = Provider.of<StorageService>(context, listen: false);
      await storageService.deleteCalendar(calendar.id);
      _loadCalendars();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${calendar.name} removed')),
        );
      }
    }
  }

  Future<void> _toggleVisibility(CalendarModel calendar) async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final updated = calendar.copyWith(isVisible: !calendar.isVisible);
    await storageService.updateCalendar(updated);
    _loadCalendars();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _calendars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No calendars added',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add calendars',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _calendars.length,
                  itemBuilder: (context, index) {
                    final calendar = _calendars[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: calendar.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: calendar.color,
                          ),
                        ),
                        title: Text(
                          calendar.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(calendar.type),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                calendar.isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: calendar.isVisible ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleVisibility(calendar),
                              tooltip: calendar.isVisible ? 'Hide' : 'Show',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCalendar(calendar),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addCalendar,
              icon: const Icon(Icons.add),
              label: const Text('Add Calendar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreferencesTab extends StatefulWidget {
  const _PreferencesTab();

  @override
  State<_PreferencesTab> createState() => _PreferencesTabState();
}

class _PreferencesTabState extends State<_PreferencesTab> {
  int _refreshInterval = 5;
  String _timeFormat = '12h';
  int _firstDayOfWeek = 0;
  bool _showLocation = true;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final storageService = Provider.of<StorageService>(context, listen: false);
    setState(() {
      _refreshInterval = storageService.getSetting('refreshInterval', 5);
      _timeFormat = storageService.getSetting('timeFormat', '12h');
      _firstDayOfWeek = storageService.getSetting('firstDayOfWeek', 0);
      _showLocation = storageService.getSetting('showLocation', true);
      _showDescription = storageService.getSetting('showDescription', false);
    });
  }

  Future<void> _saveSettings() async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    await storageService.saveSetting('refreshInterval', _refreshInterval);
    await storageService.saveSetting('timeFormat', _timeFormat);
    await storageService.saveSetting('firstDayOfWeek', _firstDayOfWeek);
    await storageService.saveSetting('showLocation', _showLocation);
    await storageService.saveSetting('showDescription', _showDescription);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Display Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Refresh Interval'),
                subtitle: Text('$_refreshInterval minutes'),
                trailing: DropdownButton<int>(
                  value: _refreshInterval,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 min')),
                    DropdownMenuItem(value: 5, child: Text('5 min')),
                    DropdownMenuItem(value: 15, child: Text('15 min')),
                    DropdownMenuItem(value: 30, child: Text('30 min')),
                  ],
                  onChanged: (value) {
                    setState(() => _refreshInterval = value!);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Time Format'),
                subtitle: Text(_timeFormat == '12h' ? '12-hour' : '24-hour'),
                trailing: DropdownButton<String>(
                  value: _timeFormat,
                  items: const [
                    DropdownMenuItem(value: '12h', child: Text('12-hour')),
                    DropdownMenuItem(value: '24h', child: Text('24-hour')),
                  ],
                  onChanged: (value) {
                    setState(() => _timeFormat = value!);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('First Day of Week'),
                subtitle: Text(_firstDayOfWeek == 0 ? 'Sunday' : 'Monday'),
                trailing: DropdownButton<int>(
                  value: _firstDayOfWeek,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Sunday')),
                    DropdownMenuItem(value: 1, child: Text('Monday')),
                  ],
                  onChanged: (value) {
                    setState(() => _firstDayOfWeek = value!);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Event Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Show Location'),
                subtitle: const Text('Display event locations'),
                value: _showLocation,
                onChanged: (value) {
                  setState(() => _showLocation = value);
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Show Description'),
                subtitle: const Text('Display event descriptions'),
                value: _showDescription,
                onChanged: (value) {
                  setState(() => _showDescription = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ),
      ],
    );
  }
}
