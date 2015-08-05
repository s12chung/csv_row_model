class DateFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    begin
      Date.parse(value)
    rescue ArgumentError
      record.errors.add(attribute, 'is not a Date format')
    end
  end
end