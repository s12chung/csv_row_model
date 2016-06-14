module CsvRowModel
  module Export
    class DynamicColumnCell < CsvRowModel::Model::DynamicColumnCell
      attr_reader :column_name, :row_model

      def initialize(column_name, row_model)
        @column_name = column_name
        @row_model = row_model
      end

      def unformatted_value
        cells.map.with_index.map do |cell, index|
          row_model.class.format_cell(cell, column_name, dynamic_column_index + index, row_model.context)
        end
      end

      def cells
        header_models.map { |header_model| call_process_method(header_model) }
      end

      def header_models
        row_model.context.public_send(column_name)
      end

      class << self
        def define_process_method(row_model_class, column_name)
          super { |header_model| header_model }
        end
      end
    end
  end
end