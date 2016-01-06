module CsvRowModel
  module Model
    module Comparison
      extend ActiveSupport::Concern

      def eql?(other)
        other.attributes == attributes
      end

      def hash
        attributes.hash
      end
    end
  end
end
