require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TournamentNote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.generators do |g|
      g.test_framework  :rspec,
                        view_specs: false,
                        helper_specs: false,
                        routing_specs: false,
                        request_specs: false
      g.factory_bot false
      g.factory_bot dir: "spec/factories"
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml').to_s]
    # config.action_controller.include_all_helpers = false

    config.hosts << 'https://tournamentnote.onrender.com'

  end
end
