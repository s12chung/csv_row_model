require 'spec_helper'

describe CsvRowModel::Model::Comparison do
  describe "#eql?" do
    context 'Export' do
      let(:model) { Model.new('foo','bar') }

      it 'should remove duplicate entries' do
        expect([BasicExportModel.new(model),BasicExportModel.new(model)].uniq.size).to eql(1)
      end

      it "works with nil given" do
        expect(BasicExportModel.new(model).eql?(nil)).to eql false
      end
    end

    context 'Import' do
      let(:source_row) { ['foo', 'bar'] }

      it 'should remove duplicate entries' do
        expect([BasicImportModel.new(source_row), BasicImportModel.new(source_row)].uniq.size).to eql(1)
      end

      it "works with nil given" do
        expect(BasicImportModel.new(source_row).eql?(nil)).to eql false
      end
    end
  end
end
