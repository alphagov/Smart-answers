source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp

gem 'rails', '5.1.6'
gem "railties"
gem "sprockets-rails"

gem 'govuk_app_config'

gem 'ast'
gem "gds-api-adapters", "~> 52.5.1"
gem 'govspeak', '~> 5.6.0'
gem 'govuk-content-schema-test-helpers', '~> 1.6.1'
gem 'govuk_frontend_toolkit', '>= 6.0.4'
gem 'govuk_publishing_components', '6.5.0'
gem 'htmlentities', '~> 4'
gem 'json'
gem 'lrucache', '0.1.4'
gem 'method_source'
gem 'parser'
gem 'plek', '2.1.1'
gem 'rack_strip_client_ip'
gem 'rails-i18n'
gem 'sass-rails', '~> 5.0.7'
gem 'slimmer', '~> 12.0.0'
gem 'tilt', '2.0.8'
gem 'uglifier'
gem 'uk_postcode', '~> 2.1.2'
gem 'rails_stdout_logging'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'nokogiri'
end

group :development, :test do
  gem 'govuk-lint'
  gem 'pry'
  gem 'byebug'
end

group :test do
  gem 'rails-controller-testing'
  gem 'capybara', '2.18.0'
  gem 'ci_reporter'
  gem 'minitest', '~> 5.11'
  gem 'minitest-focus', '~> 1.1', '>= 1.1.2'
  gem 'mocha', '1.4.0', require: false
  gem 'poltergeist', '1.17.0'
  gem 'shoulda', '~> 3.5.0'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
  gem 'timecop'
  gem 'webmock', '~> 3.3.0', require: false
end
