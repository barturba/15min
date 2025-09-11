// Entry point for the build script in your package.json

// Function to format date as MM/DD/YYYY HH:MM:SS
function formatDateTime(date) {
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const year = date.getFullYear();
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');

  return `${month}/${day}/${year} ${hours}:${minutes}:${seconds}`;
}

// Function to copy text to clipboard
async function copyToClipboard(text, fieldType = 'unknown') {
  const startTime = Date.now();

  try {
    await navigator.clipboard.writeText(text);

    // Track successful copy with PostHog
    if (window.posthog) {
      window.posthog.capture('copy_to_clipboard', {
        field_type: fieldType,
        text_length: text.length,
        copy_method: 'clipboard_api',
        success: true,
        duration: Date.now() - startTime
      });
    }

    showStatusMessage();
  } catch (err) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);

    // Track fallback copy with PostHog
    if (window.posthog) {
      window.posthog.capture('copy_to_clipboard', {
        field_type: fieldType,
        text_length: text.length,
        copy_method: 'fallback_execCommand',
        success: true,
        error_type: err.name,
        duration: Date.now() - startTime
      });
    }

    showStatusMessage();
  }
}

// Function to show status message
function showStatusMessage() {
  const message = document.getElementById('statusMessage');
  message.classList.remove('opacity-0');
  message.classList.add('opacity-100');

  setTimeout(() => {
    message.classList.remove('opacity-100');
    message.classList.add('opacity-0');
  }, 2000);
}

// Function to update times
function updateTimes(triggeredBy = 'auto_update') {
  const now = new Date();
  const workEndTime = document.getElementById('workEndTime');
  const workStartInput = document.getElementById('workStartTime');
  const select = document.getElementById('workStartSelect');

  const previousEndTime = workEndTime.value;
  const previousStartTime = workStartInput.value;

  workEndTime.value = formatDateTime(now);

  const minutesAgo = parseInt(select.value);
  const workStartTime = new Date(now.getTime() - (minutesAgo * 60 * 1000));
  workStartInput.value = formatDateTime(workStartTime);

  // Track time updates with PostHog
  if (window.posthog && triggeredBy !== 'auto_update') {
    window.posthog.capture('time_selection_changed', {
      trigger_type: triggeredBy,
      minutes_ago: minutesAgo,
      work_duration_minutes: minutesAgo,
      previous_start_time: previousStartTime,
      new_start_time: workStartInput.value,
      end_time: workEndTime.value,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    });
  }
}

// Track page view with PostHog
function trackPageView() {
  if (window.posthog) {
    window.posthog.capture('$pageview', {
      page_title: document.title,
      page_url: window.location.href,
      page_path: window.location.pathname,
      user_agent: navigator.userAgent,
      screen_resolution: `${window.screen.width}x${window.screen.height}`,
      viewport_size: `${window.innerWidth}x${window.innerHeight}`,
      referrer: document.referrer,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      language: navigator.language
    });
  }
}

// Track user engagement
function trackEngagement(eventType, details = {}) {
  if (window.posthog) {
    window.posthog.capture('user_engagement', {
      engagement_type: eventType,
      ...details,
      timestamp: Date.now(),
      session_duration: Date.now() - (window.sessionStartTime || Date.now())
    });
  }
}

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
  // Track session start
  window.sessionStartTime = Date.now();

  // Track initial page view
  trackPageView();

  // Track app initialization
  trackEngagement('app_initialized', {
    user_agent: navigator.userAgent,
    screen_size: `${window.screen.width}x${window.screen.height}`,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
  });

  // Update times immediately
  updateTimes();

  // Update both work start and work end times every second
  setInterval(() => updateTimes('auto_update'), 1000);

  // Handle work start dropdown change
  const select = document.getElementById('workStartSelect');
  select.addEventListener('change', function() {
    updateTimes('dropdown_change');
  });

  // Track dropdown interactions
  select.addEventListener('focus', function() {
    trackEngagement('dropdown_focused', {
      current_value: select.value,
      available_options: Array.from(select.options).map(opt => opt.value)
    });
  });

  // Track input field interactions
  const workStartInput = document.getElementById('workStartTime');
  const workEndInput = document.getElementById('workEndTime');

  [workStartInput, workEndInput].forEach((input, index) => {
    const fieldType = index === 0 ? 'work_start' : 'work_end';

    input.addEventListener('click', function() {
      trackEngagement('input_clicked', {
        field_type: fieldType,
        field_value: input.value,
        click_time: Date.now()
      });
    });

    input.addEventListener('focus', function() {
      trackEngagement('input_focused', {
        field_type: fieldType,
        field_value: input.value
      });
    });
  });

  // Track copy actions with field types
  window.copyToClipboard = function(text) {
    // Determine field type based on context or last clicked element
    let fieldType = 'unknown';
    if (document.activeElement === workStartInput) {
      fieldType = 'work_start_time';
    } else if (document.activeElement === workEndInput) {
      fieldType = 'work_end_time';
    }

    copyToClipboard(text, fieldType);
  };

  // Track page visibility changes
  document.addEventListener('visibilitychange', function() {
    trackEngagement('visibility_change', {
      hidden: document.hidden,
      visibility_state: document.visibilityState,
      time_spent: Date.now() - window.sessionStartTime
    });
  });

  // Track before unload
  window.addEventListener('beforeunload', function() {
    trackEngagement('session_end', {
      session_duration: Date.now() - window.sessionStartTime,
      page_views: 1 // Could be incremented for multi-page apps
    });
  });
});
