# 15min - Work Timer App

A minimal, modern single-page Rails application for tracking work start and end times.

[![CI](https://github.com/barturba/15min/actions/workflows/ci.yml/badge.svg)](https://github.com/barturba/15min/actions/workflows/ci.yml)

[🚀 **Live Demo**](https://15min.bartasurba.com)

## Features

- **Work Start Time**: Configurable dropdown with options (15 min ago, 30 min ago, 1 hour ago, 2 hours ago)
- **Work End Time**: Automatically shows current time and updates every second
- **Time Format**: MM/DD/YYYY HH:MM:SS
- **Clipboard Copy**: Single click on any time field copies it to clipboard
- **Modern UI**: Ultra minimal design with Tailwind CSS and hacker green theme
- **Real-time Updates**: Times update automatically
- **PWA Ready**: Installable as a progressive web app with custom icons

## Tech Stack

- **Rails 8** - Latest Rails framework
- **Tailwind CSS** - Utility-first CSS framework
- **JavaScript/ESBuild** - Modern JavaScript bundling
- **Kamal 2** - Container-based deployment

## Getting Started

### Prerequisites

- Ruby 3.3.6 (managed by mise)
- Node.js and Bun
- Docker (for deployment)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   bun install
   ```

3. Precompile assets:
   ```bash
   bundle exec rails assets:precompile
   ```

4. Start the development server:
   ```bash
   bundle exec rails server
   ```

5. Visit `http://localhost:3000`

## Deployment with Kamal

1. Configure your server details in `config/deploy.yml`:
   - Update `servers.web` with your server IP
   - Update `registry.username` with your Docker Hub username
   - Update `proxy.host` with your domain

2. Set up secrets in `.kamal/secrets`:
   ```
   KAMAL_REGISTRY_PASSWORD=your-docker-hub-token
   RAILS_MASTER_KEY=your-rails-master-key
   ```

3. Deploy:
   ```bash
   kamal setup
   kamal deploy
   ```

## Usage

1. Select your work start time from the dropdown (15 min ago, 30 min ago, 1 hour ago, 2 hours ago)
2. The work start time will automatically calculate and display
3. The work end time shows the current time and updates every second
4. Click on any time field to copy it to your clipboard
5. A confirmation message appears when copied successfully

## Development

The application uses:
- Hot reloading for assets in development
- ESBuild for JavaScript bundling
- Tailwind CSS for styling
- Minimal Rails setup (no database, jobs, or other services)
# PostHog integration update
