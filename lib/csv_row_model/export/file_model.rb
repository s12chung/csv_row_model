module CsvRowModel
  module Export
    module FileModel
      extend ActiveSupport::Concern

      # @return [Array] an array of rows, where if cell is row_name, it's parsed into the header_match
      #                 and everything else is return as is.
      def to_rows
        rows_template.map do |row|
          [].tap do |result|
            row.each do |cell|
              if header? cell
                result << self.class.format_header(cell, context)
              else
                result << cell.to_s
              end
            end
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

      private

      def header?(cell)
        self.class.is_row_name? cell
      end

    end
  end
end
