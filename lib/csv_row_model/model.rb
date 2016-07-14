require 'csv_row_model/model/base'
require 'csv_row_model/model/columns'
require 'csv_row_model/model/children'
require 'csv_row_model/model/dynamic_columns'
require 'csv_row_model/model/comparison'

require 'csv_row_model/concerns/inspect'
require 'csv_row_model/concerns/hidden_module'

module CsvRowModel
  # Base module for representing a RowModel---a model that represents row(s).
  module Model
    extend ActiveSupport::Concern

    include HiddenModule

    include InheritedClassVar

    include ActiveWarnings

    include Base

    include Columns
    include Children
    include DynamicColumns

    include Comparison
  end
end
