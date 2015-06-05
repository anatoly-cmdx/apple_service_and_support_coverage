require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'headless'

module CapybaraWebkitHeadless
  include Capybara::DSL

  def new_session(options = {})
    Headless.new(display: 100, reuse: true, destroy_at_exit: false).start
    at_exit { Headless.new(display: 100, reuse: true).stop }

    Capybara.default_driver = Capybara.javascript_driver = :webkit
    Capybara.run_server = false
    Capybara.app_host = options[:app_host] if options[:app_host]

    if options[:allowed_urls]
      options[:allowed_urls].to_a.each { |url| page.driver.allow_url url }
    end

    Capybara::Session.new(:webkit)
  end
end
