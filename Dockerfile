# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t fifteen_min_app .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name fifteen_min_app fifteen_min_app

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=ruby-3.2.9

FROM docker.io/library/ruby:3.2.9-slim AS base

# Rails app lives here
WORKDIR /rails

# Validate Ruby version matches .ruby-version file
COPY .ruby-version ./
RUN if [ -f .ruby-version ] && [ "$(cat .ruby-version)" != "ruby-3.2.9" ]; then \
      echo "Ruby version mismatch: expected $(cat .ruby-version), got ruby-3.2.9"; \
      exit 1; \
    fi

# Install base packages (cached layer)
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 sqlite3 && \
    rm -rf /var/lib/apt/lists

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules (cached layer)
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev node-gyp pkg-config python-is-python3 unzip && \
    rm -rf /var/lib/apt/lists

# Install Node.js and npm for asset compilation
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs npm

# Copy dependency files first for better caching
COPY Gemfile Gemfile.lock ./

# Install application gems with caching
RUN --mount=type=cache,target=/usr/local/bundle/cache \
    bundle install --without development test && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy package files for Node dependencies
COPY package.json package-lock.json ./

# Install node modules with caching
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy application code (after dependencies are installed)
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production with temporary secret key
RUN SECRET_KEY_BASE=$(openssl rand -base64 32) ./bin/rails assets:precompile

# Clean up build artifacts
RUN rm -rf node_modules


# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Health check for container liveness
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
