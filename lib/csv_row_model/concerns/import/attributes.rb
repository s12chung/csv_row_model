require 'csv_row_model/concerns/attributes_base'
require 'csv_row_model/concerns/import/csv_string_model'
require 'csv_row_model/internal/import/attribute'

module CsvRowModel
  module Import
    module Attributes
      extend ActiveSupport::Concern
      include AttributesBase
      include CsvStringModel

      included do
        ensure_attribute_method
      end

      def attribute_objects
        @attribute_objects ||= begin
          csv_string_model.valid?
          _attribute_objects(csv_string_model.errors)
        end
      end

      # return [Hash] a map changes from {.column}'s default option': `column_name -> [value_before_default, default_set]`
      def default_changes
        array_to_block_hash(self.class.column_names) { |column_name| attribute_objects[column_name].default_change }.delete_if {|k, v| v.blank? }
      end

      protected
      # to prevent circular dependency with csv_string_model
      def _attribute_objects(csv_string_model_errors={})
        index = -1
        array_to_block_hash(self.class.column_names) do |column_name|
          Attribute.new(column_name, source_row[index += 1], csv_string_model_errors[column_name], self)
        end
      end

      class_methods do
        protected
        def merge_options(column_name, options={})
          original_options = columns[column_name]
          csv_string_model_class.add_type_validation(column_name, columns[column_name]) unless original_options[:validate_type]
          super
        end

        def define_attribute_method(column_name)
          return if super { original_attribute(column_name) }.nil?
          csv_string_model_class.add_type_validation(column_name, columns[column_name])
        end
      end
    end
  end
end
