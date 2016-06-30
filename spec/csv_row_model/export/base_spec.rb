require 'spec_helper'

describe CsvRowModel::Export::Base do
  let(:source_model) { Model.new('Test 1', 'Test 2') }
  let(:instance)     { BasicExportModel.new(source_model) }

  describe 'instance' do
    describe '#to_row' do
      subject{ instance.to_row }

      it 'return an array with model formatted attribute values' do
        expect(subject).to eql ["Test 1", "Test 2"]
      end
    end
  end
end
