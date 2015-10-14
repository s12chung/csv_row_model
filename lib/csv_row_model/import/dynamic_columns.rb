module CsvRowModel
  module Import
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      # The dynamic source header is a collection of headers after regular columns,
      # only one dynamic column is supported
      def dynamic_source_headers
        source_header[self.class.columns.size..-1]
      end

      def dynamic_source_row
        source_row[self.class.columns.size..-1]
      end

      # @return [Hash] a map of `column_name => original_attribute(column_name)`
      def original_attributes
        super
        self.class.dynamic_column_names.each { |column_name| original_attribute(column_name) }
        @original_attributes
      end

      # @return [Object] the column's attribute before override
      def original_attribute(column_name)
        return super if self.class.column_names.include?(column_name)

        @original_attributes ||= {}.with_indifferent_access
        @default_changes     ||= {}.with_indifferent_access

        return @original_attributes[column_name] if @original_attributes.has_key? column_name

        values = dynamic_source_headers.map.with_index do |source_header, index|
          value = self.class.format_cell(
            dynamic_source_row[index],
            source_header,
            self.class.dynamic_index(column_name))
          public_send(column_name.to_s.singularize, value, source_header)
        end

        @original_attributes[column_name] = self.class.format_dynamic_column_cells(values, column_name)
      end

      class_methods do

        # Safe to override. Method applied to each cell by default
        #
        # @param cells [Array] Array of values
        # @param column_name [Symbol] Dynamic column name
        def format_dynamic_column_cells(cells, column_name)
          cells
        end

        protected

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_dynamic_attribute_method(column_name)
          define_method(column_name) { original_attribute(column_name) }
        end
      end

    end
  end
end
