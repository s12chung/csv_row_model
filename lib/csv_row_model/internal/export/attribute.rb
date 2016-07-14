require 'csv_row_model/internal/model/attribute'

module CsvRowModel
  module Export
    class Attribute < CsvRowModel::Model::Attribute
      def value
        formatted_value
      end

      def source_value
        row_model.public_send(column_name)
      end
    end
  end
end