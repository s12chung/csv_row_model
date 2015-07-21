module CsvRowModel
  module Validators
    module ValidateAttributes
      extend ActiveSupport::Concern

      class AttributeValidator < ActiveModel::EachValidator # :nodoc:
        def validate_each(record, attribute, value)
          warnings = record.instance_variable_get(:@run_warning_validations)
          return unless value && (warnings ? value.unsafe? : value.invalid?)
          record.errors.add(attribute)
        end
      end

      class_methods do
        protected

        # Adds validation check to add errors any attribute of `attributes` passed is truthy and invalid.
        # Inspired by: https://github.com/rails/rails/blob/2bb0abbec0e4abe843131f188129a1189b1bf714/activerecord/lib/active_record/validations/associated.rb#L46
        #
        # @param [Array<Symbol>] attributes array of attributes to check
        def validate_attributes(*attributes)
          validates_with AttributeValidator, { attributes: attributes }
        end
      end
    end
  end
end