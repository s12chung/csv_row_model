module CsvRowModel
  module Model
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        inherited_class_hash :dynamic_columns
      end

      # See Model::Columns#attributes
      def attributes
        super.merge(attributes_from_column_names(self.class.dynamic_column_names))
      end

      class_methods do
        # See Model::Columns::headers
        def headers(context={})
          super + dynamic_column_headers(context)
        end

        def dynamic_column_headers(context={})
          dynamic_column_names.map do |column_name|
            Array(OpenStruct.new(context).public_send(column_name)).each do |header_model|
              header_proc = dynamic_column_options(column_name)[:header] || ->(header_model) { header_model }
              instance_exec(header_model, &header_proc)
            end
          end.flatten
        end

        # @return [Integer] index of dynamic_column of all columns
        def dynamic_index(column_name)
          offset = dynamic_column_names.index(column_name)
          offset ? columns.size + offset : nil
        end

        def dynamic_column_options(column_name)
          dynamic_columns[column_name]
        end

        # @return [Array<Symbol>] column names for the row model
        def dynamic_column_names
          dynamic_columns.keys
        end

        def singular_dynamic_attribute_method_name(column_name)
          column_name.to_s.singularize
        end

        protected

        VALID_OPTIONS_KEYS = %i[header].freeze

        # define a dynamic_column, must be after all normal columns
        #
        # options to be implemented later
        #
        # @param column_name [Symbol] column_name
        def dynamic_column(column_name, options={})
          extra_keys = options.keys - VALID_OPTIONS_KEYS
          raise ArgumentError.new("invalid options #{extra_keys}") unless extra_keys.empty?

          merge_dynamic_columns(column_name.to_sym => options)
        end
      end
    end
  end
end
