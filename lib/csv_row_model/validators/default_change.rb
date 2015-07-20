class DefaultChangeValidator < ActiveModel::EachValidator # :nodoc:
  def validate_each(record, attribute, value)
    return unless record.default_changes[attribute]
    record.errors.add(attribute, 'changed by default')
  end
end