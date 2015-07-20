Bundler.require(:default, :test)
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'csv_row_model'

Dir[Dir.pwd + '/spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end