class IntegerFormatValidator < ActiveModel::EachValidator # :nodoc:
  ZERO_DECIMAL_REGEXP = /\A0+\.0+\z/.freeze # 00.000

  def validate_each(record, attribute, value)
    Integer(value)
  rescue ArgumentError
    integer = value.to_i
    return if  integer == value.to_f && (integer != 0 || value.match(ZERO_DECIMAL_REGEXP))
    add_error(record, attribute)
  rescue TypeError
    add_error(record, attribute)
  end

  def add_error(record, attribute)
    record.errors.add(attribute, 'is not a Integer format')
  end
end