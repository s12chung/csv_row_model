module CsvRowModel
  module Import
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      # @return [Array] dynamic_column headers
      def dynamic_source_headers
        self.class.dynamic_source_headers source_header
      end

      # @return [Array] dynamic_column row data
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
        return super if self.class.column_names.include? column_name
        return unless self.class.dynamic_column_names.include? column_name
        return @original_attributes[column_name] if original_attribute_memoized? column_name

        values = dynamic_source_headers.map.with_index do |source_header, index|
          value = self.class.format_cell(
            dynamic_source_row[index],
            source_header,
            self.class.dynamic_index(column_name),
            context
          )
          public_send(self.class.singular_dynamic_attribute_method_name(column_name), value, source_header)
        end

        @original_attributes[column_name] = self.class.format_dynamic_column_cells(values, column_name)
      end

      class_methods do
        # Safe to override. Method applied to each dynamic_column attribute
        #
        # @param cells [Array] Array of values
        # @param column_name [Symbol] Dynamic column name
        def format_dynamic_column_cells(cells, column_name)
          cells
        end
        # @return [Array] dynamic_column headers
        def dynamic_source_headers(source_header)
          source_header[columns.size..-1]
        end

        protected

        # See {Model#dynamic_column}
        def dynamic_column(column_name, options={})
          super
          define_dynamic_attribute_method(column_name)
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_dynamic_attribute_method(column_name)
          define_method(column_name) { original_attribute(column_name) }
          define_method(singular_dynamic_attribute_method_name(column_name)) { |value, source_header| value }
        end
      end
    end
  end
end
