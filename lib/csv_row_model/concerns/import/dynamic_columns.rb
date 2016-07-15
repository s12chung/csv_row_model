require 'csv_row_model/concerns/dynamic_columns_base'
require 'csv_row_model/internal/import/dynamic_column_attribute'

module CsvRowModel
  module Import
    module DynamicColumns
      extend ActiveSupport::Concern
      include DynamicColumnsBase

      included do
        ensure_define_dynamic_attribute_method
      end

      def dynamic_column_attribute_objects
        @dynamic_column_attribute_objects ||= array_to_block_hash(self.class.dynamic_column_names) do |column_name|
          self.class.dynamic_attribute_class.new(column_name, dynamic_column_source_headers, dynamic_column_source_cells, self)
        end
      end

      # @return [Array] an array of format_dynamic_column_header(...)
      def formatted_dynamic_column_headers
        dynamic_column_attribute_objects.values.first.try(:formatted_headers) || []
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

        def dynamic_attribute_class
          DynamicColumnAttribute
        end
      end
    end
  end
end
