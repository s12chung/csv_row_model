module CsvRowModel
  module Validators
    class NumberValidator < ActiveModel::EachValidator # :nodoc:
      def before_after_decimal(value)
        value ||= ""
        before, decimal, after = value.partition(".")
        before.sub!(/\A0+/, "")
        after.sub!(/0+\z/, "")
        [before, after]
      end
    end
  end
end