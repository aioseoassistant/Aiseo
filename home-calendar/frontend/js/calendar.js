// Calendar Display Application
const API_BASE = window.location.origin;

// State
let currentDate = new Date();
let events = [];
let calendars = [];
let settings = {
    refreshInterval: 5,
    timeFormat: '12h',
    firstDayOfWeek: 'sunday',
    showLocation: true,
    showDescription: false
};
let selectedCalendarType = '';
let selectedColor = '#3788d8';
let refreshTimer = null;
let longPressTimer = null;

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    await loadInitialData();
    setupEventListeners();
    renderCalendar();
    startAutoRefresh();
});

// Load initial data
async function loadInitialData() {
    try {
        showLoading(true);

        // Load calendars
        const calendarsResponse = await fetch(`${API_BASE}/api/calendars`);
        const calendarsData = await calendarsResponse.json();
        calendars = calendarsData.calendars || [];

        // Show setup if no calendars
        if (calendars.length === 0) {
            document.getElementById('noCalendarsMessage').classList.remove('hidden');
            showLoading(false);
            return;
        } else {
            document.getElementById('noCalendarsMessage').classList.add('hidden');
        }

        // Load events
        await loadEvents();

        showLoading(false);
    } catch (error) {
        console.error('Error loading initial data:', error);
        showLoading(false);
    }
}

// Load events
async function loadEvents() {
    try {
        const startDate = getWeekStart(currentDate);
        const endDate = new Date(startDate);
        endDate.setDate(endDate.getDate() + 7);

        const response = await fetch(
            `${API_BASE}/api/events?start=${startDate.toISOString()}&end=${endDate.toISOString()}`
        );

        const data = await response.json();
        events = data.events || [];

        updateSyncStatus(data.lastSync);
    } catch (error) {
        console.error('Error loading events:', error);
        updateSyncStatus(null, true);
    }
}

// Render calendar
function renderCalendar() {
    const weekView = document.getElementById('weekView');
    weekView.innerHTML = '';

    // Update month/year display
    document.getElementById('monthYear').textContent =
        currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

    // Get week dates
    const weekStart = getWeekStart(currentDate);
    const weekDates = [];
    for (let i = 0; i < 7; i++) {
        const date = new Date(weekStart);
        date.setDate(date.getDate() + i);
        weekDates.push(date);
    }

    // Render each day
    weekDates.forEach(date => {
        const dayColumn = createDayColumn(date);
        weekView.appendChild(dayColumn);
    });
}

// Create day column
function createDayColumn(date) {
    const dayColumn = document.createElement('div');
    dayColumn.className = 'day-column';

    // Check if today
    const today = new Date();
    if (isSameDay(date, today)) {
        dayColumn.classList.add('today');
    }

    // Day header
    const dayHeader = document.createElement('div');
    dayHeader.className = 'day-header';

    const dayName = document.createElement('div');
    dayName.className = 'day-name';
    dayName.textContent = date.toLocaleDateString('en-US', { weekday: 'short' });

    const dayNumber = document.createElement('div');
    dayNumber.className = 'day-number';
    dayNumber.textContent = date.getDate();

    dayHeader.appendChild(dayName);
    dayHeader.appendChild(dayNumber);

    // Events container
    const eventsContainer = document.createElement('div');
    eventsContainer.className = 'events-container';

    // Get events for this day
    const dayEvents = events.filter(event =>
        isSameDay(new Date(event.start), date)
    );

    // Sort events by start time
    dayEvents.sort((a, b) => new Date(a.start) - new Date(b.start));

    if (dayEvents.length === 0) {
        const noEvents = document.createElement('div');
        noEvents.className = 'no-events';
        noEvents.textContent = 'No events';
        eventsContainer.appendChild(noEvents);
    } else {
        dayEvents.forEach(event => {
            const eventEl = createEventElement(event);
            eventsContainer.appendChild(eventEl);
        });
    }

    dayColumn.appendChild(dayHeader);
    dayColumn.appendChild(eventsContainer);

    return dayColumn;
}

// Create event element
function createEventElement(event) {
    const eventEl = document.createElement('div');
    eventEl.className = 'event';

    // Set calendar color
    eventEl.style.background = event.calendarColor || '#3788d8';

    // Add all-day class if applicable
    if (event.allDay) {
        eventEl.classList.add('all-day');
    }

    // Event time
    if (!event.allDay) {
        const eventTime = document.createElement('div');
        eventTime.className = 'event-time';
        eventTime.textContent = formatEventTime(new Date(event.start), new Date(event.end));
        eventEl.appendChild(eventTime);
    }

    // Event title
    const eventTitle = document.createElement('div');
    eventTitle.className = 'event-title';
    eventTitle.textContent = event.title;
    eventEl.appendChild(eventTitle);

    // Event location (if enabled)
    if (settings.showLocation && event.location) {
        const eventLocation = document.createElement('div');
        eventLocation.className = 'event-location';
        eventLocation.textContent = `📍 ${event.location}`;
        eventEl.appendChild(eventLocation);
    }

    return eventEl;
}

// Format event time
function formatEventTime(start, end) {
    const format = settings.timeFormat === '12h' ? 'short12' : 'short24';

    if (format === 'short12') {
        const startTime = start.toLocaleTimeString('en-US', {
            hour: 'numeric',
            minute: '2-digit'
        });
        return startTime;
    } else {
        const startTime = start.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
        return startTime;
    }
}

// Get week start date
function getWeekStart(date) {
    const d = new Date(date);
    const day = d.getDay();
    const diff = settings.firstDayOfWeek === 'monday'
        ? (day === 0 ? -6 : 1 - day)
        : -day;

    d.setDate(d.getDate() + diff);
    d.setHours(0, 0, 0, 0);
    return d;
}

// Check if same day
function isSameDay(date1, date2) {
    return date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate();
}

// Navigation
function goToPreviousWeek() {
    currentDate.setDate(currentDate.getDate() - 7);
    renderCalendar();
}

function goToNextWeek() {
    currentDate.setDate(currentDate.getDate() + 7);
    renderCalendar();
}

function goToToday() {
    currentDate = new Date();
    renderCalendar();
}

// Refresh
async function refresh() {
    updateSyncStatus(null, false, true);
    await loadEvents();
    renderCalendar();
}

function startAutoRefresh() {
    if (refreshTimer) {
        clearInterval(refreshTimer);
    }

    const intervalMs = settings.refreshInterval * 60 * 1000;
    refreshTimer = setInterval(refresh, intervalMs);
}

function updateSyncStatus(lastSync, error = false, syncing = false) {
    const syncStatus = document.getElementById('syncStatus');
    const syncText = syncStatus.querySelector('.sync-text');

    if (syncing) {
        syncStatus.classList.add('syncing');
        syncText.textContent = 'Syncing...';
    } else if (error) {
        syncStatus.classList.remove('syncing');
        syncText.textContent = 'Sync error';
        syncText.style.color = '#e74c3c';
    } else {
        syncStatus.classList.remove('syncing');
        syncText.textContent = 'Synced';
        syncText.style.color = '#2ecc71';

        // Reset color after 3 seconds
        setTimeout(() => {
            syncText.style.color = '#666';
        }, 3000);
    }
}

// Event Listeners
function setupEventListeners() {
    // Navigation
    document.getElementById('prevWeek').addEventListener('click', goToPreviousWeek);
    document.getElementById('nextWeek').addEventListener('click', goToNextWeek);
    document.getElementById('todayBtn').addEventListener('click', goToToday);

    // Settings button
    document.getElementById('settingsBtn').addEventListener('click', openSettings);

    // Long press for menu
    document.body.addEventListener('touchstart', handleTouchStart);
    document.body.addEventListener('touchend', handleTouchEnd);
    document.body.addEventListener('mousedown', handleTouchStart);
    document.body.addEventListener('mouseup', handleTouchEnd);

    // Touch menu
    document.getElementById('menuAddCalendar').addEventListener('click', () => {
        closeTouchMenu();
        openAddCalendar();
    });
    document.getElementById('menuManageCalendars').addEventListener('click', () => {
        closeTouchMenu();
        openManageCalendars();
    });
    document.getElementById('menuSettings').addEventListener('click', () => {
        closeTouchMenu();
        openSettings();
    });
    document.getElementById('menuRefresh').addEventListener('click', () => {
        closeTouchMenu();
        refresh();
    });
    document.getElementById('menuClose').addEventListener('click', closeTouchMenu);

    // Settings modal
    document.getElementById('closeSettings').addEventListener('click', closeSettings);
    document.getElementById('saveSettings').addEventListener('click', saveSettings);

    // Manage calendars modal
    document.getElementById('closeCalendars').addEventListener('click', closeManageCalendars);
    document.getElementById('addCalendarBtn').addEventListener('click', openAddCalendar);

    // Add calendar modal
    document.getElementById('closeAddCalendar').addEventListener('click', closeAddCalendar);
    document.getElementById('cancelAddCalendar').addEventListener('click', closeAddCalendar);
    document.getElementById('submitCalendar').addEventListener('click', submitCalendar);

    // Calendar type buttons
    document.querySelectorAll('.type-btn').forEach(btn => {
        btn.addEventListener('click', () => selectCalendarType(btn.dataset.type));
    });

    // Color picker
    document.querySelectorAll('.color-option').forEach(option => {
        option.addEventListener('click', () => selectColor(option.dataset.color));
    });

    // Setup calendars button (no calendars message)
    document.getElementById('setupCalendarsBtn').addEventListener('click', openAddCalendar);

    // Swipe gestures
    let touchStartX = 0;
    let touchEndX = 0;

    document.body.addEventListener('touchstart', (e) => {
        touchStartX = e.changedTouches[0].screenX;
    });

    document.body.addEventListener('touchend', (e) => {
        touchEndX = e.changedTouches[0].screenX;
        handleSwipe();
    });

    function handleSwipe() {
        const swipeThreshold = 100;
        const diff = touchStartX - touchEndX;

        if (Math.abs(diff) > swipeThreshold) {
            if (diff > 0) {
                // Swipe left - next week
                goToNextWeek();
            } else {
                // Swipe right - previous week
                goToPreviousWeek();
            }
        }
    }
}

// Long press handlers
function handleTouchStart(e) {
    if (e.target.closest('.modal') || e.target.closest('button')) {
        return;
    }

    longPressTimer = setTimeout(() => {
        openTouchMenu();
    }, 1000); // 1 second
}

function handleTouchEnd(e) {
    if (longPressTimer) {
        clearTimeout(longPressTimer);
    }
}

// Modals
function openTouchMenu() {
    document.getElementById('touchMenu').classList.remove('hidden');
}

function closeTouchMenu() {
    document.getElementById('touchMenu').classList.add('hidden');
}

function openSettings() {
    // Load current settings
    document.getElementById('timeFormat').value = settings.timeFormat;
    document.getElementById('firstDayOfWeek').value = settings.firstDayOfWeek;
    document.getElementById('refreshInterval').value = settings.refreshInterval;
    document.getElementById('showLocation').checked = settings.showLocation;
    document.getElementById('showDescription').checked = settings.showDescription;

    document.getElementById('settingsModal').classList.remove('hidden');
}

function closeSettings() {
    document.getElementById('settingsModal').classList.add('hidden');
}

async function saveSettings() {
    settings.timeFormat = document.getElementById('timeFormat').value;
    settings.firstDayOfWeek = document.getElementById('firstDayOfWeek').value;
    settings.refreshInterval = parseInt(document.getElementById('refreshInterval').value);
    settings.showLocation = document.getElementById('showLocation').checked;
    settings.showDescription = document.getElementById('showDescription').checked;

    // Restart auto-refresh with new interval
    startAutoRefresh();

    // Re-render calendar
    renderCalendar();

    closeSettings();
}

function openManageCalendars() {
    renderCalendarsList();
    document.getElementById('calendarsModal').classList.remove('hidden');
}

function closeManageCalendars() {
    document.getElementById('calendarsModal').classList.add('hidden');
}

function renderCalendarsList() {
    const list = document.getElementById('calendarsList');
    list.innerHTML = '';

    if (calendars.length === 0) {
        list.innerHTML = '<p>No calendars added yet.</p>';
        return;
    }

    calendars.forEach(calendar => {
        const item = document.createElement('div');
        item.className = 'calendar-item';

        item.innerHTML = `
            <div class="calendar-info">
                <div class="calendar-color-dot" style="background: ${calendar.color}"></div>
                <div class="calendar-details">
                    <h3>${calendar.name}</h3>
                    <p>${calendar.type}</p>
                </div>
            </div>
            <div class="calendar-actions">
                <button class="delete-btn" onclick="deleteCalendar('${calendar.id}')">Delete</button>
            </div>
        `;

        list.appendChild(item);
    });
}

function openAddCalendar() {
    document.getElementById('addCalendarModal').classList.remove('hidden');
    document.getElementById('calendarForm').classList.add('hidden');
    selectedCalendarType = '';
    selectedColor = '#3788d8';

    // Reset form
    document.getElementById('calendarName').value = '';
    document.getElementById('calendarUrl').value = '';
    document.getElementById('caldavUsername').value = '';
    document.getElementById('caldavPassword').value = '';

    // Reset color selection
    document.querySelectorAll('.color-option').forEach(opt => {
        opt.classList.remove('selected');
    });
    document.querySelector(`.color-option[data-color="${selectedColor}"]`).classList.add('selected');
}

function closeAddCalendar() {
    document.getElementById('addCalendarModal').classList.add('hidden');
    document.getElementById('addCalendarError').classList.add('hidden');
}

function selectCalendarType(type) {
    selectedCalendarType = type;

    // Update UI
    document.querySelectorAll('.type-btn').forEach(btn => {
        btn.classList.remove('selected');
    });
    event.target.classList.add('selected');

    // Show form
    document.getElementById('calendarForm').classList.remove('hidden');

    // Show/hide fields based on type
    const caldavGroup = document.getElementById('caldavGroup');
    const urlGroup = document.getElementById('urlGroup');

    if (type === 'caldav') {
        caldavGroup.classList.remove('hidden');
        urlGroup.querySelector('label').textContent = 'CalDAV Server URL:';
        urlGroup.querySelector('small').textContent = 'e.g., https://caldav.example.com/calendar';
    } else {
        caldavGroup.classList.add('hidden');
        if (type === 'google') {
            urlGroup.querySelector('label').textContent = 'Google Calendar iCal URL:';
            urlGroup.querySelector('small').textContent = 'Get from Calendar Settings → Integrate calendar → Secret address in iCal format';
        } else if (type === 'icloud') {
            urlGroup.querySelector('label').textContent = 'iCloud Calendar URL:';
            urlGroup.querySelector('small').textContent = 'Get from iCloud Calendar → Share Calendar → Public Calendar URL';
        } else {
            urlGroup.querySelector('label').textContent = 'iCal URL:';
            urlGroup.querySelector('small').textContent = 'Paste your calendar\'s iCal/ICS URL here';
        }
    }
}

function selectColor(color) {
    selectedColor = color;

    document.querySelectorAll('.color-option').forEach(opt => {
        opt.classList.remove('selected');
    });
    event.target.classList.add('selected');
}

async function submitCalendar() {
    const errorEl = document.getElementById('addCalendarError');
    errorEl.classList.add('hidden');

    const name = document.getElementById('calendarName').value.trim();
    const url = document.getElementById('calendarUrl').value.trim();
    const username = document.getElementById('caldavUsername').value.trim();
    const password = document.getElementById('caldavPassword').value.trim();

    // Validation
    if (!name) {
        errorEl.textContent = 'Please enter a calendar name';
        errorEl.classList.remove('hidden');
        return;
    }

    if (!url) {
        errorEl.textContent = 'Please enter a calendar URL';
        errorEl.classList.remove('hidden');
        return;
    }

    if (selectedCalendarType === 'caldav' && (!username || !password)) {
        errorEl.textContent = 'CalDAV calendars require username and password';
        errorEl.classList.remove('hidden');
        return;
    }

    try {
        showLoading(true);

        const response = await fetch(`${API_BASE}/api/calendars`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name,
                type: selectedCalendarType,
                url,
                username,
                password,
                color: selectedColor
            })
        });

        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error);
        }

        // Reload calendars and events
        await loadInitialData();
        renderCalendar();

        closeAddCalendar();
        showLoading(false);

    } catch (error) {
        errorEl.textContent = error.message;
        errorEl.classList.remove('hidden');
        showLoading(false);
    }
}

async function deleteCalendar(id) {
    if (!confirm('Are you sure you want to delete this calendar?')) {
        return;
    }

    try {
        showLoading(true);

        const response = await fetch(`${API_BASE}/api/calendars/${id}`, {
            method: 'DELETE'
        });

        const data = await response.json();

        if (!data.success) {
            throw new Error(data.error);
        }

        // Reload calendars and events
        await loadInitialData();
        renderCalendar();
        renderCalendarsList();

        showLoading(false);

    } catch (error) {
        alert('Error deleting calendar: ' + error.message);
        showLoading(false);
    }
}

// Utility
function showLoading(show) {
    const overlay = document.getElementById('loadingOverlay');
    if (show) {
        overlay.classList.remove('hidden');
    } else {
        overlay.classList.add('hidden');
    }
}
