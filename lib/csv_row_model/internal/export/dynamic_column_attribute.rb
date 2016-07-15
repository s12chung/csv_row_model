require 'csv_row_model/internal/model/dynamic_column_attribute'

module CsvRowModel
  module Export
    class DynamicColumnAttribute < CsvRowModel::Model::DynamicColumnAttribute
      def unformatted_value
        formatted_cells
      end

      def source_cells
        header_models.map { |header_model| call_process_cell(header_model) }
      end

      class << self
        def define_process_cell(row_model_class, column_name)
          super { |header_model| header_model }
        end
      end
    end
  end
end