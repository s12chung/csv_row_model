module CsvRowModel
  module Model
    class DynamicColumnCell
      def value
        @value ||= row_model.class.format_dynamic_column_cells(unformatted_value, column_name, dynamic_column_index, row_model.context)
      end

      def dynamic_column_index
        @dynamic_column_index ||= row_model.class.dynamic_column_index(column_name)
      end

      protected

      def process_method_name
        self.class.process_method_name(column_name)
      end

      # Calls the process_method to return the value of a Cell given the args
      def call_process_method(*args)
        row_model.public_send(process_method_name, *args)
      end

      class << self
        def process_method_name(column_name)
          column_name.to_s.singularize.to_sym
        end

        # define a method to process each cell of the attribute method
        # process_method = formatted_cell + source_header --> one cell
        # attribute_method = many cells = [process_method(), process_method()...]
        def define_process_method(row_model_class, column_name, &block)
          row_model_class.send(:define_method, process_method_name(column_name), &block)
        end
      end
    end
  end
end