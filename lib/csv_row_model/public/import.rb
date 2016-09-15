require 'csv_row_model/public/model'
require 'csv_row_model/concerns/import/base'
require 'csv_row_model/concerns/import/attributes'
require 'csv_row_model/concerns/import/dynamic_columns'
require 'csv_row_model/concerns/import/represents'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
  module Import
    extend ActiveSupport::Concern

    include CsvRowModel::Model

    include Base
    include Attributes
    include Represents
    include DynamicColumns
  end
end
