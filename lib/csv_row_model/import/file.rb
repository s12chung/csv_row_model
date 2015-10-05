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
      # @return [Hash] context passed to the {Import}
      attr_reader :context

      delegate :header, :size, :skipped_rows, :end_of_file?, to: :csv

      # @param [String] file_path path of csv file
      # @param [Import, Mapper] row_model_class model class returned for importing
      # @param context [Hash] context passed to the {Import}
      def initialize(file_path, row_model_class, context={})
        @csv, @row_model_class, @context = Csv.new(file_path), row_model_class, context.to_h
        reset
      end

      # Resets the file back to the top
      def reset
        csv.reset
        @index = -1
        @current_row_model = nil
      end

      # Gets the next row model based on the context
      def next(context={})
        return if end_of_file?

        run_callbacks :next do
          context = context.to_h.reverse_merge(self.context)
          @previous_row_model = current_row_model
          @current_row_model = row_model_class.next(csv, context, previous_row_model)
          @index += 1
          @current_row_model = @index = nil if end_of_file?
        end

        current_row_model
      end

      # Iterates through the entire csv file and provides the `current_row_model` in a block, while handing aborts and skips
      # via. calling {Model#abort?} and {Model#skip?}
      def each(context={})
        return to_enum(__callee__) unless block_given?
        return false if _abort?

        while self.next(context)
          run_callbacks :each_iteration do
            return false if _abort?
            next if _skip?

            yield current_row_model
          end
        end
      end
    end
  end
end
