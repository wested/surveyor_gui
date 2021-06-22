Capybara.asset_host = 'http://localhost:3000'

DOWNLOAD_DIRECTORY = Rails.root.join('tmp', 'downloads')


RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :webkit, using: :chrome, screen_size: [1400, 1400]
  end

  config.before(:each, type: :system, js: true, headless_selenium: true) do
    ## https://www.zagaja.com/2019/02/rspec-headless-chrome-capybara/
    require 'selenium/webdriver'

    Capybara.register_driver :selenium_chrome_headless do |app|

      browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
        opts.args << '--window-size=1920,3080'
        opts.args << '--headless'
        opts.args << '--disable-gpu'
        opts.args << '--no-sandbox'
        opts.args << '--disable-popup-blocking'
      end
      browser_options.add_preference(:download, prompt_for_download: false, default_directory: DOWNLOAD_DIRECTORY)
      browser_options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

      Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
    end

    Capybara::Screenshot.register_driver(:selenium_chrome_headless) do |driver, path|
      driver.browser.save_screenshot(path)
    end

    Capybara.javascript_driver = :selenium_chrome_headless

    driven_by :selenium_chrome_headless
  end

  config.after(:each, type: :system, js: true, headless_selenium: true) do
    # remove download files
    wildcard_download_path = DOWNLOAD_DIRECTORY.join('*')
    FileUtils.rm(Dir.glob(wildcard_download_path))
  end

end

