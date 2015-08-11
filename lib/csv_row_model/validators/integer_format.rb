class IntegerFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    value ||= ""
    before, decimal, after = value.partition(".")
    return if value.class == String && value.to_i.to_s == before && (after.blank? || after =~ /0+\z/)
    record.errors.add(attribute, 'is not a Integer format')
  end
end