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
    has_many :item_row_models, ItemImportRowModel

    def items
      deep_public_send(:item)
    end
  end
  class ListImportWMapper
    include CsvRowModel::Import::Mapper
    dependent_attributes list: [:list_name, :items]

    protected
    def _list
      { list_name: row_model.list_name, items: row_model.items }
    end
  end
  subject do
    CsvRowModel::Import::File.new(file_path, ListImportWMapper)
  end
  it '' do
    enum = subject.each
    mapper = enum.next

    expect(mapper.row_model.source_header).to eql(['list_name', 'item'])
    expect(mapper.list).to eql(list_name: 'list a', items: ['item 1', 'item 2', 'item 3'])

    mapper = enum.next
    expect(mapper.list).to eql(list_name: 'list b', items: ['item 1'])
  end
end
