class FloatFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    Float(value)
  rescue ArgumentError, TypeError
    record.errors.add(attribute, 'is not a Float format')
  end
end