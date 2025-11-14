import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import 'event_card.dart';

class DayColumn extends StatelessWidget {
  final DateTime date;
  final List<EventModel> events;
  final bool isToday;

  const DayColumn({
    super.key,
    required this.date,
    required this.events,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat.E().format(date); // Mon, Tue, etc.
    final dayNumber = date.day;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF3788d8) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: isToday
                  ? null
                  : Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.white : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : const Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No events',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: EventCard(event: events[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
