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

    ATTRIBUTE_METHODS = {
      original_attributes: :value, # a map of `column_name => original_attribute(column_name)`
      formatted_attributes: :formatted_cells, # a map of `column_name => format_cell(column_name, ...)`
    }.freeze
    ATTRIBUTE_METHODS.each do |method_name, attribute_method|
      define_method(method_name) do
        super().merge! column_names_to_attribute_value(self.class.dynamic_column_names, attribute_method)
      end
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