class IntegerFormatValidator < CsvRowModel::Validators::NumberValidator # :nodoc:
  def validate_each(record, attribute, value)
    before, after = before_after_decimal(value)

    return if value.to_i.to_s == before && after.empty?

    record.errors.add(attribute, 'is not a Integer format')
  end
end