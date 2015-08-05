class FloatFormatValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    return if value.to_f.to_s =~ /#{value}(?:\.0)?/
    record.errors.add(attribute, 'is not a Float format')
  end
end