class DateFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    begin
      Date.parse(value.to_s)
    rescue ArgumentError
      record.errors.add(attribute, 'is not a Date format')
    end
  end
end