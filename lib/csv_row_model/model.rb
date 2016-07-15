require 'csv_row_model/concerns/model/base'
require 'csv_row_model/concerns/model/attributes'
require 'csv_row_model/concerns/model/children'
require 'csv_row_model/concerns/model/dynamic_columns'

module CsvRowModel
  # Base module for representing a RowModel---a model that represents row(s).
  module Model
    extend ActiveSupport::Concern

    include ActiveWarnings

    include Base
    include Attributes
    include Children
    include DynamicColumns
  end
end
