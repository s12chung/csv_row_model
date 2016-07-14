require 'csv_row_model/internal/model/header'

module CsvRowModel
  module Model
    module Attributes
      extend ActiveSupport::Concern
      included do
        inherited_class_hash :columns
      end

      # @return [Hash] a map of `column_name => public_send(column_name)`
      def attributes
        attributes_from_method_names self.class.column_names
      end

      def to_json
        attributes.to_json
      end

      def headers
        self.class.headers(context)
      end

      protected

      def attributes_from_method_names(column_names)
        array_to_block_hash(column_names) { |column_name| try(column_name) }
      end

      def array_to_block_hash(array, &block)
        array.zip(array.map { |column_name| block.call(column_name) }).to_h
      end

      class_methods do
        # @return [Array<Symbol>] column names for the row model
        def column_names
          columns.keys
        end

        # @param [Symbol] column_name name of column to find index
        # @return [Integer] index of the column_name
        def index(column_name)
          column_names.index column_name
        end

        # @param [Hash, OpenStruct] context name of column to check
        # @return [Array] column headers for the row model
        def headers(context={})
          column_names.map { |column_name| Header.new(column_name, self, context).value }
        end

        # Safe to override
        #
        # @return [String] formatted header
        def format_header(column_name, column_index, context)
          column_name
        end

        # Safe to override. Method applied to each cell by default
        #
        # @param cell [String] the cell's string
        # @param column_name [Symbol] the cell's column_name
        # @param column_index [Integer] the column_name's index
        def format_cell(cell, column_name, column_index, context)
          cell
        end

        protected

        VALID_OPTIONS_KEYS = %i[type parse validate_type default header].freeze

        # Adds column to the row model
        #
        # @param [Symbol] column_name name of column to add
        # @param options [Hash]
        #
        # @option options [class] :type class you want to automatically parse to (by default does nothing, equivalent to String)
        # @option options [Lambda, Proc] :parse for parsing the cell
        # @option options [Boolean] :validate_type adds a validations within a {::csv_string_model} call.
        # if true, it will add the default validation for the given :type (if applicable)
        #
        # @option options [Object] :default default value of the column if it is blank?, can pass Proc
        # @option options [String] :header human friendly string of the column name, by default format_header(column_name)
        # @option options [Hash] :header_matchs array with string to match cell to find in the row, by default column name
        def column(column_name, options={})
          column_name = column_name.to_sym

          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          merge_columns(column_name => options)
        end

        def merge_options(column_name, options={})
          column_name = column_name.to_sym
          column(column_name, options)
        end
      end
    end
  end
end
