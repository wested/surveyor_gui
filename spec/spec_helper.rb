# This file is customized to run specs withing the testbed environemnt
ENV["RAILS_ENV"] ||= 'test'
begin
  require File.expand_path("../../testbed/config/environment", __FILE__)
rescue LoadError => e
  fail "Could not load the testbed app. Have you generated it?\n#{e.class}: #{e}"
end

require 'rspec/rails'
#require 'rspec/autorun'

require 'capybara/rails'
require 'capybara/rspec'
#require 'capybara/poltergeist'
require 'factories'
require 'json_spec'
require 'database_cleaner'
require 'rspec/retry'
require 'rack/utils'
require 'rails-controller-testing'
require 'webdrivers'
require 'capybara-screenshot/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

Capybara.app = Rack::ShowExceptions.new(Testbed::Application)
# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema! if ::Rails.version >= "4.0" && defined?(ActiveRecord::Migration)


Capybara.server_port = 3001
Capybara.asset_host = "http://lvh.me:3001"

Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  config.include JsonSpec::Helpers
  config.include SurveyorAPIHelpers
  config.include SurveyorUIHelpers
  config.include WaitForAjax

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # config.expect_with :rspec do |c|
  #   c.syntax = :expect
  # end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # rspec-retry
  # https://github.com/rspec/rspec-core/issues/456
  config.verbose_retry       = true # show retry status in spec process
  retry_count                = ENV['RSPEC_RETRY_COUNT']
  config.default_retry_count = retry_count.try(:to_i) || 1
  puts "RSpec retry count is #{config.default_retry_count}"

  # host
  config.before :each do
  #  host = "lvh.me:"+Capybara.current_session.driver.server.port.to_s
  ##  puts host
  #  Capybara.asset_host = "http://#{host}"
  #  Rails.application.routes.default_url_options[:host] = host
  ##    #"lvh.me:"+Capybara.current_session.driver.server.port.to_s
  end

  # Database Cleaner
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each do |example|
    if example.metadata[:clean_with_truncation] || example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.append_after :each do
    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!

  config.before(:all, type: :system) do
    Capybara.server = :puma, { Silent: true }
  end
end
JsonSpec.configure do
  exclude_keys "id", "created_at", "updated_at", "uuid", "modified_at", "completed_at"
end
