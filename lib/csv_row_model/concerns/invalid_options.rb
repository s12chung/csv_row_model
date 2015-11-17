module CsvRowModel
  module Concerns
    module InvalidOptions
      extend ActiveSupport::Concern

      class_methods do
        protected
        def check_and_merge_options(options, default_options)
          invalid_options = options.keys - default_options.keys
          raise ArgumentError.new("Invalid option(s): #{invalid_options}") if invalid_options.present?

          options.reverse_merge(default_options)
        end
      end
    end
  end
end