module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs that
  # represents just one model.
  # It needs CsvRowModel::Import
  module Import
    module SingleModel
      extend ActiveSupport::Concern

      class_methods do
        # Safe to override
        #
        # @param cell [String] the cell's string
        # @return [Integer] returns index of the header_match that cell match
        def index_header_match(cell)
          match = header_matchers.each_with_index.select do |matcher, index|
            cell.match(matcher)
          end.first
          match ? match[1] : nil
        end

        # @return [Array] header_matchs matchers for the row model
        def header_matchers
          @header_matchers ||= begin
            columns.map do |name, options|
              matchers = options[:header_matchs] || [name.to_s]
              Regexp.new(matchers.join('|'),Regexp::IGNORECASE)
            end
          end
        end

        def next(csv, context={}, previous=nil)
          source_row = Array.new(header_matchers.size)

          while csv.next_row
            current_row = csv.read_row
            current_row.each_with_index do |cell, position|
              next if cell.blank?
              index = index_header_match(cell)
              next unless index
              source_row[index] = current_row[position + 1]
              break
            end
          end

          new(source_row, context: context)
        end
      end
    end
  end
end


