module CsvRowModel
  module CheckOptions
    extend ActiveSupport::Concern

    class_methods do
      def check_options(*klasses)
        options = klasses.extract_options!
        valid_options = klasses.map {|klass| klass.try(:valid_options) }.compact.flatten

        invalid_options = options.keys - valid_options
        raise ArgumentError.new("Invalid option(s): #{invalid_options}") if invalid_options.present?

        klasses.each { |klass| klass.try(:custom_check_options, options) }
        true
      end
    end
  end
end