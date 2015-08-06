require 'csv_row_model/validators/boolean_format'

module CsvRowModel
  module Import
    module Attributes
      extend ActiveSupport::Concern
      # Classes with a validations associated with them in csv_row_model/validators
      PARSE_VALIDATION_CLASSES = [Boolean, Integer, Float, Date].freeze

      # Mapping of column type classes to a parsing lambda. These are applied after {Import.format_cell}.
      # Can pass custom Proc with :parse option.
      CLASS_TO_PARSE_LAMBDA = {
        nil => ->(s) { s },
        Boolean => ->(s) { s =~ BooleanFormatValidator::FALSE_BOOLEAN_REGEX ? false : true },
        String  => ->(s) { s },
        Integer => ->(s) { s.to_i },
        Float   => ->(s) { s.to_f },
        Date    => ->(s) { s.present? ? Date.parse(s) : s }
      }.freeze

      # @return [Hash] a map of `column_name => original_attribute(column_name)`
      def original_attributes
        @original_attributes ||= begin
          values = self.class.column_names.map { |column_name| original_attribute(column_name) }
          self.class.column_names.zip(values).to_h
        end
      end

      # @return [Object] the column's attribute before override
      def original_attribute(column_name)
        @default_changes ||= {}
        value = self.class.format_cell(mapped_row[column_name], column_name, self.class.index(column_name))

        csv_string_model.valid?
        if value.present? && csv_string_model.errors[column_name].blank?
          instance_exec(value, &self.class.parse_lambda(column_name))
        elsif self.class.options(column_name)[:default]
          original_value = value
          value = instance_exec(value, &self.class.default_lambda(column_name))
          @default_changes[column_name] = [original_value, value]
          value
        end
      end

      # return [Hash] a map changes from {.column}'s default option': `column_name -> [value_before_default, default_set]`
      def default_changes
        original_attributes
        @default_changes
      end

      class_methods do
        # Safe to override. Method applied to each cell by default
        #
        # @param cell [String] the cell's string
        # @param column_name [Symbol] the cell's column_name
        # @param column_index [Integer] the column_name's index
        def format_cell(cell, column_name, column_index)
          cell
        end

        # @return [Lambda] returns a Lambda: ->(original_value) { default_exists? ? default : original_value }
        def default_lambda(column_name)
          default = options(column_name)[:default]
          default.is_a?(Proc) ? ->(s) { instance_exec(&default) } : ->(s) { default.nil? ? s : default }
        end

        # @return [Lambda, Proc] returns the Lambda/Proc given in the parse option or:
        # ->(original_value) { parse_proc_exists? ? parsed_value : original_value  }
        def parse_lambda(column_name)
          options = options(column_name)

          raise ArgumentError.new("You need either :parse OR :type but not both of them") if options[:parse] && options[:type]

          parse_lambda = options[:parse] || CLASS_TO_PARSE_LAMBDA[options[:type]]
          return parse_lambda if parse_lambda
          raise ArgumentError.new("type must be #{CLASS_TO_PARSE_LAMBDA.keys.reject(:nil?).join(", ")}")
        end

        protected
        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_attribute_method(column_name)
          add_type_validation(column_name)
          define_method(column_name) { original_attribute(column_name) }
        end

        # Adds the type validation based on :validate_type option
        def add_type_validation(column_name)
          options = options(column_name)
          validate_type = options[:validate_type]

          return unless validate_type

          type = options[:type]
          raise ArgumentError.new("invalid :type given for :validate_type for column") unless PARSE_VALIDATION_CLASSES.include? type
          validate_type = Proc.new { validates column_name, "#{type.name.underscore}_format".to_sym => true, allow_blank: true }

          csv_string_model(&validate_type)
        end
      end
    end
  end
end