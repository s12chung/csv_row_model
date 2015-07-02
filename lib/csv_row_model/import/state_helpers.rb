module CsvRowModel
  module Import
    module StateHelpers
      class << self
        def and(primary_condition, secondary_conditions)
          raise "Invalid #{self.class} state" if primary_condition && !secondary_conditions
          primary_condition
        end
      end
    end
  end
end