require 'spec_helper'

describe CsvRowModel::Export::Base do
  let(:source_model) { Model.new('Test 1', 'Test 2') }
  let(:row_model_class) {  Class.new(BasicExportModel) }
  let(:instance)     { row_model_class.new(source_model) }

  describe 'instance' do
    describe '#to_row' do
      subject{ instance.to_row }

      it 'return an array with model attribute values' do
        expect(subject).to eql ["Test 1", "Test 2"]
      end

      context "with attribute overwritten" do
        before do
          row_model_class.class_eval do
            def string1; "waka" end
          end
        end

        it 'return an array with the override' do
          expect(subject).to eql ["waka", "Test 2"]
        end
      end
    end
  end
end
