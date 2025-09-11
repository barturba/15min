class HomeController < ApplicationController
  def index
    # Track custom event for home page visits
    track_custom_event("home_page_visit", {
      timestamp: Time.current,
      page_title: "Home Page"
    })
  end

  private

  def track_custom_event(event_name, properties = {})
    return unless defined?($posthog)

    begin
      $posthog.capture({
        distinct_id: session.id || request.session_options[:id] || "anonymous-#{Time.now.to_i}",
        event: event_name,
        properties: properties
      })
    rescue => e
      Rails.logger.error("PostHog custom event error: #{e.message}")
    end
  end

  # Example method to demonstrate disabling person profile processing
  def track_anonymous_event(event_name, properties = {})
    return unless defined?($posthog)

    begin
      $posthog.capture({
        distinct_id: "anonymous-#{Time.now.to_i}",
        event: event_name,
        properties: properties.merge("$process_person_profile" => false)
      })
    rescue => e
      Rails.logger.error("PostHog anonymous event error: #{e.message}")
    end
  end
end
