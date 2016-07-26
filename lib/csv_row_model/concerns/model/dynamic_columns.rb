require 'csv_row_model/internal/model/dynamic_column_header'

module CsvRowModel
  module Model
    module DynamicColumns
      extend ActiveSupport::Concern
      include InheritedClassVar

      included do
        inherited_class_hash :dynamic_columns
      end

      class_methods do
        def dynamic_columns?
          dynamic_columns.present?
        end

        # @return [Integer] index of dynamic_column of all columns
        def dynamic_column_index(column_name)
          offset = dynamic_column_names.index(column_name)
          offset ? columns.size + offset : nil
        end

        # @return [Array<Symbol>] column names for the row model
        def dynamic_column_names
          dynamic_columns.keys
        end

        # See Model::Columns::headers
        def headers(context={})
          super + dynamic_column_headers(context)
        end

        def dynamic_column_headers(context={})
          dynamic_column_names.map { |column_name| DynamicColumnHeader.new(column_name, self, context).value }.flatten
        end

        # Safe to override. Method applied to each dynamic_column attribute
        #
        # @param cells [Array] Array of values
        # @param column_name [Symbol] Dynamic column name
        def format_dynamic_column_cells(cells, column_name, column_index, context)
          cells
        end

        # Safe to override
        #
        # @return [String] formatted header
        def format_dynamic_column_header(header_model, column_name, dynamic_column_index, context)
          header_model
        end

        protected

        VALID_OPTIONS_KEYS = %i[header header_models_context_key].freeze

        # define a dynamic_column, must be after all normal columns
        #
        # @param column_name [Symbol] column_name
        # @option options [String] :header human friendly string of the column name, by default format_header(column_name)
        def dynamic_column(column_name, options={})
          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          dynamic_columns_object.merge(column_name.to_sym => options)
        end
      end
    end
  end
end
