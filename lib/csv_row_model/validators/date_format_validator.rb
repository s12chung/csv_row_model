class DateFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    Date.parse(value)
  rescue ArgumentError, TypeError
    record.errors.add(attribute, 'is not a Date format')
  end
end