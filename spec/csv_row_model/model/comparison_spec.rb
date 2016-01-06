require 'spec_helper'

describe CsvRowModel::Model::Comparison do
  context '#export' do
    let(:model) { Model.new('foo','bar') }

    it 'should remove duplicate entries' do
      expect([BasicExportModel.new(model),BasicExportModel.new(model)].uniq.size).to eql(1)
    end
  end

  context '#import' do
    let(:source_row) { ['foo', 'bar'] }

    it 'should remove duplicate entries' do
      expect([BasicImportModel.new(source_row), BasicImportModel.new(source_row)].uniq.size).to eql(1)
    end
  end
end
