module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      module ClassMethods
        def column_names
          self == class_included ? (@column_names ||= []) : class_included.column_names
        end

        private
        def column(column_name)
          column_names << column_name
        end
      end
    end
  end
end