if defined?(Rails)
  require 'csv_row_model/engine'
else
  require 'active_model'

  require 'csv_row_model/version'

  require 'csv_row_model/model'

  require 'csv_row_model/import'
  require 'csv_row_model/import/csv'
  require 'csv_row_model/import/file'
  require 'csv_row_model/import/mapper'
end

module CsvRowModel
end