module CsvRowModel
  module ColumnShared
    #
    # row_model
    #
    def context
      row_model.context
    end

    #
    # row_model_class
    #
    def column_index
      row_model_class.index(column_name)
    end

    def options
      row_model_class.columns[column_name]
    end
  end
end