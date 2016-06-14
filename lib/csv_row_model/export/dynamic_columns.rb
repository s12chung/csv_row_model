require 'csv_row_model/export/dynamic_column_cell'

module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      def cells
        @dynamic_column_cells ||= super.merge(array_to_block_hash(self.class.dynamic_column_names) do |column_name|
          DynamicColumnCell.new(column_name, self)
        end)
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        super.flatten
      end

      # See Model::Export#formatted_attributes
      def formatted_attributes
        super.merge!(array_to_block_hash(self.class.dynamic_column_names) { |column_name| formatted_attribute(column_name) })
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
          define_method(column_name) { formatted_attribute(column_name) }
          DynamicColumnCell.define_process_cell(self, column_name)
        end
      end
    end
  end
end
