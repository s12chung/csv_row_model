require 'csv_row_model/model/csv_string_model'

require 'csv_row_model/model/columns'
require 'csv_row_model/model/children'
require 'csv_row_model/model/dynamic_columns'

module CsvRowModel
  # Base module for representing a RowModel---a model that represents row(s).
  module Model
    extend ActiveSupport::Concern

    included do
      include Concerns::InheritedClassVar

      include ActiveWarnings
      include Validators::ValidateAttributes

      include Columns
      include Children
      include DynamicColumns

      # @return [Model] return the parent, if this instance is a child
      attr_reader :parent

      # @return [DateTime] return when self has been intialized
      attr_reader :initialized_at

      validate_attributes :parent
    end

    # @param [NilClass] source not used here, see {Input}
    # @param [Hash] options
    # @option options [String] :parent if the instance is a child, pass the parent
    def initialize(source=nil, options={})
      @initialized_at = DateTime.now
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

    class_methods do
      # @return [Class] the Class with validations of the csv_string_model
      def csv_string_model_class
        @csv_string_model_class ||= inherited_custom_class(:csv_string_model_class, CsvStringModel)
      end

      protected
      # Called to add validations to the csv_string_model_class
      def csv_string_model(&block)
        csv_string_model_class.class_eval(&block)
      end

      def inherited_class_module
        Model
      end
    end
  end
end
