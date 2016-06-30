module CsvRowModel
  module Model
    class DynamicColumnCell
      attr_reader :column_name, :row_model

      def initialize(column_name, row_model)
        @column_name = column_name
        @row_model = row_model
      end

      def value
        @value ||= row_model.class.format_dynamic_column_cells(unformatted_value, column_name, dynamic_column_index, row_model.context)
      end

      def dynamic_column_index
        @dynamic_column_index ||= row_model.class.dynamic_column_index(column_name)
      end

      protected

      def process_cell_method_name
        self.class.process_cell_method_name(column_name)
      end

      # Calls the process_cell to return the value of a Cell given the args
      def call_process_cell(*args)
        row_model.public_send(process_cell_method_name, *args)
      end

      class << self
        def process_cell_method_name(column_name)
          column_name.to_s.singularize.to_sym
        end

        # define a method to process each cell of the attribute method
        # process_cell = one cell
        # attribute_method = many cells = [process_cell(), process_cell()...]
        def define_process_cell(row_model_class, column_name, &block)
          row_model_class.send(:define_method, process_cell_method_name(column_name), &block)
        end
      end
    end
  end
end