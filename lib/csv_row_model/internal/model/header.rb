module CsvRowModel
  module Model
    class Header
      attr_reader :column_name, :row_model_class, :context

      def initialize(column_name, row_model_class, context)
        @column_name = column_name
        @row_model_class = row_model_class
        @context = OpenStruct.new(context)
      end

      def value
        options[:header] || formatted_header
      end

      def formatted_header
        row_model_class.format_header(column_name, index, context)
      end
      def options
        row_model_class.columns[column_name]
      end
      def index
        row_model_class.index(column_name)
      end
    end
  end
end