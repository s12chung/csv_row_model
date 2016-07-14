module CsvRowModel
  module CheckOptions
    extend ActiveSupport::Concern

    class_methods do
      def check_options(options)
        invalid_options = options.keys - self::VALID_OPTIONS
        raise ArgumentError.new("Invalid option(s): #{invalid_options}") if invalid_options.present?
        true
      end
    end
  end
end