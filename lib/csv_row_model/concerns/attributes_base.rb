require 'csv_row_model/concerns/model/attributes'
require 'csv_row_model/concerns/hidden_module'

# Shared between Import and Export, see test fixture for basic setup
module CsvRowModel
  module AttributesBase
    extend ActiveSupport::Concern
    include Model::Attributes
    include HiddenModule

    # @return [Hash] a map of `column_name => public_send(column_name)`
    def attributes
      attributes_from_method_names self.class.column_names
    end

    # @return [Hash] a map of `column_name => original_attribute(column_name)`
    def original_attributes
      array_to_block_hash(self.class.column_names) { |column_name| original_attribute(column_name) }
    end

    # @return [Object] the column's attribute before override
    def original_attribute(column_name)
      attribute_objects[column_name].try(:value)
    end

    # @return [Hash] a map of `column_name => format_cell(column_name, ...)`
    def formatted_attributes
      array_to_block_hash(self.class.column_names) { |column_name| attribute_objects[column_name].formatted_value }
    end

    # @return [Hash] a map of `column_name => source (source_row[index_of_column_name] or row_model.public_send(column_name)) `
    def source_attributes
      array_to_block_hash(self.class.column_names) { |column_name| attribute_objects[column_name].source_value }
    end

    def to_json
      attributes.to_json
    end

    def eql?(other)
      other.try(:attributes) == attributes
    end

    def hash
      attributes.hash
    end

    protected
    def attributes_from_method_names(column_names)
      array_to_block_hash(column_names) { |column_name| try(column_name) }
    end

    def array_to_block_hash(array, &block)
      array.zip(array.map(&block)).to_h
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
      def define_attribute_method(column_name, &block)
        return if method_defined? column_name
        define_proxy_method(column_name, &block)
      end

      def ensure_attribute_method
        self.column_names.each { |*args| define_attribute_method(*args) }
      end
    end
  end
end