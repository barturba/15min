class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  after_action :track_page_view

  private

  def track_page_view
    return unless defined?($posthog)

    begin
      # Build comprehensive URL information
      url_info = {
        full_url: request.url,
        path: request.path,
        query_string: request.query_string.presence,
        host: request.host,
        port: request.port,
        protocol: request.protocol.chomp("://")
      }

      # Build screen/screen_name based on controller and action
      screen_name = "#{controller_name}##{action_name}"
      screen_category = controller_name

      $posthog.capture({
        distinct_id: session.id || request.session_options[:id] || "anonymous-#{Time.now.to_i}",
        event: "page_view",
        properties: {
          # Screen/Screen Name
          screen_name: screen_name,
          screen_category: screen_category,

          # URL Information
          url: request.url,
          path: request.path,
          query_string: request.query_string.presence,
          host: request.host,
          protocol: request.protocol.chomp("://"),

          # Page Information
          page_title: page_title_from_controller,
          controller: controller_name,
          action: action_name,

          # User Context
          user_agent: request.user_agent,
          ip: request.remote_ip,
          referrer: request.referrer,
          accept_language: request.headers["Accept-Language"],
          http_method: request.method,

          # Timing
          timestamp: Time.current.to_i,

          # Environment
          environment: Rails.env,
          rails_version: Rails.version
        }.compact
      })
    rescue => e
      Rails.logger.error("PostHog tracking error: #{e.message}")
    end
  end

  def page_title_from_controller
    # Try to get page title from content_for or default to screen name
    begin
      content_for(:title) || "#{controller_name.humanize} - #{action_name.humanize}"
    rescue
      "#{controller_name.humanize} - #{action_name.humanize}"
    end
  end
end
