module CsvRowModel
  module Export
    class Cell
      attr_reader :column_name, :row_model

      def initialize(column_name, row_model)
        @column_name = column_name
        @row_model = row_model
      end

      def value
        formatted_value
      end

      def formatted_value
        @formatted_value ||= row_model.class.format_cell(source_value, column_name, row_model.class.index(column_name), row_model.context)
      end

      def source_value
        row_model.public_send(column_name)
      end
    end
  end
end