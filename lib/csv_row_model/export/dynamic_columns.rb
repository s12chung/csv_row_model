module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each { |*args| define_dynamic_attribute_method(*args) }
      end

      class_methods do
        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        # @param index [Integer] the index's column_name
        def define_dynamic_attribute_method(column_name)

          # Safe to override
          #
          #
          # @return [String] a string of public_send(column_name) of the CSV model
          define_method(column_name) do
            context.public_send(column_name).map do |header_model|
              self.class.format_cell(
                public_send(column_name.to_s.singularize, header_model),
                column_name,
                self.class.dynamic_index(column_name)
              )
            end
          end
        end
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        super.flatten
      end
    end
  end
end
