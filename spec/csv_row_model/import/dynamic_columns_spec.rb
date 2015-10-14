require 'spec_helper'

describe CsvRowModel::Import::DynamicColumns do

  subject do
    CsvRowModel::Import::File.new(dynamic_column_4_rows_path, DynamicColumnImportModel)
  end

  it 'should import correctly dynamic columns' do
    row_model = subject.next

    expect(row_model.first_name).to eql('Josie')
    expect(row_model.last_name).to  eql('Herman')

    # ROW => Josie , Herman , Yes , Yes , No , No , Yes , No
    #
    # ['Organize', 'Clean', 'Punctual', 'Strong', 'Crazy', 'Flexible']
    # ['Yes'     , 'Yes'  , 'No'      , 'No'    ,  'Yes' , 'No'      ]
    expect(row_model.skills).to eql(['Organize', 'Clean', 'Crazy'])

    # ['Organize', 'Clean', 'Punctual', 'Strong', 'Crazy', 'Flexible']
    expect(row_model.dynamic_source_headers).to eql(Skill.all)
  end
end
