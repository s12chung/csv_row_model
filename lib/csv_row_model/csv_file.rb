module CsvRowModel
  class CsvFile
    attr_reader :path, :index, :current_row

    def initialize(path)
      @path = path
      reset
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
      @current_row = file.readline
      current_row.nil? ? @index = nil : @index += 1
      current_row
    end

    private
    def _file
      CSV.open(path)
    end

    def file
      return @file unless index == -1
      @file = _file
    end
  end
end