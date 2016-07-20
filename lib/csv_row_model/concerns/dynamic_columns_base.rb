require 'csv_row_model/concerns/model/dynamic_columns'

# Shared between Import and Export, see test fixture for basic setup
module CsvRowModel
  module DynamicColumnsBase
    extend ActiveSupport::Concern
    include Model::DynamicColumns

    def attribute_objects
      @attribute_objects ||= super.merge(dynamic_column_attribute_objects)
    end

    def attributes
      super.merge!(attributes_from_method_names(self.class.dynamic_column_names))
    end

    # @return [Hash] a map of `column_name => original_attribute(column_name)`
    def original_attributes
      super.merge!(array_to_block_hash(self.class.dynamic_column_names) { |column_name| original_attribute(column_name) })
    end

    # @return [Hash] a map of `column_name => format_cell(column_name, ...)`
    def formatted_attributes
      super.merge!(array_to_block_hash(self.class.dynamic_column_names) { |column_name| attribute_objects[column_name].formatted_cells })
    end

    class_methods do
      protected
      # See {Model::DynamicColumns#dynamic_column}
      def dynamic_column(column_name, options={})
        super
        define_dynamic_attribute_method(column_name)
      end

      # Define default attribute method for a dynamic_column
      # @param column_name [Symbol] the cell's column_name
      def define_dynamic_attribute_method(column_name)
        define_proxy_method(column_name) { original_attribute(column_name) }
        dynamic_attribute_class.define_process_cell(self, column_name)
      end

      def ensure_define_dynamic_attribute_method
        dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end
    end
  end
end