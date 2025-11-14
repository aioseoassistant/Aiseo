const fs = require('fs').promises;
const path = require('path');

const CONFIG_DIR = path.join(__dirname, '../config');
const CONFIG_FILE = path.join(CONFIG_DIR, 'calendar-config.json');

/**
 * Configuration management module
 */
class Config {
  /**
   * Load configuration from file
   */
  static async load() {
    try {
      const data = await fs.readFile(CONFIG_FILE, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      if (error.code === 'ENOENT') {
        // File doesn't exist, return default config
        return {
          calendars: [],
          settings: {
            refreshInterval: 5, // minutes
            timeFormat: '12h',
            firstDayOfWeek: 'sunday',
            showPastDays: 1,
            showFutureDays: 14,
            showLocation: true,
            showDescription: false
          }
        };
      }
      throw error;
    }
  }

  /**
   * Save configuration to file
   */
  static async save(config) {
    try {
      // Ensure config directory exists
      await fs.mkdir(CONFIG_DIR, { recursive: true });

      // Write config file
      await fs.writeFile(
        CONFIG_FILE,
        JSON.stringify(config, null, 2),
        'utf8'
      );

      console.log('Configuration saved successfully');
    } catch (error) {
      console.error('Error saving configuration:', error);
      throw error;
    }
  }

  /**
   * Update specific settings
   */
  static async updateSettings(newSettings) {
    const config = await this.load();
    config.settings = {
      ...config.settings,
      ...newSettings
    };
    await this.save(config);
    return config.settings;
  }

  /**
   * Get current settings
   */
  static async getSettings() {
    const config = await this.load();
    return config.settings;
  }

  /**
   * Check if configuration exists
   */
  static async exists() {
    try {
      await fs.access(CONFIG_FILE);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Reset configuration to defaults
   */
  static async reset() {
    const defaultConfig = {
      calendars: [],
      settings: {
        refreshInterval: 5,
        timeFormat: '12h',
        firstDayOfWeek: 'sunday',
        showPastDays: 1,
        showFutureDays: 14,
        showLocation: true,
        showDescription: false
      }
    };

    await this.save(defaultConfig);
    return defaultConfig;
  }
}

module.exports = Config;
