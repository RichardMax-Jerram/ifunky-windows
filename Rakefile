require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'ci/reporter/rake/rspec'


PuppetLint.configuration.fail_on_warnings = false
PuppetLint.configuration.relative = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_documentation')
#PuppetLint.configuration.send('disable_single_quote_string_with_variables')
#PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp", "spec/**/*.pp"]
#PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
#PuppetLint.configuration.ignore_paths = ["**/spec/**/*.pp", "**/vendor/**/*.pp"]

PuppetSyntax.exclude_paths = ["**/spec/**/*.pp", "**/vendor/**/*.pp"]
PuppetSyntax.future_parser = true

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.fail_on_warnings = true
  config.ignore_paths = ["**/spec/**/*.pp", "**/vendor/**/*.pp"]
  config.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
end

PuppetSyntax.exclude_paths = ["**/spec/**/*", "**/vendor/**/*"]

# Show reports in Jenkins
ENV['CI_REPORTS'] = 'reports'

desc "Run syntax, lint, and spec tests."
task :test => [
         :syntax,
         :lint,
         :spec
     ]

namespace :ci do
  task :all => ['ci:setup:rspec', 'spec', 'syntax', 'lint', 'spec']
end