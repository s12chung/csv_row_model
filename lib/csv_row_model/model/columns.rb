module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      # @return [Hash] a map of `column_name => public_send(column_name)`
      def attributes
        attributes = self.class.column_names
          .zip(self.class.column_names.map { |column_name| public_send(column_name) })
          .to_h
        attributes
      end

      def to_json
        attributes.to_json
      end

      class_methods do
        # @return [Array] column names for the row model
        def column_names
          memoized_class_included_var :column_names, [], Model
        end

        protected
        # Adds column to the row model
        #
        # @param [Symbol] column_name name of column to add
        def column(column_name)
          column_names << column_name
        end
      end
    end
  end
end