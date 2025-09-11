require "posthog"

# Only initialize PostHog if API key is available
if ENV["POSTHOG_API_KEY"].present?
  begin
    # Initialize the client with configuration
    $posthog = PostHog::Client.new({
      api_key: ENV["POSTHOG_API_KEY"],
      host: ENV.fetch("POSTHOG_HOST", "https://us.i.posthog.com"),
      on_error: Proc.new { |status, msg| Rails.logger.error("PostHog error: #{status} - #{msg}") }
    })
    Rails.logger.info("PostHog initialized successfully")
  rescue => e
    Rails.logger.error("Failed to initialize PostHog: #{e.message}")
    $posthog = nil
  end
else
  Rails.logger.warn("PostHog API key not found. Set POSTHOG_API_KEY environment variable.")
  $posthog = nil
end
