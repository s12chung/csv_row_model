module CsvRowModel
  module Import
    class Csv
      class Row
        attr_reader :row, :skipped_rows

        def initialize(row, index, skipped_rows)
          @row, @index, @skipped_rows = row, index, skipped_rows
        end

        def empty?
          !!row.try(:empty?)
        end
      end
    end
  end
end