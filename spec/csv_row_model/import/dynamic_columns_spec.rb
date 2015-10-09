require 'spec_helper'

describe CsvRowModel::Import::DynamicColumns do
  subject do
    CsvRowModel::Import::File.new(dynamic_column_4_rows_path, DynamicColumnImportModel)
  end

  it '' do
    row_model = subject.next

    expect(row_model.first_name).to eql('Josie')
    expect(row_model.last_name).to eql('Herman')
    expect(row_model.skills).to eql(["Organize", "Clean", "Crazy"])
    expect(row_model.dynamic_source_headers).to eql(Skill.all)
  end
end
