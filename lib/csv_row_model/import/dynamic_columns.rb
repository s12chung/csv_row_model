module CsvRowModel
  module Import
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      def dynamic_source_headers
        source_header[self.class.columns.size..-1]
      end

      def dynamic_source_row
        source_row[self.class.columns.size..-1]
      end

      class_methods do
        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_dynamic_attribute_method(column_name)
          define_method("__#{column_name}") do
            dynamic_source_headers.map.with_index do |source_header, index|
              public_send(column_name.to_s.singularize, dynamic_source_row[index], source_header)
            end
          end

          define_method(column_name) { public_send("__#{column_name}") }
        end
      end
    end
  end
end