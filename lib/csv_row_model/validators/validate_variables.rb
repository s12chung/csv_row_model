module CsvRowModel
  module Validators
    module ValidateVariables
      extend ActiveSupport::Concern

      class VariableValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return unless value && !value.valid?
          record.errors.add(attribute)
        end
      end

      module ClassMethods
        protected

        # inspiration: https://github.com/rails/rails/blob/2bb0abbec0e4abe843131f188129a1189b1bf714/activerecord/lib/active_record/validations/associated.rb#L46
        def validate_variables(*variables)
          validates_with VariableValidator, { attributes: variables }
        end
      end
    end
  end
end