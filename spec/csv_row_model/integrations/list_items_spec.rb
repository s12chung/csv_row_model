require 'spec_helper'

describe 'List Items simple Scenario' do
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
  class ItemImportRowModel < BaseModel
    include CsvRowModel::Import
    validates :list_name, absence: true
  end
  class ListImportRowModel < BaseModel
    include CsvRowModel::Import
    has_many :items, ItemImportRowModel

    def all_items
      deep_public_send(:item)
    end
  end
  subject do
    CsvRowModel::Import::File.new(file_path, ListImportRowModel)
  end
  it '' do
    enum = subject.each
    mapper = enum.next

    expect(mapper.source_header).to eql(['list_name', 'item'])
    expect(mapper.list_name).to eql('list a')
    expect(mapper.all_items).to eql(['item 1', 'item 2', 'item 3'])

    mapper = subject.next
    expect(mapper.list_name).to eql('list b')
    expect(mapper.all_items).to eql(['item 1'])
  end
end
