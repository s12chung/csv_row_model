module CsvRowModel
  class CsvFile
    attr_reader :path,
                :index, # = -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
                :current_row

    def initialize(path)
      @path = path
      reset
    end

    def skip_header
      index == -1 ? (@header ||= readline) : false
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
        @current_row = file.readline
      end

      current_row.nil? ? set_end_of_file : @index += 1

      current_row
    end

    def end_of_file?
      Import::StateHelpers.and index.nil?, current_row.nil?
    end

    def next_line
      @next_line ||= file.readline
    end

    private
    def _file
      CSV.open(path)
    end

    def file
      return @file unless index == -1
      @file = _file
    end

    def set_end_of_file
      @current_row = @index = nil
    end
  end
end