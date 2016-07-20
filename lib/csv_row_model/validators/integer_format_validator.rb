class IntegerFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    Integer(value)
  rescue ArgumentError
    integer = value.to_i
    return if integer == value.to_f && integer != 0
    add_error(record, attribute)
  rescue TypeError
    add_error(record, attribute)
  end

  def add_error(record, attribute)
    record.errors.add(attribute, 'is not a Integer format')
  end
end