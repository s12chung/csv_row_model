module CsvRowModel
  class Coercer < Struct.new(:options, :caller)

    def decode(value)
      caller.instance_exec(value, &parse_lambda)
    end

    private

    # @return [Lambda, Proc] returns the Lambda/Proc given in the parse option or:
    # ->(original_value) { parse_proc_exists? ? parsed_value : original_value  }
    def parse_lambda
      raise ArgumentError.new("You need either :parse OR :type but not both of them") if options[:parse] && options[:type]
      parse_lambda = options[:parse] || CLASS_TO_PARSE_LAMBDA[options[:type]]
      return parse_lambda if parse_lambda
      raise ArgumentError.new("type must be #{CLASS_TO_PARSE_LAMBDA.keys.reject{|e|e.nil?}.join(', ')}")
    end

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

  end
end
