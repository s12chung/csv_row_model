module CsvRowModel
  module Concerns
    module DeepClassVar
      class Cache
        attr_accessor :klass, :variable_name, :value

        def initialize(klass, variable_name)
          @klass, @variable_name = klass, variable_name
        end

        def cache
          return value if valid? && value

          @value = yield
          validate
          value
        end

        def break
          @valid = false
        end

        def break_all
          ([klass] + klass.descendants).each do |descendant|
            descendant.try(:break_cache, variable_name)
          end
        end

        def validate
          @valid = true
        end
        def valid?
          @valid
        end
      end
    end
  end
end