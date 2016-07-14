require 'csv_row_model/internal/export/dynamic_column_attribute'

module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      def attribute_objects
        @dynamic_column_attribute_objects ||= super.merge(array_to_block_hash(self.class.dynamic_column_names) do |column_name|
          DynamicColumnAttribute.new(column_name, self)
        end)
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        super.flatten
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
          DynamicColumnAttribute.define_process_cell(self, column_name)
        end
      end
    end
  end
end
