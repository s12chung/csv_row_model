class BooleanFormatValidator < ActiveModel::EachValidator # :nodoc:
  # inspired by https://github.com/MrJoy/to_bool/blob/5c9ed38e47c638725e33530ea1a8aec96281af20/lib/to_bool.rb#L23
  FALSE_BOOLEAN_REGEX = /^(false|f|no|n|0)$/i
  TRUE_BOOLEAN_REGEX = /^(true|t|yes|y|1)$/i

  def validate_each(record, attribute, value)
    return if value =~ FALSE_BOOLEAN_REGEX || value =~ TRUE_BOOLEAN_REGEX

    record.errors.add(attribute, 'is not a Boolean format')
  end
end