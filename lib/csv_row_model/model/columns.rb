module CsvRowModel
  module Model
    module Columns
      extend ActiveSupport::Concern

      # @return [Hash] a map of `column_name => public_send(column_name)`
      def attributes
        attributes_from_column_names self.class.column_names
      end

      def to_json
        attributes.to_json
      end

      def headers
        self.class.headers(context)
      end

      protected

      def attributes_from_column_names(column_names)
        hash_convert(column_names) { |column_name| public_send(column_name) }
      end

      private

      def hash_convert(column_names)
        column_names
          .zip(
            column_names.map { |column_name| yield(column_name) }
          ).to_h
      end

      class_methods do
        # @return [Array<Symbol>] column names for the row model
        def column_names
          columns.keys
        end

        # @return [Hash] column names mapped to their options
        def columns
          inherited_class_var(:@_columns, {}, :merge)
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

        # @param [Symbol] column_name name of column to check
        # @return [Boolean] true if it's a column name
        def is_column_name? column_name
          column_name.is_a?(Symbol) && index(column_name)
        end

        # @param [Hash, OpenStruct] context name of column to check
        # @return [Array] column headers for the row model
        def headers(context={})
          @headers ||= columns.map { |name, options| options[:header] || format_header(name) }
        end

        # Safe to override
        #
        # @return [String] formatted header
        def format_header(column_name)
          column_name
        end

        protected

        def merge_columns(column_hash)
          @_columns ||= {}
          deep_clear_class_cache(:@_columns)
          @_columns.merge!(column_hash)
        end

        VALID_OPTIONS_KEYS = %i[type parse validate_type default header header_matchs].freeze

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
          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          merge_columns(column_name.to_sym => options)
        end
        # alias_method :row, :column
      end
    end
  end
end
