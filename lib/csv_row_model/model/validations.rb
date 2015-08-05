require 'csv_row_model/model/csv_string_model'

module CsvRowModel
  module Model
    module Validations
      extend ActiveSupport::Concern

      included do
        include ActiveWarnings
        include Validators::ValidateAttributes

        class << self
          # @return [Class] the Class with validations of the csv_string_model
          def csv_string_model_class
            @csv_string_model_class ||= begin
              klass = Class.new(CsvStringModel)
              # how else can i get the current scopes name...
              klass.send(:define_singleton_method, :name, &eval("-> { \"#{name}RawCsv\" }"))
              klass
            end
          end

          protected
          # Called to add validations to the csv_string_model_class
          def csv_string_model(&block)
            csv_string_model_class.instance_eval &block
          end
        end
      end
    end
  end
end