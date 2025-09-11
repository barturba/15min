require 'posthog'

PostHog.configuration = PostHog::Configuration.new(
  api_key: "phc_K9vJZcJ94A7OAWEIVCA0aKiSTQ5ixqzQSfzB6qgnz1h",
  host: "https://us.i.posthog.com",
  on_error: Proc.new { |status, msg| Rails.logger.error("PostHog error: #{status} - #{msg}") }
)

# Initialize the client
$posthog = PostHog::Client.new(PostHog.configuration)
