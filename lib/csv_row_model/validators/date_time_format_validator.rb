class DateTimeFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    DateTime.parse(value)
  rescue ArgumentError, TypeError
    record.errors.add(attribute, 'is not a DateTime format')
  end
end
