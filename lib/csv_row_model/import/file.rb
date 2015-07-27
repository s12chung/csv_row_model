require 'csv_row_model/import/file/callbacks'
require 'csv_row_model/import/file/validations'

module CsvRowModel
  module Import
    # Represents a csv file and handles parsing to return `Import` or `Mapper`
    class File
      include Callbacks
      include Validations

      # @return [Csv]
      attr_reader :csv
      # @return [Input,Mapper] model class returned for importing
      attr_reader :row_model_class

      # Current index of the row model
      # @return [Integer] returns -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
      attr_reader :index
      # @return [Input, Mapper] the current row model set by {#next}
      attr_reader :current_row_model
      # @return [Input, Mapper] the previous row model set by {#next}
      attr_reader :previous_row_model

      delegate :header, :size, to: :csv

      # @param [String] file_path path of csv file
      # @param [Import, Mapper] row_model_class model class returned for importing
      def initialize(file_path, row_model_class)
        @csv, @row_model_class = Csv.new(file_path), row_model_class
        reset
      end

      # Resets the file back to the top
      def reset
        csv.reset
        @index = -1
        @current_row_model = nil
      end

      # Gets the next row model based on the context
      #
      # @param context [Hash] context passed to the {Import}
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

      # @return [Boolean] returns true, if the object is at the end of file
      def end_of_file?
        csv.end_of_file?
      end

      # @return [Boolean] iterator of the {#each} method
      def each_iterator(context={})
        to_enum(:each, context)
      end

      # Iterates through the entire csv file and provides the `current_row_model` in a block, while handing aborts and skips
      # via. calling {Model#abort?} and {Model#skip?}
      #
      # @param context [Hash] context passed to the {Import}
      def each(context={})
        return false if _abort?

        while self.next(context)
          return false if _abort?
          next if _skip?

          run_callbacks :yield do
            yield current_row_model
          end
        end
      end

      protected
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
