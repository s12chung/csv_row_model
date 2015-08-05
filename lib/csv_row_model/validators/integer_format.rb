class IntegerFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    return if value.class == String && value.to_i.to_s == value.partition(".").first
    record.errors.add(attribute, 'is not a Integer format')
  end
end