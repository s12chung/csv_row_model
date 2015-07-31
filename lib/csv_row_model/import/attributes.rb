module CsvRowModel
  module Import
    module Attributes
      extend ActiveSupport::Concern

      # Mapping of column type classes to a parsing lambda. These are applied after {Import.format_cell}.
      # Can pass custom Proc with :parse option.
      CLASS_TO_PARSE_LAMBDA = {
        nil => ->(s) { s },
        # inspired by https://github.com/MrJoy/to_bool/blob/5c9ed38e47c638725e33530ea1a8aec96281af20/lib/to_bool.rb#L23
        Boolean => ->(s) { s =~ /^(false|f|no|n|0|)$/i ? false : true },
        String  => ->(s) { s },
        Integer => ->(s) { s.to_i },
        Float   => ->(s) { s.to_f },
        Date    => ->(s) { s.present? ? Date.parse(s) : s }
      }

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

        if value.present?
          instance_exec(value, &self.class.parse_lambda(column_name))
        else
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
          define_method(column_name) { original_attribute(column_name) }
        end
      end
    end
  end
end