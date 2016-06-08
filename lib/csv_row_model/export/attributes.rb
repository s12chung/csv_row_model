module CsvRowModel
  module Export
    module Attributes
      extend ActiveSupport::Concern

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      # @return [Hash] a map of `column_name => self.class.format_cell(public_send(column_name))`
      def formatted_attributes
        formatted_attributes_from_column_names self.class.column_names
      end

      def formatted_attribute(column_name)
        return public_send(column_name) if self.class.is_dynamic_column?(column_name)

        self.class.format_cell(
          public_send(column_name),
          column_name,
          self.class.index(column_name),
          context
        )
      end

      protected
      def formatted_attributes_from_column_names(column_names)
        array_to_block_hash(column_names) { |column_name| formatted_attribute(column_name) }
      end

      class_methods do
        protected
        # See {Model#column}
        def column(column_name, options={})
          super
          define_attribute_method(column_name)
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_attribute_method(column_name)
          return if method_defined? column_name
          define_method(column_name) { source_model.public_send(column_name) }
        end
      end
    end
  end
end
