const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs').promises;
const CalendarSync = require('./calendar-sync');
const config = require('./config');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// Initialize calendar sync
const calendarSync = new CalendarSync();

// Store calendar configurations
let calendars = [];
let cachedEvents = [];

// Load saved configuration on startup
async function loadConfig() {
  try {
    const configData = await config.load();
    calendars = configData.calendars || [];
    console.log(`Loaded ${calendars.length} calendar(s) from configuration`);

    // Initial sync
    if (calendars.length > 0) {
      await syncCalendars();
    }
  } catch (error) {
    console.log('No existing configuration found, starting fresh');
  }
}

// Sync all calendars
async function syncCalendars() {
  try {
    console.log('Syncing calendars...');
    const allEvents = [];

    for (const calendar of calendars) {
      try {
        const events = await calendarSync.fetchEvents(calendar);
        allEvents.push(...events.map(event => ({
          ...event,
          calendarId: calendar.id,
          calendarName: calendar.name,
          calendarColor: calendar.color
        })));
      } catch (error) {
        console.error(`Error syncing calendar ${calendar.name}:`, error.message);
      }
    }

    // Sort events by start time
    cachedEvents = allEvents.sort((a, b) =>
      new Date(a.start) - new Date(b.start)
    );

    console.log(`Synced ${cachedEvents.length} events from ${calendars.length} calendar(s)`);
  } catch (error) {
    console.error('Error syncing calendars:', error);
  }
}

// Auto-sync every 5 minutes
setInterval(syncCalendars, 5 * 60 * 1000);

// API Routes

// Get all events
app.get('/api/events', (req, res) => {
  const { start, end } = req.query;

  let filteredEvents = cachedEvents;

  if (start) {
    filteredEvents = filteredEvents.filter(event =>
      new Date(event.start) >= new Date(start)
    );
  }

  if (end) {
    filteredEvents = filteredEvents.filter(event =>
      new Date(event.start) <= new Date(end)
    );
  }

  res.json({
    success: true,
    events: filteredEvents,
    lastSync: new Date().toISOString()
  });
});

// Get all configured calendars
app.get('/api/calendars', (req, res) => {
  res.json({
    success: true,
    calendars: calendars.map(cal => ({
      id: cal.id,
      name: cal.name,
      type: cal.type,
      color: cal.color
    }))
  });
});

// Add a new calendar
app.post('/api/calendars', async (req, res) => {
  try {
    const { name, type, url, username, password, color } = req.body;

    if (!name || !type) {
      return res.status(400).json({
        success: false,
        error: 'Name and type are required'
      });
    }

    const calendar = {
      id: Date.now().toString(),
      name,
      type, // 'google', 'caldav', 'ical'
      url,
      username,
      password,
      color: color || getRandomColor(),
      createdAt: new Date().toISOString()
    };

    // Test the calendar connection
    try {
      await calendarSync.fetchEvents(calendar);
    } catch (error) {
      return res.status(400).json({
        success: false,
        error: `Cannot connect to calendar: ${error.message}`
      });
    }

    calendars.push(calendar);
    await config.save({ calendars });
    await syncCalendars();

    res.json({
      success: true,
      calendar: {
        id: calendar.id,
        name: calendar.name,
        type: calendar.type,
        color: calendar.color
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Update a calendar
app.put('/api/calendars/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const calendarIndex = calendars.findIndex(cal => cal.id === id);

    if (calendarIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Calendar not found'
      });
    }

    calendars[calendarIndex] = {
      ...calendars[calendarIndex],
      ...updates,
      id, // Prevent ID change
      updatedAt: new Date().toISOString()
    };

    await config.save({ calendars });
    await syncCalendars();

    res.json({
      success: true,
      calendar: calendars[calendarIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Delete a calendar
app.delete('/api/calendars/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const calendarIndex = calendars.findIndex(cal => cal.id === id);

    if (calendarIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Calendar not found'
      });
    }

    const deletedCalendar = calendars.splice(calendarIndex, 1)[0];
    await config.save({ calendars });
    await syncCalendars();

    res.json({
      success: true,
      calendar: deletedCalendar
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Force sync
app.post('/api/sync', async (req, res) => {
  try {
    await syncCalendars();
    res.json({
      success: true,
      eventCount: cachedEvents.length,
      lastSync: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Check WiFi status (for first-time setup)
app.get('/api/wifi/status', async (req, res) => {
  try {
    // This would check actual WiFi status on Raspberry Pi
    // For now, we'll simulate it
    res.json({
      success: true,
      connected: true,
      ssid: 'HomeNetwork',
      strength: 85
    });
  } catch (error) {
    res.json({
      success: false,
      connected: false
    });
  }
});

// Get available WiFi networks (for first-time setup)
app.get('/api/wifi/scan', async (req, res) => {
  try {
    // This would scan for actual WiFi networks on Raspberry Pi
    // For now, return mock data for development
    res.json({
      success: true,
      networks: [
        { ssid: 'HomeNetwork', strength: 85, secured: true },
        { ssid: 'GuestNetwork', strength: 60, secured: false },
        { ssid: 'NeighborWiFi', strength: 45, secured: true }
      ]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Connect to WiFi network (for first-time setup)
app.post('/api/wifi/connect', async (req, res) => {
  try {
    const { ssid, password } = req.body;

    if (!ssid) {
      return res.status(400).json({
        success: false,
        error: 'SSID is required'
      });
    }

    // This would actually connect to WiFi on Raspberry Pi
    // For now, simulate success
    console.log(`Connecting to WiFi: ${ssid}`);

    res.json({
      success: true,
      message: `Connected to ${ssid}`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'running',
    calendars: calendars.length,
    events: cachedEvents.length,
    uptime: process.uptime()
  });
});

// Serve frontend pages
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.get('/setup', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/setup.html'));
});

// Helper function to generate random colors
function getRandomColor() {
  const colors = [
    '#3788d8', // Blue
    '#e74c3c', // Red
    '#2ecc71', // Green
    '#f39c12', // Orange
    '#9b59b6', // Purple
    '#1abc9c', // Teal
    '#e91e63', // Pink
    '#ff5722', // Deep Orange
  ];
  return colors[Math.floor(Math.random() * colors.length)];
}

// Start server
app.listen(PORT, async () => {
  console.log(`\n╔════════════════════════════════════════════════╗`);
  console.log(`║   Home Calendar Server                         ║`);
  console.log(`╠════════════════════════════════════════════════╣`);
  console.log(`║   Server: http://localhost:${PORT}                ║`);
  console.log(`║   Setup:  http://localhost:${PORT}/setup          ║`);
  console.log(`╚════════════════════════════════════════════════╝\n`);

  await loadConfig();
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully...');
  process.exit(0);
});
