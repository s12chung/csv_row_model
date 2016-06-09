module CsvRowModel
  module Import
    class DynamicColumnCell
      attr_reader :column_name, :source_headers, :source_cells, :row_model

      def initialize(column_name, source_headers, source_cells, row_model)
        @column_name = column_name
        @source_headers = source_headers
        @source_cells = source_cells
        @row_model = row_model
      end

      def value
        @value = begin
          csv_column_index = row_model.class.dynamic_index(column_name)
          values = source_headers.map.with_index do |source_header, index|
            formatted_value = row_model.class.format_cell(source_cells[index], source_header, csv_column_index, row_model.context)
            row_model.public_send(attribute_method, formatted_value, source_header)
          end
          row_model.class.format_dynamic_column_cells(values, column_name, csv_column_index, row_model.context)
        end
      end

      protected

      # method name of:
      # def generate_value_from(source_cell, source_header); end
      #
      # defined in row_model, to generate the values of the attribute
      def attribute_method
        column_name.to_s.singularize.to_sym
      end
    end
  end
end