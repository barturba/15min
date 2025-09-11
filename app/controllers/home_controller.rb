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
      # Build base properties for consistency
      base_properties = {
        # Screen/Screen Name
        screen_name: "#{controller_name}##{action_name}",
        screen_category: controller_name,

        # URL Information
        url: request.url,
        path: request.path,
        controller: controller_name,
        action: action_name,

        # Timing
        timestamp: Time.current.to_i,

        # Environment
        environment: Rails.env
      }

      # Merge with custom properties
      merged_properties = base_properties.merge(properties)

      $posthog.capture({
        distinct_id: session.id || request.session_options[:id] || "anonymous-#{Time.now.to_i}",
        event: event_name,
        properties: merged_properties.compact
      })
    rescue => e
      Rails.logger.error("PostHog custom event error: #{e.message}")
    end
  end

  # Example method to demonstrate disabling person profile processing
  def track_anonymous_event(event_name, properties = {})
    return unless defined?($posthog)

    begin
      # Build base properties for consistency
      base_properties = {
        # Screen/Screen Name
        screen_name: "#{controller_name}##{action_name}",
        screen_category: controller_name,

        # URL Information
        url: request.url,
        path: request.path,
        controller: controller_name,
        action: action_name,

        # Timing
        timestamp: Time.current.to_i,

        # Environment
        environment: Rails.env,

        # Disable person profile processing
        "$process_person_profile" => false
      }

      # Merge with custom properties
      merged_properties = base_properties.merge(properties)

      $posthog.capture({
        distinct_id: "anonymous-#{Time.now.to_i}",
        event: event_name,
        properties: merged_properties.compact
      })
    rescue => e
      Rails.logger.error("PostHog anonymous event error: #{e.message}")
    end
  end
end
