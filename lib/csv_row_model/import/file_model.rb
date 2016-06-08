module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs that
  # represents just one model.
  # It needs CsvRowModel::Import
  module Import
    module FileModel
      extend ActiveSupport::Concern

      class_methods do
        # Safe to override
        #
        # @param cell [String] the cell's string
        # @return [Integer] returns index of the header_match that cell match
        def index_header_match(cell, context)
          match = header_matchers(context).each_with_index.select do |matcher, index|
            cell.match(matcher)
          end.first

          match ? match[1] : nil
        end

        # @return [Array] header_matchs matchers for the row model
        def header_matchers(context)
          @header_matchers ||= begin
            columns.map do |name, options|
              if formatted_header = self.format_header(name, context)
                Regexp.new("^#{formatted_header}$", Regexp::IGNORECASE)
              end
            end.compact
          end
        end

        def next(file, context={})
          csv = file.csv
          return csv.read_row unless csv.next_row

          source_row = Array.new(header_matchers(context).size)

          while csv.next_row
            current_row = csv.read_row

            current_row.each_with_index do |cell, position|
              next if position == 0 # This is a hack to ignore the first column because of infos.csv have 'Compte' twice... 
              next if cell.blank?
              index = index_header_match(cell, context)
              next unless index
              source_row[index] = current_row[position + 1]
              break
            end
          end

          new(source_row, source_header: csv.header, context: context, previous: file.previous_row_model)
        end
      end
    end
  end
end
