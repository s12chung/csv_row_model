require 'csv_row_model/concerns/attributes_base'
require 'csv_row_model/internal/export/attribute'

module CsvRowModel
  module Export
    module Attributes
      extend ActiveSupport::Concern
      include AttributesBase

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      def attribute_objects
        @attribute_objects ||= array_to_block_hash(self.class.column_names) { |column_name| Attribute.new(column_name, self) }
      end

      class_methods do
        protected
        def define_attribute_method(column_name)
          super { source_model.public_send(column_name) }
        end
      end
    end
  end
end
