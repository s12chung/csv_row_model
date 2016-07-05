module CsvRowModel
  module Export
    module FileModel
      extend ActiveSupport::Concern

      # @return [Array] an array of rows, where if cell is row_name, it's parsed into the header_match
      #                 and everything else is return as is.
      def to_rows
        rows_template.map.with_index do |row, index|
          row.map do |cell|
            self.class.row_names.include?(cell) ? self.class.format_header(cell, index, context) : cell.to_s
          end
        end
      end

      # Safe to override
      #
      # @return [Array<Array>] an array of arrays, where every represents a row and every row
      #                        can have strings and row_name (column_name). By default,
      #                        returns a row_name for every row
      def rows_template
        @rows_template ||= self.class.row_names.map { |row_name| [row_name] }
      end

      class_methods do
        def setup(csv, context, with_headers: true); end
      end
    end
  end
end
