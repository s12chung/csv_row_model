require 'csv_row_model/model/deep_class_var'
require 'csv_row_model/model/columns'
require 'csv_row_model/model/children'

module CsvRowModel
  # Base module for representing a RowModel---a model that represents row(s).
  module Model
    extend ActiveSupport::Concern
    include CsvRowModel::Memoize

    included do
      include ActiveModel::Validations
      include Validators::ValidateAttributes

      include DeepClassVar
      include Columns
      include Children

      # @return [Model] return the parent, if this instance is a child
      attr_reader :parent

      validate_attributes :parent
    end

    # @param [NilClass] source not used here, see {Input}
    # @param [Hash] options
    # @option options [String] :parent if the instance is a child, pass the parent
    def initialize(source=nil, options={})
      @parent = options[:parent]
    end

    # Safe to override.
    #
    # @return [Boolean] returns true, if this instance should be skipped
    def skip?
      !valid?
    end

    # Safe to override.
    #
    # @return [Boolean] returns true, if the entire csv file should stop reading
    def abort?
      false
    end
  end
end
