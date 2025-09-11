require "posthog"

# Only initialize PostHog if API key is available
if ENV["POSTHOG_API_KEY"].present?
  PostHog.configuration = PostHog::Configuration.new(
    api_key: ENV["POSTHOG_API_KEY"],
    host: ENV.fetch("POSTHOG_HOST", "https://us.i.posthog.com"),
    on_error: Proc.new { |status, msg| Rails.logger.error("PostHog error: #{status} - #{msg}") }
  )

  # Initialize the client
  $posthog = PostHog::Client.new(PostHog.configuration)
else
  Rails.logger.warn("PostHog API key not found. Set POSTHOG_API_KEY environment variable.")
  $posthog = nil
end
