module CsvRowModel
  module Model
    class DynamicColumnHeader < Header
      include DynamicColumnShared

      def value
        header_models.map { |header_model| header_proc.call(header_model) }
      end

      def header_proc
        options[:header] || ->(header_model) { format_header(header_model) }
      end

      def format_header(header_model)
        row_model_class.format_dynamic_column_header(header_model, column_name, dynamic_column_index, 0, context)
      end

      def dynamic_column_index
        row_model_class.dynamic_column_index(column_name)
      end

      def options
        row_model_class.dynamic_columns[column_name]
      end
    end
  end
end