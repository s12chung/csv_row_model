module CsvRowModel
  module Export
    module DynamicColumns
      extend ActiveSupport::Concern

      included do
        self.dynamic_column_names.each do |column_name|

          # Safe to override
          #
          #
          # @return [String] a string of public_send(column_name) of the CSV model
          define_method(column_name) do
            context.public_send(column_name).map do |header_model|
              public_send(column_name.to_s.singularize, header_model)
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