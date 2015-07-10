require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'csv_row_model'
require 'bundler/setup'

require 'fixtures/models'

begin
  require 'pry'
rescue LoadError
end

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end
