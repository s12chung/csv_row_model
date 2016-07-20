require 'csv_row_model/concerns/dynamic_columns_base'
require 'csv_row_model/concerns/export/attributes'
require 'csv_row_model/internal/export/dynamic_column_attribute'

module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern
      include DynamicColumnsBase

      included do
        ensure_define_dynamic_attribute_method
      end

      def dynamic_column_attribute_objects
        @dynamic_column_attribute_objects ||= array_to_block_hash(self.class.dynamic_column_names) do |column_name|
          self.class.dynamic_attribute_class.new(column_name, self)
        end
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        super.flatten
      end

      class_methods do
        def dynamic_attribute_class
          DynamicColumnAttribute
        end
      end
    end
  end
end
