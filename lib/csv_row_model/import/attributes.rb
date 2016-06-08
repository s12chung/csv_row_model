require 'csv_row_model/validators/boolean_format'

module CsvRowModel
  module Import
    module Attributes
      extend ActiveSupport::Concern

      included do
        self.column_names.each { |*args| define_attribute_method(*args) }
      end

      # Mapping of column type classes to a parsing lambda. These are applied after {Import.format_cell}.
      # Can pass custom Proc with :parse option.
      CLASS_TO_PARSE_LAMBDA = {
        nil      => ->(s) { s },
        Boolean  => ->(s) { s =~ BooleanFormatValidator::FALSE_BOOLEAN_REGEX ? false : true },
        String   => ->(s) { s },
        Integer  => ->(s) { s.to_i },
        Float    => ->(s) { s.to_f },
        DateTime => ->(s) { s.present? ? DateTime.parse(s) : s },
        Date     => ->(s) { s.present? ? Date.parse(s) : s }
      }.freeze

      # @return [Hash] a map of `column_name => original_attribute(column_name)`
      def original_attributes
        self.class.column_names.each { |column_name| original_attribute(column_name) }
        @original_attributes
      end

      # @return [Object] the column's attribute before override
      def original_attribute(column_name)
        return @original_attributes[column_name] if original_attribute_memoized? column_name

        csv_string_model.valid?
        return nil unless csv_string_model.errors[column_name].blank?

        value = self.class.format_cell(mapped_row[column_name], column_name, self.class.index(column_name), context)
        if value.present?
          value = instance_exec(value, &self.class.parse_lambda(column_name))
        elsif self.class.options(column_name)[:default]
          original_value = value
          value = instance_exec(value, &self.class.default_lambda(column_name))
          @default_changes[column_name] = [original_value, value]
        end
        @original_attributes[column_name] = value
      end

      # return [Hash] a map changes from {.column}'s default option': `column_name -> [value_before_default, default_set]`
      def default_changes
        original_attributes
        @default_changes
      end

      protected
      def original_attribute_memoized?(column_name)
        @original_attributes ||= {}
        @default_changes     ||= {}
        @original_attributes.has_key? column_name
      end

      class_methods do
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
        # See {Model#column}
        def column(column_name, options={})
          super
          define_attribute_method(column_name)
        end

        def merge_options(column_name, options={})
          original_options = options(column_name)
          add_type_validation(column_name) if !original_options[:validate_type] && options[:validate_type]
          super
        end

        # Define default attribute method for a column
        # @param column_name [Symbol] the cell's column_name
        def define_attribute_method(column_name)
          return if method_defined? column_name
          add_type_validation(column_name)
          define_method(column_name) { original_attribute(column_name) }
        end
      end
    end
  end
end
