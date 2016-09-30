class BooleanFormatValidator < ActiveModel::EachValidator # :nodoc:
  # inspired by https://github.com/MrJoy/to_bool/blob/5c9ed38e47c638725e33530ea1a8aec96281af20/lib/to_bool.rb#L23
  FALSE_BOOLEAN_REGEX = /^(false|f|no|n|0)$/i.freeze
  TRUE_BOOLEAN_REGEX = /^(true|t|yes|y|1)$/i.freeze

  def validate_each(record, attribute, value)
    return if value =~ self.class.false_boolean_regex || value =~ self.class.true_boolean_regex

    record.errors.add(attribute, 'is not a Boolean format')
  end

  class << self
    def false_boolean_regex; FALSE_BOOLEAN_REGEX end
    def true_boolean_regex; TRUE_BOOLEAN_REGEX end
  end
end