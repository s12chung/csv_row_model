require 'csv_row_model/concerns/export/base'
require 'csv_row_model/concerns/export/dynamic_columns'
require 'csv_row_model/concerns/export/attributes'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    include Base
    include Attributes
    include DynamicColumns
  end
end
