require 'spec_helper'

describe CsvRowModel::Import do
  def test_attributes
    expect(klass.new(%w[a b]).attributes).to eql(string1: 'a', string2: 'b')
  end

  it_behaves_like "with_or_without_csv_row_model_model", CsvRowModel::Import
end