module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        super.flatten
      end

      # See Model::Columns#formatted_attributes
      def formatted_attributes
        super.merge(formatted_attributes_from_column_names(self.class.dynamic_column_names))
      end

      class_methods do
        protected

        # See {Model::DynamicColumns#dynamic_column}
        def dynamic_column(column_name, options={})
          super
          define_dynamic_attribute_method(column_name)
        end

        # Define default attribute method for a dynamic_column
        # @param column_name [Symbol] the cell's column_name
        def define_dynamic_attribute_method(column_name)
          define_method(column_name) do
            context.public_send(column_name).map do |header_model|
              self.class.format_cell(
                public_send(self.class.singular_dynamic_attribute_method_name(column_name), header_model),
                column_name,
                self.class.dynamic_index(column_name),
                context
              )
            end
          end

          define_method(singular_dynamic_attribute_method_name(column_name)) { |header_model| header_model }
        end
      end
    end
  end
end
