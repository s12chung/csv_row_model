module CsvRowModel
  module Export
    module Attributes
      extend ActiveSupport::Concern

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      class_methods do

        # See {Model#column}
        def column(column_name, options={})
          super
          define_attribute_method(column_name)
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_attribute_method(column_name)
          define_method(column_name) do
            self.class.format_cell(source_model.public_send(column_name), column_name, self.class.index(column_name))
          end
        end

        # Safe to override. Method applied to each cell by default
        #
        # @param cell [Object] the cell's value
        def format_cell(cell, column_name, column_index)
          cell
        end
      end
    end
  end
end
