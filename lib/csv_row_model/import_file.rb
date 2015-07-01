module CsvRowModel
  class ImportFile
    extend ActiveSupport::Concern

    attr_reader :file_path, :row_model_class,
                :index, :current_row_model, :previous_row_model,
                :file_index, :current_row

    def initialize(file_path, row_model_class)
      @file_path, @row_model_class = file_path, row_model_class
      reset
    end

    def file
      return @file unless file_index == -1
      @file = _file
    end

    def reset
      @index = @file_index = -1
      @current_row_model = @current_row = nil
    end

    def next(context={})
      # skip header
      readline if file_index == -1

      readline

      if current_row.nil?
        @previous_row_model = current_row_model
        @current_row_model = nil
        @index = nil
      elsif current_row_model.try(:child?, current_row)
        # TODO: handle children
      else
        @previous_row_model = current_row_model
        @current_row_model = row_model_class.new(current_row, context: context, source_header: header, previous: previous_row_model)
        @index += 1
      end
    end

    def header
      return @header if @header

      file = _file
      @header = file.readline
      file.close
      @header
    end

    def each(context={})
      return false unless valid?

      while self.next(context)
        # TODO: collect row_model errors
        return false if current_row_model.abort?
        next if current_row_model.skip?

        yield current_row_model, index
      end
    end

    # TODO: check valid file or abort
    def valid?
      true
    end

    private
    def _file
      CSV.open(file_path)
    end

    def readline
      @current_row = file.readline
      current_row.nil? ? @file_index = nil : @file_index += 1
      current_row
    end
  end
end