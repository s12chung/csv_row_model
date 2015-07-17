module CsvRowModel
  module Import
    class Csv
      attr_reader :path,
                  :index, # = -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
                  :current_row

      include ActiveModel::Validations

      validate :_file

      def initialize(path)
        @path = path
        reset
      end

      def skip_header
        start_of_file? ? (@header = readline) : false
      end

      def header
        return @header if @header

        file = _file
        @header = file.readline
        file.close
        @header
      end

      def reset
        @index = -1
        @current_row = nil
      end

      # http://stackoverflow.com/questions/2650517/count-the-number-of-lines-in-a-file-without-reading-entire-file-into-memory
      def size
        @size ||= `wc -l #{path}`.split[0].to_i
      end

      def readline
        if @next_line
          @current_row = @next_line
          @next_line = nil
        else
          @current_row = _readline
        end
        current_row.nil? ? set_end_of_file : @index += 1
        current_row
      end

      def start_of_file?
        index == -1
      end

      def end_of_file?
        index.nil?
      end

      def next_line
        @next_line ||= file.readline
      end

      protected

      def _file
        CSV.open(path)
      rescue => e
        errors.add(:file, e.message)
      end

      def _readline
        file.readline
      rescue => e
        errors.add(:file, e.message)
      end

      def file
        return @file unless start_of_file?
        @file = _file
      end

      def set_end_of_file
        @current_row = @index = nil
      end
    end
  end
end
