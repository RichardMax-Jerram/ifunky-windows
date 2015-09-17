source "https://rubygems.org"

gem 'rake'

group :test do
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "puppetlabs_spec_helper"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "rspec-puppet-facts"
  gem 'rspec-hiera-puppet'
  gem "rspec", "< 3.2.0", { "platforms" => ["ruby_18"] }
  gem 'metadata-json-lint'
  gem 'ci_reporter_rspec'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check', :require => false
  gem 'puppet-lint-version_comparison-check', :require => false
  gem 'puppet-lint-empty_string-check', :require => false
  gem 'puppet-lint-absolute_classname-check', :require => false
  gem 'puppet-lint-roles_and_profiles-check'
  gem 'test-unit'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
end
