# Configure Capybara
require 'capybara/poltergeist' if ENV['DRIVER'] == "phantomjs"

Capybara.default_max_wait_time = (ENV['MAX_WAIT'] || 30).to_i

def configure_poltergeist
  # DEFAULT: headless tests with poltergeist/PhantomJS
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      phantomjs: ENV['PHANTOMJS'],
      phantomjs_options: ['--debug=no', '--load-images=no', '--ignore-ssl-errors=yes'],#, '--ssl-protocol=any'],
      window_size: [1280, 1024],
      timeout: 300,
      debug: false
    )
  end
end

# configure selenium on chrome headless
def configure_selenium
  Capybara.register_driver :selenium do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[ no-sandbox headless disable-gpu window-size=1280,1024]
      }
    )

    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  end
end

case ENV['DRIVER']
# if driver not set, default to poltergeist
when "phantomjs"
  configure_poltergeist
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.current_driver = :poltergeist
  Capybara.default_max_wait_time = (ENV['MAX_WAIT'] || 8).to_i
# run chrome headless when specified
when nil, "chrome"
  configure_selenium
  Capybara.javascript_driver = :selenium
  Capybara.default_driver = :selenium
  Capybara.current_driver = :selenium
end

Before do
  if Capybara.default_driver == :selenium
    Capybara.current_session.driver.browser.manage.window.resize_to(1280, 1024)
  end
end
