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
        @value ||= row_model.class.format_dynamic_column_cells(unformatted_value, column_name, dynamic_index, row_model.context)
      end

      def unformatted_value
        formatted_cells.zip(formatted_headers).map do |formatted_cell, source_header|
          call_process_method(formatted_cell, source_header)
        end
      end

      def formatted_cells
        source_cells.map.with_index do |source_cell, index|
          row_model.class.format_cell(source_cell, column_name, dynamic_index + index, row_model.context)
        end
      end

      def formatted_headers
        source_headers.map.with_index do |source_header, index|
          row_model.class.format_dynamic_column_header(source_header, column_name, dynamic_index, index, row_model.context)
        end
      end

      def dynamic_index
        @dynamic_index ||= row_model.class.dynamic_index(column_name)
      end

      protected
      def process_method_name
        self.class.process_method_name(column_name)
      end

      def call_process_method(formatted_cell, source_header)
        row_model.public_send(process_method_name, formatted_cell, source_header)
      end

      class << self
        def process_method_name(column_name)
          column_name.to_s.singularize.to_sym
        end

        # define a method to process each cell of the attribute method
        # process_method = formatted_cell + source_header --> one cell
        # attribute_method = many cells
        def define_process_method(row_model_class, column_name)
          row_model_class.send(:define_method, process_method_name(column_name)) { |formatted_cell, source_header| formatted_cell }
        end
      end
    end
  end
end