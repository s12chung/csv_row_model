class BooleanFormatValidator < ActiveModel::EachValidator # :nodoc:
  FALSE_BOOLEAN_REGEX = /^(false|f|no|n|0|)$/i
  TRUE_BOOLEAN_REGEX = /^(true|t|yes|y|1)$/i

  def validate_each(record, attribute, value)
    return if value =~ FALSE_BOOLEAN_REGEX || value =~ TRUE_BOOLEAN_REGEX

    record.errors.add(attribute, 'is not a Boolean format')
  end
end