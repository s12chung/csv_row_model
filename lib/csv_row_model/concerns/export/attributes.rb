require 'csv_row_model/internal/export/attribute'

module CsvRowModel
  module Export
    module Attributes
      extend ActiveSupport::Concern

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      def attribute_objects
        @attribute_objects ||= array_to_block_hash(self.class.column_names) { |column_name| Attribute.new(column_name, self) }
      end

      # @return [Hash] a map of `column_name => formatted_attributes`
      def formatted_attributes
        array_to_block_hash(self.class.column_names) { |column_name| formatted_attribute(column_name) }
      end

      def formatted_attribute(column_name)
        attribute_objects[column_name].try(:value)
      end

      def source_attribute(column_name)
        attribute_objects[column_name].try(:source_value)
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
          define_proxy_method(column_name) { source_model.public_send(column_name) }
        end
      end
    end
  end
end
