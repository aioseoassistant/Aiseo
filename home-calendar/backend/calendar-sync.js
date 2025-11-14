const fetch = require('node-fetch');
const ical = require('node-ical');
const ICAL = require('ical.js');

class CalendarSync {
  constructor() {
    this.userAgent = 'HomeCalendar/1.0';
  }

  /**
   * Fetch events from a calendar based on its type
   * @param {Object} calendar - Calendar configuration
   * @returns {Array} Array of events
   */
  async fetchEvents(calendar) {
    switch (calendar.type) {
      case 'ical':
      case 'google':
      case 'icloud':
        return await this.fetchICalEvents(calendar);
      case 'caldav':
        return await this.fetchCalDAVEvents(calendar);
      default:
        throw new Error(`Unsupported calendar type: ${calendar.type}`);
    }
  }

  /**
   * Fetch events from iCal/ICS URL (works for Google Calendar public URLs, iCloud shared calendars)
   */
  async fetchICalEvents(calendar) {
    try {
      if (!calendar.url) {
        throw new Error('Calendar URL is required for iCal calendars');
      }

      console.log(`Fetching iCal events from: ${calendar.name}`);

      const response = await fetch(calendar.url, {
        headers: {
          'User-Agent': this.userAgent
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const icalData = await response.text();
      const events = await ical.async.parseICS(icalData);

      const parsedEvents = [];
      const now = new Date();
      const oneMonthFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

      for (const key in events) {
        const event = events[key];

        if (event.type === 'VEVENT') {
          // Handle recurring events
          if (event.rrule) {
            const occurrences = this.expandRecurringEvent(event, now, oneMonthFromNow);
            parsedEvents.push(...occurrences);
          } else {
            // Single event
            const startDate = event.start;
            const endDate = event.end;

            // Only include events within our date range
            if (startDate >= now || endDate >= now) {
              parsedEvents.push({
                id: event.uid || key,
                title: event.summary || 'Untitled Event',
                description: event.description || '',
                location: event.location || '',
                start: startDate.toISOString(),
                end: endDate.toISOString(),
                allDay: this.isAllDayEvent(event),
                recurring: false
              });
            }
          }
        }
      }

      console.log(`Fetched ${parsedEvents.length} events from ${calendar.name}`);
      return parsedEvents;

    } catch (error) {
      console.error(`Error fetching iCal events from ${calendar.name}:`, error.message);
      throw error;
    }
  }

  /**
   * Fetch events from CalDAV server
   */
  async fetchCalDAVEvents(calendar) {
    try {
      if (!calendar.url || !calendar.username || !calendar.password) {
        throw new Error('CalDAV calendars require URL, username, and password');
      }

      console.log(`Fetching CalDAV events from: ${calendar.name}`);

      // Create basic auth header
      const auth = Buffer.from(`${calendar.username}:${calendar.password}`).toString('base64');

      // CalDAV REPORT request to get events
      const now = new Date();
      const oneMonthFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

      const requestBody = `<?xml version="1.0" encoding="utf-8" ?>
<C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
  <D:prop>
    <D:getetag/>
    <C:calendar-data/>
  </D:prop>
  <C:filter>
    <C:comp-filter name="VCALENDAR">
      <C:comp-filter name="VEVENT">
        <C:time-range start="${this.formatCalDAVDate(now)}" end="${this.formatCalDAVDate(oneMonthFromNow)}"/>
      </C:comp-filter>
    </C:comp-filter>
  </C:filter>
</C:calendar-query>`;

      const response = await fetch(calendar.url, {
        method: 'REPORT',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/xml; charset=utf-8',
          'Depth': '1',
          'User-Agent': this.userAgent
        },
        body: requestBody
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const xmlData = await response.text();

      // Parse the CalDAV response
      // This is a simplified version - a production version would use an XML parser
      const events = await this.parseCalDAVResponse(xmlData);

      console.log(`Fetched ${events.length} events from ${calendar.name}`);
      return events;

    } catch (error) {
      console.error(`Error fetching CalDAV events from ${calendar.name}:`, error.message);
      throw error;
    }
  }

  /**
   * Expand recurring events into individual occurrences
   */
  expandRecurringEvent(event, startDate, endDate) {
    const occurrences = [];

    try {
      // Use rrule to expand the event
      const dates = event.rrule.between(startDate, endDate, true);

      dates.forEach(date => {
        const duration = event.end - event.start;
        const occurrenceEnd = new Date(date.getTime() + duration);

        occurrences.push({
          id: `${event.uid || event.id}_${date.getTime()}`,
          title: event.summary || 'Untitled Event',
          description: event.description || '',
          location: event.location || '',
          start: date.toISOString(),
          end: occurrenceEnd.toISOString(),
          allDay: this.isAllDayEvent(event),
          recurring: true,
          recurringEventId: event.uid || event.id
        });
      });

    } catch (error) {
      console.error('Error expanding recurring event:', error);
    }

    return occurrences;
  }

  /**
   * Check if an event is all-day
   */
  isAllDayEvent(event) {
    // Check if the event doesn't have a specific time
    if (event.datetype === 'date') {
      return true;
    }

    // Check if start and end times are exactly midnight
    const start = new Date(event.start);
    const end = new Date(event.end);

    return (
      start.getHours() === 0 &&
      start.getMinutes() === 0 &&
      start.getSeconds() === 0 &&
      end.getHours() === 0 &&
      end.getMinutes() === 0 &&
      end.getSeconds() === 0
    );
  }

  /**
   * Format date for CalDAV queries
   */
  formatCalDAVDate(date) {
    return date.toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z';
  }

  /**
   * Parse CalDAV XML response
   */
  async parseCalDAVResponse(xmlData) {
    const events = [];

    try {
      // Extract calendar data from XML
      // This is a simplified regex-based extraction
      // Production code should use a proper XML parser
      const calendarDataRegex = /<C:calendar-data>([\s\S]*?)<\/C:calendar-data>/g;
      let match;

      while ((match = calendarDataRegex.exec(xmlData)) !== null) {
        const icalData = match[1]
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>')
          .replace(/&amp;/g, '&')
          .replace(/&quot;/g, '"')
          .replace(/&#13;/g, '\r')
          .trim();

        // Parse the iCal data
        const parsedEvents = await ical.async.parseICS(icalData);

        for (const key in parsedEvents) {
          const event = parsedEvents[key];

          if (event.type === 'VEVENT') {
            events.push({
              id: event.uid || key,
              title: event.summary || 'Untitled Event',
              description: event.description || '',
              location: event.location || '',
              start: event.start.toISOString(),
              end: event.end.toISOString(),
              allDay: this.isAllDayEvent(event),
              recurring: !!event.rrule
            });
          }
        }
      }

    } catch (error) {
      console.error('Error parsing CalDAV response:', error);
    }

    return events;
  }

  /**
   * Validate calendar configuration
   */
  validateCalendar(calendar) {
    if (!calendar.type) {
      throw new Error('Calendar type is required');
    }

    if (!calendar.name) {
      throw new Error('Calendar name is required');
    }

    switch (calendar.type) {
      case 'ical':
      case 'google':
      case 'icloud':
        if (!calendar.url) {
          throw new Error('URL is required for iCal/Google/iCloud calendars');
        }
        break;

      case 'caldav':
        if (!calendar.url || !calendar.username || !calendar.password) {
          throw new Error('CalDAV calendars require URL, username, and password');
        }
        break;

      default:
        throw new Error(`Unsupported calendar type: ${calendar.type}`);
    }

    return true;
  }
}

module.exports = CalendarSync;
