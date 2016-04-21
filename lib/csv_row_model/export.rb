require 'csv_row_model/export/base'
require 'csv_row_model/export/dynamic_columns'
require 'csv_row_model/export/attributes'
require 'csv_row_model/model/comparison'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    include Base
    include Attributes
    include DynamicColumns

    include Model::Comparison # can't be added on Model module because Model does not have attributes implemented
  end
end
