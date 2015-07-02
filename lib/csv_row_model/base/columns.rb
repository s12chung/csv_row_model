module CsvRowModel
  module Base
    module Columns
      extend ActiveSupport::Concern

      module ClassMethods
        def column_names
          self == included_csv_model_class ? (@column_names ||= []) : included_csv_model_class.column_names
        end

        private
        def column(column_name)
          column_names << column_name
        end
      end
    end
  end
end