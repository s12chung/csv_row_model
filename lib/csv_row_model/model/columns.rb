module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      def attributes
        attributes = self.class.column_names
          .zip(self.class.column_names.map { |column_name| public_send(column_name) })
          .to_h
        attributes.merge!(class: self.class.to_s)
        attributes
      end

      def to_json
        attributes.to_json
      end

      class_methods do
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