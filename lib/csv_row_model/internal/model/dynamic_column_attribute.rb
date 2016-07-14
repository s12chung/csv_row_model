require 'csv_row_model/internal/model/attribute'
require 'csv_row_model/internal/concerns/dynamic_column_shared'

module CsvRowModel
  module Model
    class DynamicColumnAttribute < Attribute
      include DynamicColumnShared

      def value
        @value ||= row_model_class.format_dynamic_column_cells(unformatted_value, column_name, column_index, row_model.context)
      end

      protected

      def process_cell_method_name
        self.class.process_cell_method_name(column_name)
      end

      # Calls the process_cell to return the value of a Attribute given the args
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
          row_model_class.define_proxy_method(process_cell_method_name(column_name), &block)
        end
      end
    end
  end
end