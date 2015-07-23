module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      # @return [Hash] a map of `column_name => public_send(column_name)`
      def attributes
        self.class.column_names
          .zip(self.class.column_names.map { |column_name| public_send(column_name) })
          .to_h
      end

      def to_json
        attributes.to_json
      end

      class_methods do
        # @return [Array] column names for the row model
        def column_names
          columns.keys
        end

        # @return [Hash] column names mapped to their options
        def columns
          deep_class_var(:@_columns, {}, :merge, Model)
        end

        # @param [Symbol] column_name name of column to find option
        # @return [Hash] options for the column_name
        def options(column_name)
          columns[column_name]
        end

        # @param [Symbol] column_name name of column to find index
        # @return [Integer] index of the column_name
        def index(column_name)
          column_names.index column_name
        end

        protected

        def _columns
          @_columns ||= {}
        end

        # Adds column to the row model
        #
        # @param [Symbol] column_name name of column to add
        # @param options [Hash]
        # @option options [Hash] :type class you want to automatically parse to (by default does nothing, equivalent to String)
        # @option options [Hash] :parse a Proc for parsing the cell
        # @option options [Hash] :default default value of the column if it is blank?, can pass Proc
        # @option options [Hash] :header human friendly string of the column name, by default header_format(column_name)
        def column(column_name, options={})
          _columns.merge!(column_name => options)
        end
      end
    end
  end
end