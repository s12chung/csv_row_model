class DateTimeFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    begin
      DateTime.parse(value.to_s)
    rescue ArgumentError
      record.errors.add(attribute, 'is not a Date Time format')
    end
  end
end
