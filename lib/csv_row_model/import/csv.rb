module CsvRowModel
  module Import
    # Abstraction of Ruby's CSV library. Keeps current row and line_number, skips empty rows, handles errors.
    class Csv
      # @return [String] the file path of the CSV
      attr_reader :file_path
      # @return [Integer, nil] return `0` at start of file, `1 to infinity` is line_number of row_model, `nil` is end of file (row is also `nil`)
      attr_reader :line_number
      # @return [Array, nil] the current row, or nil at the beginning or end of file
      attr_reader :current_row

      include ActiveModel::Validations

      validate { begin; _ruby_csv; rescue => e; errors.add(:csv, e.message) end }

      def initialize(file_path)
        @file_path = file_path
        reset
      end

      # http://stackoverflow.com/questions/2650517/count-the-number-of-lines-in-a-file-without-reading-entire-file-into-memory
      # @return [Integer] the number of rows in the file, including empty new lines
      def size
        @size ||= `wc -l #{file_path}`.split[0].to_i + 1
      end

      # If the current position is at the headers, skip it and return it. Otherwise, only return false.
      # @return [Boolean, Array] returns false, if header is already skipped, otherwise returns the header
      def skip_headers
        start_of_file? ? (@headers = read_row) : false
      end

      # Returns the header __without__ changing the position of the CSV
      # @return [Array, nil] the header
      def headers
        @headers ||= next_row
      end

      # Resets the file to the start of file
      def reset
        return false unless valid?

        @line_number = 0
        @headers = @current_row = @next_row = @skipped_rows = @next_skipped_rows = nil

        @ruby_csv.try(:close)
        @ruby_csv = _ruby_csv
        true
      end

      # @return [Boolean] true, if the current position is at the start of the file
      def start_of_file?
        line_number == 0
      end

      # @return [Boolean] true, if the current position is at the end of the file
      def end_of_file?
        line_number.nil?
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
        @line_number = current_row.nil? ? nil : @line_number + 1
        @next_row = nil

        current_row
      end

      protected
      def _ruby_csv
        CSV.open(file_path)
      end

      def _read_row
        return unless valid?
        @ruby_csv.readline.tap { |row| @headers ||= row }
      rescue Exception => e
        changed = e.exception(e.message.gsub(/line \d+\.?/, "line #{line_number + 1}.")) # line numbers are usually off
        changed.set_backtrace(e.backtrace)
        changed
      end
    end
  end
end
