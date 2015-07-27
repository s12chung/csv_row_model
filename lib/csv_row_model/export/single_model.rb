module CsvRowModel
  module Export
    module SingleModel
      extend ActiveSupport::Concern

      included do

        alias_method :is_row_name?, :is_column_name?

        class << self
          # @return [Boolean] by default false
          def single_model?
            true
          end
        end
      end

      # @return [Array] an array of rows, where if cell is row_name, it's parsed into the header_match
      #                 and everything else is return as is.
      def to_rows
        rows_temaplate.map do |row|
          result = []
          row.each do |cell|
            if is_row_name? cell
              header_matchs = self.class.options(cell)[:header_matchs]
              result << "#{header_matchs ? header_matchs.first : self.class.format_header(cell)}"
              result << "#{attributes[cell]}"
            else
              result << cell.to_s
            end
          end
          result
        end
      end

      # Safe to override
      #
      # @return [Array<Array>] an array of arrays, where every represents a row and every row
      #                        can have strings and row_name (column_name). By default,
      #                        returns a row_name for every row
      def rows_temaplate
        @rows_temaplate ||= self.class.row_names.map{ |row_name| [row_name]}
      end

    end
  end
end