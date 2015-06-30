if defined?(Rails)
  require "csv_row_model/engine"
else
  require "active_support"

  require "csv_row_model/version"
  require "csv_row_model/base"
end

module CsvRowModel
end
