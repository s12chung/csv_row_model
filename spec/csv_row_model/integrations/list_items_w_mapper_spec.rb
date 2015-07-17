require 'spec_helper'

describe 'List Items Scenario with Mapper' do
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
  class BaseWModel
    include CsvRowModel::Model
    column :list_name
    column :item
  end
  class ItemImportWRowModel < BaseWModel
    include CsvRowModel::Import
    validates :list_name, absence: true
  end
  class ListImportWRowModel < BaseWModel
    include CsvRowModel::Import
    has_many :items, ItemImportRowModel
  end
  class ListImportWMapper
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
    CsvRowModel::Import::File.new(file_path, ListImportWMapper)
  end
  it '' do
    enum = subject.each
    mapper = enum.next

    expect(mapper.row_model.source_header).to eql(['list_name', 'item'])
    expect(mapper.list_name).to eql('list a')
    expect(mapper.items).to eql(['item 1', 'item 2', 'item 3'])

    mapper = enum.next
    expect(mapper.list_name).to eql('list b')
    expect(mapper.items).to eql(['item 1'])
  end
end
