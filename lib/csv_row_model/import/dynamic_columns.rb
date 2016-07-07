require 'csv_row_model/import/dynamic_column_cell'

module CsvRowModel
  module Import
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      def cell_objects
        @dynamic_column_cell_objects ||= super.merge(array_to_block_hash(self.class.dynamic_column_names) do |column_name|
          DynamicColumnCell.new(column_name, dynamic_column_source_headers, dynamic_column_source_cells, self)
        end)
      end

      # @return [Hash] a map of `column_name => format_cell(column_name, ...)`
      def formatted_attributes
        super.merge!(array_to_block_hash(self.class.dynamic_column_names) { |column_name| cell_objects[column_name].formatted_cells })
      end

      # @return [Hash] a map of `column_name => original_attribute(column_name)`
      def original_attributes
        super.merge!(array_to_block_hash(self.class.dynamic_column_names) { |column_name| original_attribute(column_name) })
      end

      # @return [Array] dynamic_column headers
      def dynamic_column_source_headers
        self.class.dynamic_column_source_headers source_headers
      end

      # @return [Array] dynamic_column row data
      def dynamic_column_source_cells
        self.class.dynamic_column_source_cells source_row
      end

      class_methods do
        def dynamic_column_source_headers(source_headers)
          dynamic_columns? ? source_headers[columns.size..-1] : []
        end

        def dynamic_column_source_cells(source_row)
          dynamic_columns? ? source_row[columns.size..-1] : []
        end

        protected

        # See {Model#dynamic_column}
        def dynamic_column(column_name, options={})
          super
          define_dynamic_attribute_method(column_name)
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_dynamic_attribute_method(column_name)
          define_proxy_method(column_name) { original_attribute(column_name) }
          DynamicColumnCell.define_process_cell(self, column_name)
        end
      end
    end
  end
end
