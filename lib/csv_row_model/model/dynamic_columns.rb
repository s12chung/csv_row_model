module CsvRowModel
  module Model
    module DynamicColumns
      extend ActiveSupport::Concern

      # See Model::Columns#attributes
      def attributes
        super.merge(attributes_from_column_names(self.class.dynamic_column_names))
      end

      # See Model::Columns#formatted_attributes
      def formatted_attributes
        super.merge(formatted_attributes_from_column_names(self.class.dynamic_column_names))
      end

      class_methods do
        # See Model::Columns::headers
        def headers(context={})
          @headers ||= super + dynamic_column_names.map do |column_name|
            OpenStruct.new(context).public_send(column_name).each do |header_model|
              public_send(header_method_name(column_name), header_model)
            end
          end.flatten
        end

        # @return [Integer] index of dynamic_column of all columns
        def dynamic_index(column_name)
          offset = dynamic_column_names.index(column_name)
          offset ? columns.size + offset : nil
        end

        # @return [Array<Symbol>] column names for the row model
        def dynamic_column_names
          dynamic_columns.keys
        end

        # @return [Hash] column names mapped to their options
        def dynamic_columns
          inherited_class_var(:@_dynamic_columns, {}, :merge)
        end

        def header_method_name(column_name)
          "#{column_name.to_s.singularize}_header"
        end
        def singular_dynamic_attribute_method_name(column_name)
          column_name.to_s.singularize
        end

        protected

        def merge_dynamic_columns(column_hash)
          @_dynamic_columns ||= {}
          deep_clear_class_cache(:@_dynamic_columns)
          @_dynamic_columns.merge!(column_hash)
        end

        VALID_OPTIONS_KEYS = [].freeze

        # define a dynamic_column, must be after all normal columns
        #
        # options to be implemented later
        #
        # @param column_name [Symbol] column_name
        def dynamic_column(column_name, options={})
          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          define_header_method(column_name)

          merge_dynamic_columns(column_name.to_sym => options)
        end

        def define_header_method(column_name)
          define_singleton_method(header_method_name(column_name)) { |header_model| header_model }
        end
      end
    end
  end
end
