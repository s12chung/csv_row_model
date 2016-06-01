module CsvRowModel
  module Import
    # Abstraction of Ruby's CSV library. Keeps current row and index, skips empty rows, handles errors.
    class Csv
      # @return [String] the file path of the CSV
      attr_reader :file_path
      # @return [Integer, nil] return `-1` at start of file, `0 to infinity` is index of row_model, `nil` is end of file (row is also `nil`)
      attr_reader :index
      # @return [Array, nil] the current row, or nil at the beginning or end of file
      attr_reader :current_row

      include ActiveModel::Validations

      validate { begin; _ruby_csv; rescue => e; errors.add(:ruby_csv, e.message) end }

      def initialize(file_path)
        @file_path = file_path
        reset
      end

      # http://stackoverflow.com/questions/2650517/count-the-number-of-lines-in-a-file-without-reading-entire-file-into-memory
      # @return [Integer] the number of rows in the file, including empty new lines
      def size
        @size ||= `wc -l #{file_path}`.split[0].to_i + 1
      end

      # If the current position is at the header, skip it and return it. Otherwise, only return false.
      # @return [Boolean, Array] returns false, if header is already skipped, otherwise returns the header
      def skip_header
        start_of_file? ? (@header = read_row) : false
      end

      # Returns the header __without__ changing the position of the CSV
      # @return [Array, nil] the header
      def header
        return unless valid?
        return @header if @header
        @header = next_row
      end

      # Resets the file to the start of file
      def reset
        return false unless valid?

        @index = -1
        @current_row = @next_row = @skipped_rows = @next_skipped_rows = nil

        @ruby_csv.try(:close)
        @ruby_csv = _ruby_csv
        true
      end

      # @return [Boolean] true, if the current position is at the start of the file
      def start_of_file?
        index == -1
      end

      # @return [Boolean] true, if the current position is at the end of the file
      def end_of_file?
        index.nil?
      end

      # Returns the next row __without__ changing the position of the CSV
      # @return [Array, nil] the next row, or `nil` at the end of file
      def next_row
        @next_row ||= _read_row
      end

      # Returns the next row, while changing the position of the CSV
      # @return [Array, nil] the changed current row, or `nil` at the end of file
      def read_row
        return if end_of_file?

        @current_row = @next_row || _read_row
        @next_row = nil
        @index = current_row.nil? ? nil : @index + 1

        current_row
      end

      protected
      def _ruby_csv
        CSV.open(file_path)
      end

      def _read_row(ruby_csv=@ruby_csv)
        return unless valid?
        ruby_csv.readline
      rescue Exception => e
        return e
      end
    end
  end
end
