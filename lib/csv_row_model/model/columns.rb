module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      included do
        include Base
      end

      def attributes
        attributes = self.class.column_names
          .zip(self.class.column_names.map { |column_name| public_send(column_name) })
          .to_h
        attributes.merge!(class: self.class.to_s)
        attributes
      end

      module ClassMethods
        def column_names
          memoized_class_included_var :column_names, [], Model
        end

        protected
        def column(column_name)
          column_names << column_name
        end
      end
    end
  end
end