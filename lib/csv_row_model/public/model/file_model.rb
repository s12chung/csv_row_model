module CsvRowModel
  module Model
    module FileModel
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :row_names, :column_names
          alias_method :rows, :columns
          alias_method :row, :column
        end
      end
    end
  end
end