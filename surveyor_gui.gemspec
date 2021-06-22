$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "surveyor_gui/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "surveyor_gui"
  s.version     = SurveyorGui::VERSION
  s.authors     = ["Kevin Jay"]
  s.email       = ["kjayma@gmail.com"]
  s.homepage    =  %q{http://github.com/kjayma/surveyor_gui}
  s.post_install_message = %q{Thanks for installing surveyor_gui! The time has come to run the surveyor_gui generator and migrate your database, even if you are upgrading.}
  s.summary     = "A Rails gem to supply a front-end and reporting capability to the Surveyor gem."

  #s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.files = `git ls-files`.split("\n") - ['irb']
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '~> 6.1'
  s.add_dependency 'dynamic_form', '~> 1.1.4'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'bootstrap-sass', '~> 3.3'
  s.add_dependency 'formtastic', '~> 3.1'

  s.add_development_dependency "mysql2"

  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'uglifier', '>= 1.0.3'
  s.add_development_dependency('rspec-rails', '~> 3.0')
  s.add_development_dependency('sprockets', '~> 3.7')

  # tests fail with capybara 3...lots of custom rspec shenanigans that result in many failing tests...failing rspec
  # customizations will need to be addressed before upgrading :(
  s.add_development_dependency('capybara')
  s.add_development_dependency('capybara-screenshot')
  s.add_development_dependency('selenium-webdriver')
  s.add_development_dependency('webdrivers', '~> 4.0')
  s.add_development_dependency('launchy', '~> 2.4.2')
  s.add_development_dependency('poltergeist')
  s.add_development_dependency('puma')
  s.add_development_dependency('capybara-webkit', "= 1.15.1")
  s.add_development_dependency('json_spec', '~> 1.1.1')
  s.add_development_dependency('factory_bot_rails')
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('rspec-retry', "= 0.4.4")
  s.add_development_dependency('phantomjs', '~> 2.1')
  s.add_development_dependency('cliver', '~> 0.3')
  s.add_development_dependency('rails-controller-testing')

  # s.add_dependency 'surveyor', '~> 1.4.1.pre'

  s.add_dependency 'will_paginate'

  s.add_dependency 'simple_form'
  s.add_dependency 'carrierwave'
  s.add_dependency 'colorbox-rails', '~> 0.1.1'
  s.add_dependency 'jquery-form-rails', '~> 1.0.1'
  s.add_dependency 'deep_cloneable'
  s.add_dependency 'lazy_high_charts'

  # TODO The editor fails when upgrading to the new 5.0 version.  So will need to be fixed when upgrading the whole project
  s.add_dependency 'tinymce-rails', '= 4.8.3'
  s.add_dependency 'cocoon'
  s.add_dependency 'font-awesome-rails'
end
