require 'spec_helper'

describe CsvRowModel::Export do
  def test_attributes
    attributes = { string1: 'a', string2: 'b' }
    expect(klass.new(OpenStruct.new(attributes)).attributes).to eql attributes
  end

  it_behaves_like "with_or_without_csv_row_model_model", CsvRowModel::Export
end