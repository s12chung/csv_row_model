if defined?(Rails)
  require "csv_row_model/engine"
else
  require "active_support"

  require "csv_row_model/version"
  require "csv_row_model/base"

  require "csv_row_model/import"
  require "csv_row_model/import_file"
  require "csv_row_model/import_mapper"
end

module CsvRowModel
end