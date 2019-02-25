$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'csv_row_model'

require Dir.pwd + '/spec/support/shared_context/with_context.rb'
Dir[Dir.pwd + '/spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true

  c.include CsvFilePaths
  c.include WithThisThenContext
end