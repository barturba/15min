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
async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    showStatusMessage();
  } catch (err) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
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
function updateTimes() {
  const now = new Date();
  const workEndTime = document.getElementById('workEndTime');
  workEndTime.value = formatDateTime(now);

  const select = document.getElementById('workStartSelect');
  const minutesAgo = parseInt(select.value);
  const workStartTime = new Date(now.getTime() - (minutesAgo * 60 * 1000));

  const workStartInput = document.getElementById('workStartTime');
  workStartInput.value = formatDateTime(workStartTime);
}

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
  // Update times immediately
  updateTimes();

  // Update both work start and work end times every second
  setInterval(updateTimes, 1000);

  // Handle work start dropdown change
  const select = document.getElementById('workStartSelect');
  select.addEventListener('change', updateTimes);

  // Make copyToClipboard function globally available
  window.copyToClipboard = copyToClipboard;
});
