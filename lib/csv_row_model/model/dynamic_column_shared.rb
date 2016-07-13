module CsvRowModel
  module Model
    module DynamicColumnShared
      def header_models
        Array(context.public_send(header_models_context_key))
      end

      def header_models_context_key
        options[:header_models_context_key] || column_name
      end
    end
  end
end