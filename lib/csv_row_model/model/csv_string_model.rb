module CsvRowModel
  module Model
    class CsvStringModel
      include ActiveWarnings

      def initialize(source)
        @source = source.symbolize_keys
      end

      def method_missing(name, *args, &block)
        return super unless @source.keys.include? name
        @source[name]
      end
    end
  end
end