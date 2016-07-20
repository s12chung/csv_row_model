require 'csv_row_model/internal/import/csv'

module CsvRowModel
  module Import
    # Represents a csv file and handles parsing to return `Import`
    class File
      extend ActiveModel::Callbacks
      include ActiveWarnings

      attr_reader :csv, :row_model_class
      attr_reader :index # -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
      attr_reader :current_row_model, :previous_row_model, :context

      delegate :size, :end_of_file?, :line_number, to: :csv

      define_model_callbacks :each_iteration
      define_model_callbacks :next
      define_model_callbacks :abort, :skip, only: :before

      validate { errors.messages.merge!(csv.errors.messages) unless csv.valid? }
      warnings do
        validate :headers_invalid_row
      end

      # @param [String] file_path path of csv file
      # @param [Import] row_model_class model class returned for importing
      # @param context [Hash] context passed to the {Import}
      def initialize(file_path, row_model_class, context={})
        @csv = Csv.new(file_path)
        @row_model_class = row_model_class
        @context = context.to_h.symbolize_keys
        reset
      end

      def headers
        h = csv.headers
        h.class == Array ? h : []
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
          @index += 1
          @current_row_model = row_model_class.next(self, context)
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

      # @return [Boolean] returns true, if the file should abort reading
      def abort?
        !valid? || !!current_row_model.try(:abort?)
      end

      # @return [Boolean] returns true, if the file should skip `current_row_model`
      def skip?
        !!current_row_model.try(:skip?)
      end

      protected
      def _abort?
        abort = abort?
        run_callbacks(:abort) if abort
        abort
      end

      def _skip?
        skip = skip?
        run_callbacks(:skip) if skip
        skip
      end

      #
      # Validations
      #
      def headers_invalid_row
        errors.add(:csv, "has header with #{csv.headers.message}") if csv.headers.class < Exception
      end

      def headers_count
        return if headers_invalid_row || !csv.valid?
        return if row_model_class.dynamic_columns? || row_model_class.try(:row_names) # dynamic_column or FileModel

        size_until_blank = ((headers || []).map { |h| h.try(:strip) }.rindex(&:present?) || -1) + 1
        column_names = row_model_class.column_names

        return if size_until_blank == column_names.size
        errors.add(:headers, "count does not match. Given headers (#{size_until_blank}). Expected headers (#{column_names.size}): #{column_names.join(", ")}.")
      end
    end
  end
end
