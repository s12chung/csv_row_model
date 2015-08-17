class FloatFormatValidator < CsvRowModel::Validators::NumberValidator # :nodoc:
  def validate_each(record, attribute, value)
    before, after = before_after_decimal(value)
    return if value.present? && value.to_f.to_s =~ /#{before}\.#{after.present? ? after : 0}/
    record.errors.add(attribute, 'is not a Float format')
  end
end