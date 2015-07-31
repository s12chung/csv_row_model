module CsvRowModel
  module Concerns
    module Inspect
      def inspect
        s = self.class.inspect_instance_variables.map { |v| "#{v}=#{instance_variable_get(v).inspect}" }.join(", ")
        "#<#{self.class.name}:#{object_id} #{s}>"
      end
    end
  end
end