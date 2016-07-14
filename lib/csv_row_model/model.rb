require 'inherited_class_var'

require 'csv_row_model/concerns/model/base'
require 'csv_row_model/concerns/model/attributes'
require 'csv_row_model/concerns/model/children'
require 'csv_row_model/concerns/model/dynamic_columns'

require 'csv_row_model/concerns/inspect'
require 'csv_row_model/concerns/hidden_module'

module CsvRowModel
  # Base module for representing a RowModel---a model that represents row(s).
  module Model
    extend ActiveSupport::Concern

    include InheritedClassVar
    include ActiveWarnings

    include HiddenModule

    include Base
    include Attributes
    include Children
    include DynamicColumns
  end
end
