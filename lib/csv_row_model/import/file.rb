require 'csv_row_model/import/file/callbacks'
require 'csv_row_model/import/file/validations'
require 'csv_row_model/state_helpers'

module CsvRowModel
  module Import
    class File
      include Callbacks
      include Validations

      attr_reader :csv, :row_model_class,
                  :index, # = -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
                  :current_row_model, :previous_row_model

      delegate :header, :size, to: :csv

      def initialize(file_path, row_model_class)
        @csv, @row_model_class = Csv.new(file_path), row_model_class
        reset
      end

      def reset
        csv.reset
        @index = -1
        @current_row_model = nil
      end

      def next(context={})
        csv.skip_header

        next_line_is_parent_row = true
        loop do
          @previous_row_model = current_row_model if next_line_is_parent_row

          csv.readline
          return set_end_of_file if csv.end_of_file?

          set_current_row_model(context) if next_line_is_parent_row

          next_line_is_parent_row = !current_row_model.append_child(csv.next_line)
          return current_row_model if next_line_is_parent_row
        end
      end

      def end_of_file?
        StateHelpers.and index.nil?, current_row_model.nil? && csv.end_of_file?
      end

      def each(context={})
        return false if _abort?

        while self.next(context)
          # TODO: collect row_model errors

          return false if _abort?
          next if _skip?

          run_callbacks :yield do
            yield current_row_model, csv.index
          end
        end
      end

      private
      def set_current_row_model(context)
        @current_row_model = row_model_class.new(csv.current_row, context: context, source_header: header, previous: previous_row_model)
        @index += 1
      end

      def set_end_of_file
        # please return nil
        @current_row_model = @index = nil
      end
    end
  end
end