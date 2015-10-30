require 'csv_row_model/export/dynamic_columns'
require 'csv_row_model/export/attributes'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    included do
      include DynamicColumns
      attr_reader :source_model, :context
      include Attributes
      validates :source_model, presence: true
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
      def setup(csv, context={}, with_headers: true)
        csv << headers(context) if with_headers
      end
    end
  end
end
