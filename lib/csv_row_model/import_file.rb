module CsvRowModel
  class ImportFile
    extend ActiveSupport::Concern

    attr_reader :file, :row_model_class,
                :index, :current_row_model, :previous_row_model

    delegate :header, :size, to: :file

    def initialize(file_path, row_model_class)
      @file, @row_model_class = CsvFile.new(file_path), row_model_class
      reset
    end

    def reset
      file.reset
      @index = -1
      @current_row_model = nil
    end

    def next(context={})
      # skip header
      file.readline if file.index == -1

      file.readline

      if file.current_row.nil?
        @previous_row_model = current_row_model
        @current_row_model = nil
        @index = nil
      elsif current_row_model.try(:child?, file.current_row)
        # TODO: handle children
      else
        @previous_row_model = current_row_model
        @current_row_model = row_model_class.new(file.current_row, context: context, source_header: header, previous: previous_row_model)
        @index += 1
      end
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
  end
end