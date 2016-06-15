module CsvRowModel
  module Export
    module Base
      extend ActiveSupport::Concern

      included do
        attr_reader :source_model
        validates :source_model, presence: true
      end

      # @param [Model] source_model object to export to CSV
      # @param [Hash]  context
      def initialize(source_model=nil, context={})
        @source_model = source_model
        super(context: context)
      end

      def to_rows
        [to_row]
      end

      # @return [Array] an array of public_send(column_name) of the CSV model
      def to_row
        formatted_attributes.values
      end

      class_methods do
        def setup(csv, context={}, with_headers: true)
          csv << headers(context) if with_headers
        end
      end
    end
  end
end