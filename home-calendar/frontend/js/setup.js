// Setup Wizard
const API_BASE = window.location.origin;

// State
let currentStep = 1;
let selectedSsid = '';
let selectedCalendarType = '';
let selectedColor = '#3788d8';
let addedCalendars = [];

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    loadWifiNetworks();
});

// Event Listeners
function setupEventListeners() {
    // WiFi
    document.getElementById('scanWifi').addEventListener('click', loadWifiNetworks);
    document.getElementById('skipWifi').addEventListener('click', () => goToStep(2));
    document.getElementById('connectWifi').addEventListener('click', connectToWifi);
    document.getElementById('cancelWifi').addEventListener('click', closeWifiModal);
    document.getElementById('showPassword').addEventListener('change', togglePasswordVisibility);

    // Calendar type selection
    document.querySelectorAll('.type-card').forEach(btn => {
        btn.addEventListener('click', () => selectCalendarType(btn.dataset.type));
    });

    // Color picker
    document.querySelectorAll('#setupColorPicker .color-option').forEach(option => {
        option.addEventListener('click', () => selectColor(option.dataset.color));
    });

    // Calendar form
    document.getElementById('addCalendarSubmit').addEventListener('click', addCalendar);
    document.getElementById('cancelAddCalendar').addEventListener('click', cancelAddCalendar);

    // Navigation
    document.getElementById('backToWifi').addEventListener('click', () => goToStep(1));
    document.getElementById('finishSetup').addEventListener('click', finishSetup);
    document.getElementById('goToCalendar').addEventListener('click', () => {
        window.location.href = '/';
    });
}

// WiFi Functions
async function loadWifiNetworks() {
    try {
        showLoading(true, 'Scanning for WiFi networks...');

        const response = await fetch(`${API_BASE}/api/wifi/scan`);
        const data = await response.json();

        if (data.success) {
            renderWifiList(data.networks);
        }

        showLoading(false);
    } catch (error) {
        console.error('Error scanning WiFi:', error);
        showLoading(false);
    }
}

function renderWifiList(networks) {
    const wifiList = document.getElementById('wifiList');
    wifiList.innerHTML = '';

    if (networks.length === 0) {
        wifiList.innerHTML = '<p class="empty-state">No WiFi networks found</p>';
        return;
    }

    networks.forEach(network => {
        const item = document.createElement('div');
        item.className = 'wifi-item';

        // Determine strength class
        let strengthClass = 'weak';
        if (network.strength > 70) strengthClass = 'strong';
        else if (network.strength > 40) strengthClass = 'medium';

        item.classList.add(strengthClass);

        item.innerHTML = `
            <div class="wifi-info">
                <div class="wifi-icon">${network.secured ? '🔒' : '📶'}</div>
                <div class="wifi-details">
                    <h3>${network.ssid}</h3>
                    <p>${network.secured ? 'Secured' : 'Open'}</p>
                </div>
            </div>
            <div class="wifi-strength">
                <div class="strength-bars">
                    <div class="strength-bar"></div>
                    <div class="strength-bar"></div>
                    <div class="strength-bar"></div>
                    <div class="strength-bar"></div>
                </div>
            </div>
        `;

        item.addEventListener('click', () => selectWifiNetwork(network));
        wifiList.appendChild(item);
    });
}

function selectWifiNetwork(network) {
    selectedSsid = network.ssid;

    if (network.secured) {
        // Show password modal
        document.getElementById('selectedSsid').textContent = network.ssid;
        document.getElementById('wifiPassword').value = '';
        document.getElementById('wifiError').classList.add('hidden');
        document.getElementById('wifiPasswordModal').classList.remove('hidden');
    } else {
        // Connect without password
        connectToWifi();
    }
}

async function connectToWifi() {
    const password = document.getElementById('wifiPassword').value;
    const errorEl = document.getElementById('wifiError');

    try {
        showLoading(true, 'Connecting to WiFi...');

        const response = await fetch(`${API_BASE}/api/wifi/connect`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                ssid: selectedSsid,
                password
            })
        });

        const data = await response.json();

        if (data.success) {
            closeWifiModal();
            goToStep(2);
        } else {
            errorEl.textContent = data.error || 'Failed to connect';
            errorEl.classList.remove('hidden');
        }

        showLoading(false);
    } catch (error) {
        errorEl.textContent = 'Connection error: ' + error.message;
        errorEl.classList.remove('hidden');
        showLoading(false);
    }
}

function closeWifiModal() {
    document.getElementById('wifiPasswordModal').classList.add('hidden');
}

function togglePasswordVisibility() {
    const passwordInput = document.getElementById('wifiPassword');
    const checkbox = document.getElementById('showPassword');

    passwordInput.type = checkbox.checked ? 'text' : 'password';
}

// Calendar Functions
function selectCalendarType(type) {
    selectedCalendarType = type;

    // Update UI
    document.querySelectorAll('.type-card').forEach(btn => {
        btn.classList.remove('selected');
    });
    event.target.closest('.type-card').classList.add('selected');

    // Show form
    document.getElementById('calendarFormContainer').classList.remove('hidden');

    // Configure form based on type
    const caldavGroup = document.getElementById('setupCaldavGroup');
    const urlGroup = document.getElementById('setupUrlGroup');
    const urlHelp = document.getElementById('setupUrlHelp');

    if (type === 'caldav') {
        caldavGroup.classList.remove('hidden');
        urlHelp.textContent = 'e.g., https://caldav.example.com/calendar';
    } else {
        caldavGroup.classList.add('hidden');

        if (type === 'google') {
            urlHelp.textContent = 'Get from Google Calendar Settings → Integrate calendar → Secret address in iCal format';
        } else if (type === 'icloud') {
            urlHelp.textContent = 'Get from iCloud Calendar → Share Calendar → Public Calendar URL';
        } else {
            urlHelp.textContent = 'Paste your calendar\'s iCal/ICS URL here';
        }
    }

    // Clear form
    document.getElementById('setupCalendarName').value = '';
    document.getElementById('setupCalendarUrl').value = '';
    document.getElementById('setupCaldavUsername').value = '';
    document.getElementById('setupCaldavPassword').value = '';
}

function selectColor(color) {
    selectedColor = color;

    document.querySelectorAll('#setupColorPicker .color-option').forEach(opt => {
        opt.classList.remove('selected');
    });
    event.target.classList.add('selected');
}

async function addCalendar() {
    const errorEl = document.getElementById('setupCalendarError');
    errorEl.classList.add('hidden');

    const name = document.getElementById('setupCalendarName').value.trim();
    const url = document.getElementById('setupCalendarUrl').value.trim();
    const username = document.getElementById('setupCaldavUsername').value.trim();
    const password = document.getElementById('setupCaldavPassword').value.trim();

    // Validation
    if (!selectedCalendarType) {
        errorEl.textContent = 'Please select a calendar type';
        errorEl.classList.remove('hidden');
        return;
    }

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
        showLoading(true, 'Adding calendar...');

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

        // Add to local list
        addedCalendars.push({
            id: data.calendar.id,
            name: data.calendar.name,
            type: data.calendar.type,
            color: data.calendar.color
        });

        // Update UI
        renderAddedCalendars();
        cancelAddCalendar();

        showLoading(false);

    } catch (error) {
        errorEl.textContent = error.message;
        errorEl.classList.remove('hidden');
        showLoading(false);
    }
}

function renderAddedCalendars() {
    const list = document.getElementById('addedCalendarsList');

    if (addedCalendars.length === 0) {
        list.innerHTML = '<p class="empty-state">No calendars added yet</p>';
        return;
    }

    list.innerHTML = '';

    addedCalendars.forEach(calendar => {
        const item = document.createElement('div');
        item.className = 'added-calendar-item';

        item.innerHTML = `
            <div class="calendar-color-dot" style="background: ${calendar.color}"></div>
            <span class="calendar-name">${calendar.name}</span>
            <span class="calendar-type">${calendar.type}</span>
        `;

        list.appendChild(item);
    });
}

function cancelAddCalendar() {
    document.getElementById('calendarFormContainer').classList.add('hidden');
    document.getElementById('setupCalendarError').classList.add('hidden');

    // Reset form
    document.querySelectorAll('.type-card').forEach(btn => {
        btn.classList.remove('selected');
    });

    selectedCalendarType = '';
}

function finishSetup() {
    if (addedCalendars.length === 0) {
        if (!confirm('You haven\'t added any calendars yet. Continue anyway?')) {
            return;
        }
    }

    // Update completion screen
    document.getElementById('completionCalendars').textContent = addedCalendars.length;

    goToStep(3);
}

// Navigation
function goToStep(step) {
    currentStep = step;

    // Update step indicators
    document.querySelectorAll('.step').forEach((stepEl, index) => {
        stepEl.classList.remove('active', 'completed');

        if (index + 1 < currentStep) {
            stepEl.classList.add('completed');
        } else if (index + 1 === currentStep) {
            stepEl.classList.add('active');
        }
    });

    // Update step content
    document.querySelectorAll('.setup-step').forEach((stepContent, index) => {
        stepContent.classList.remove('active');

        if (index + 1 === currentStep) {
            stepContent.classList.add('active');
        }
    });
}

// Utility
function showLoading(show, text = 'Loading...') {
    const overlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');

    if (show) {
        loadingText.textContent = text;
        overlay.classList.remove('hidden');
    } else {
        overlay.classList.add('hidden');
    }
}
