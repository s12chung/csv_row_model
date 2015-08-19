module CsvRowModel
  module Validators
    class NumberValidator < ActiveModel::EachValidator # :nodoc:
      def before_after_decimal(value)
        value ||= ""

        # if value == "0003434.1233000"
        #   before = "3434"; after = "1233"
        before, decimal, after = value.partition(".")
        before.sub!(/\A0+/, "")
        after.sub!(/0+\z/, "")
        [before, after]
      end
    end
  end
end