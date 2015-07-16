require 'spec_helper'

describe 'List Items Scenario' do
  include_context 'csv file'
  let(:csv_source) do
    [
      [ 'list_name', 'item'   ],
      [ 'list a',    'item 1' ],
      [ '',          'item 2' ],
      [ '',          'item 3' ],
      [ 'list b',    'item 1' ],
    ]
  end
  class BaseModel
    include CsvRowModel::Model
    column :list_name
    column :item
  end
  class ItemImportModel < BaseModel
    include CsvRowModel::Import
    validates :list_name, absence: true
  end
  class ListImportModel < BaseModel
    include CsvRowModel::Import
    has_many :items, ItemImportModel
  end
  # mapper not really needed in this example
  class ListImportMapper
    include CsvRowModel::Import::Mapper
    memoize :list_name, :items


    private
    def _list_name
      row_model.list_name
    end
    def _items
      row_model.deep_public_send(:item)
    end
  end
  subject do
    CsvRowModel::Import::File.new(file_path, ListImportMapper)
  end
  it '' do
    mapper = subject.next
    expect(mapper.row_model.source_header).to eql(['list_name', 'item'])
    expect(mapper.list_name).to eql('list a')
    expect(mapper.items).to eql(['item 1', 'item 2', 'item 3'])

    mapper = subject.next
    expect(mapper.list_name).to eql('list b')
    expect(mapper.items).to eql(['item 1'])
  end
end
