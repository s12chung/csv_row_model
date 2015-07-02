module CsvRowModel
  class ImportFile
    extend ActiveSupport::Concern

    attr_reader :file, :row_model_class,
                :index, # = -1 = start of file, 0 to infinity = index of row_model, nil = end of file, no row_model
                :current_row_model, :previous_row_model

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
      file.skip_header

      next_line_is_parent_row = true
      loop do
        @previous_row_model = current_row_model if next_line_is_parent_row

        file.readline
        return set_end_of_file if file.end_of_file?

        set_current_row_model(context) if next_line_is_parent_row

        next_line_is_parent_row = !current_row_model.append_child(file.next_line)
        return current_row_model if next_line_is_parent_row
      end
    end

    def end_of_file?
      Import::StateHelpers.and index.nil?, current_row_model.nil? && file.end_of_file?
    end

    def each(context={})
      return false unless valid?

      while self.next(context)
        # TODO: collect row_model errors
        return false if current_row_model.abort?
        next if current_row_model.skip?

        yield current_row_model, file.index
      end
    end

    # TODO: check valid file or abort
    def valid?
      true
    end

    private
    def set_current_row_model(context)
      @current_row_model = row_model_class.new(file.current_row, context: context, source_header: header, previous: previous_row_model)
      @index += 1
    end

    def set_end_of_file
      # please return nil
      @current_row_model = @index = nil
    end
  end
end