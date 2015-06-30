module CsvRowModel
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      private

      def column(column_name)
        @columns ||= []
        @columns << column_name
      end
    end
  end
end