module CsvRowModel
  module Validators
    module ValidateAttributes
      extend ActiveSupport::Concern

      class AttributeValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return unless value && !value.valid?
          record.errors.add(attribute)
        end
      end

      class_methods do
        protected

        # inspiration: https://github.com/rails/rails/blob/2bb0abbec0e4abe843131f188129a1189b1bf714/activerecord/lib/active_record/validations/associated.rb#L46
        def validate_attributes(*attributes)
          validates_with AttributeValidator, { attributes: attributes }
        end
      end
    end
  end
end