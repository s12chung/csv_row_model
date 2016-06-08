require 'csv_row_model/import/base'
require 'csv_row_model/import/csv_string_model'
require 'csv_row_model/import/attributes'
require 'csv_row_model/import/dynamic_columns'
require 'csv_row_model/import/represents'

require 'csv_row_model/model/comparison'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
  module Import
    extend ActiveSupport::Concern

    include Concerns::Inspect
    include Concerns::InvalidOptions

    include Base
    include CsvStringModel
    include Attributes
    include DynamicColumns
    include Represents

    include Model::Comparison # can't be added on Model module because Model does not have attributes implemented
  end
end
