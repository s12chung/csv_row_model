require 'csv_row_model/export/dynamic_columns'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    included do
      include DynamicColumns
      attr_reader :source_model, :context
      validates :source_model, presence: true

      self.column_names.each { |*args| define_attribute_method(*args) }
    end

    # @param [Model] source_model object to export to CSV
    # @param [Hash]  context
    def initialize(source_model, context={})
      @source_model = source_model
      @context      = OpenStruct.new(context)
    end

    def to_rows
      [to_row]
    end

    # @return [Array] an array of public_send(column_name) of the CSV model
    def to_row
      attributes.values
    end

    class_methods do
      # See {Model#column}
      def column(column_name, options={})
        super
        define_attribute_method(column_name)
      end

      def setup(csv, context={}, with_headers: true)
        csv << headers(context) if with_headers
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
