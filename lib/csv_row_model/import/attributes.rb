require 'csv_row_model/import/cell'

module CsvRowModel
  module Import
    module Attributes
      extend ActiveSupport::Concern

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      def cell_objects
        @cell_objects ||= begin
          csv_string_model.valid?
          _cell_objects(csv_string_model.errors)
        end
      end

      # @return [Hash] a map of `column_name => original_attribute(column_name)`
      def original_attributes
        array_to_block_hash(self.class.column_names) { |column_name| original_attribute(column_name) }
      end

      # @return [Object] the column's attribute before override
      def original_attribute(column_name)
        cell_objects[column_name].try(:value)
      end

      # return [Hash] a map changes from {.column}'s default option': `column_name -> [value_before_default, default_set]`
      def default_changes
        array_to_block_hash(self.class.column_names) { |column_name| cell_objects[column_name].default_change }.delete_if {|k, v| v.blank? }
      end

      protected
      # to prevent circular dependency with csv_string_model
      def _cell_objects(csv_string_model_errors={})
        array_to_block_hash(self.class.column_names) do |column_name|
          Cell.new(column_name, mapped_row[column_name], csv_string_model_errors[column_name], self)
        end
      end

      class_methods do
        protected
        # See {Model#column}
        def column(column_name, options={})
          super
          define_attribute_method(column_name)
        end

        def merge_options(column_name, options={})
          original_options = columns[column_name]
          csv_string_model_class.add_type_validation(column_name, columns[column_name]) unless original_options[:validate_type]
          super
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_attribute_method(column_name)
          return if method_defined? column_name
          csv_string_model_class.add_type_validation(column_name, columns[column_name])
          define_method(column_name) { original_attribute(column_name) }
        end
      end
    end
  end
end
