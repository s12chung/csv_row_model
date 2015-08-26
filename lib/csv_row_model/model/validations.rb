require 'csv_row_model/model/csv_string_model'

module CsvRowModel
  module Model
    module Validations
      extend ActiveSupport::Concern

      included do
        include Concerns::DeepClassVar

        include ActiveWarnings
        include Validators::ValidateAttributes

        class << self
          # @return [Class] the Class with validations of the csv_string_model
          def csv_string_model_class
            @csv_string_model_class ||= inherited_custom_class(:csv_string_model_class, CsvStringModel)
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