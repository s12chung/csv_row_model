require 'csv_row_model/validators/boolean_format'

module CsvRowModel
  module Import
    class Cell
      attr_reader :column_name, :source_value, :csv_string_model_errors, :row_model

      def initialize(column_name, source_value, csv_string_model_errors, row_model)
        @column_name = column_name
        @source_value = source_value
        @csv_string_model_errors = csv_string_model_errors
        @row_model = row_model
      end

      def value
        @value ||= begin
          return unless csv_string_model_errors.blank?
          default? ? default_value : parsed_value
        end
      end

      def formatted_value
        @formatted_value ||= row_model.class.format_cell(source_value, column_name, row_model.class.index(column_name), row_model.context)
      end

      def parsed_value
        @parsed_value ||= begin
          value = formatted_value
          value.present? ? row_model.instance_exec(formatted_value, &parse_lambda) : value
        end
      end

      def default_value
        @default_value ||= begin
          default = options[:default]
          default.is_a?(Proc) ? row_model.instance_exec(&default) : default
        end
      end

      def default?
        !!options[:default] && formatted_value.blank?
      end

      def default_change
        [formatted_value, default_value] if default?
      end

      def options
        row_model.class.columns[column_name]
      end

      protected

      # Mapping of column type classes to a parsing lambda. These are applied after {Import.format_cell}.
      # Can pass custom Proc with :parse option.
      CLASS_TO_PARSE_LAMBDA = {
        nil      => ->(s) { s }, # no type given
        Boolean  => ->(s) { s =~ BooleanFormatValidator::FALSE_BOOLEAN_REGEX ? false : true },
        String   => ->(s) { s },
        Integer  => ->(s) { s.to_i },
        Float    => ->(s) { s.to_f },
        DateTime => ->(s) { s.present? ? DateTime.parse(s) : s },
        Date     => ->(s) { s.present? ? Date.parse(s) : s }
      }.freeze

      # @return [Lambda, Proc] returns the Lambda/Proc given in the parse option or:
      # ->(source_value) { parse_proc_exists? ? parsed_value : source_value  }
      def parse_lambda
        raise ArgumentError.new("Use :parse OR :type option, but not both for: #{column_name}") if options[:parse] && options[:type]

        parse_lambda = options[:parse] || CLASS_TO_PARSE_LAMBDA[options[:type]]
        return parse_lambda if parse_lambda
        raise ArgumentError.new("type must be #{CLASS_TO_PARSE_LAMBDA.keys.reject(:nil?).join(", ")} for: #{column_name}")
      end
    end
  end
end