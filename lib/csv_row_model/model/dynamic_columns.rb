module CsvRowModel
  module Model
    module DynamicColumns
      extend ActiveSupport::Concern
      def attributes
        super.merge(attributes_from_column_names(self.class.dynamic_column_names))
      end

      class_methods do
        def dynamic_columns_headers(context={})
          dynamic_column_names.map do |column_name|
            OpenStruct.new(context).public_send(column_name).each do |header_model|
              public_send("#{column_name.to_s.singularize}_header", header_model)
            end
          end.flatten
        end

        VALID_OPTIONS_KEYS = %i[request]
        # @return [Array<Symbol>] column names for the row model
        def dynamic_column_names
          dynamic_columns.keys
        end

        # @return [Hash] column names mapped to their options
        def dynamic_columns
          inherited_class_var(:@_dynamic_columns, {}, :merge)
        end

        protected

        def merge_dynamic_columns(column_hash)
          @_dynamic_columns ||= {}
          deep_clear_class_cache(:@_dynamic_columns)
          @_dynamic_columns.merge!(column_hash)
        end

        def dynamic_column(column_name, options={})
          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          merge_dynamic_columns(column_name.to_sym => options)
        end
      end
    end
  end
end