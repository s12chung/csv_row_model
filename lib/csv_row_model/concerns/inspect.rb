module CsvRowModel
  module Concerns
    module Inspect
      def inspect
        s = self.class.send(:inspect_methods).map { |method| "#{method}=#{public_send(method).inspect}" }.join(", ")
        "#<#{self.class.name}:#{object_id} #{s}>"
      end
    end
  end
end