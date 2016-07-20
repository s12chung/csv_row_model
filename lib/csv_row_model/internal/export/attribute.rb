require 'csv_row_model/internal/attribute_base'

module CsvRowModel
  module Export
    class Attribute < CsvRowModel::AttributeBase
      def value
        formatted_value
      end

      def source_value
        row_model.public_send(column_name)
      end
    end
  end
end