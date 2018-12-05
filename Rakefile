begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler/gem_tasks'

require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "-I #{File.expand_path('../spec/', __FILE__)}"
  t.pattern =  File.expand_path('../spec/**/*_spec.rb', __FILE__)
end

task(default: :spec)
