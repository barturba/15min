class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  after_action :track_page_view

  private

  def track_page_view
    return unless defined?($posthog)

    begin
      $posthog.capture({
        distinct_id: session.id || request.session_options[:id] || "anonymous-#{Time.now.to_i}",
        event: 'page_view',
        properties: {
          url: request.url,
          path: request.path,
          controller: controller_name,
          action: action_name,
          user_agent: request.user_agent,
          ip: request.remote_ip,
          referrer: request.referrer
        }
      })
    rescue => e
      Rails.logger.error("PostHog tracking error: #{e.message}")
    end
  end
end
