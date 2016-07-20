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
          row_model_class.class_eval { def string1; "waka" end }
        end
        it 'return an array with the override' do
          expect(subject).to eql ["waka", "Test 2"]
        end
      end

      context "with format_cell" do
        before do
          row_model_class.class_eval { def self.format_cell(*args) args.join("__") end }
        end
        it 'return an array with the override' do
          expect(subject).to eql ["Test 1__string1__0__#<OpenStruct>", "Test 2__string2__1__#<OpenStruct>"]
        end
      end
    end
  end
end
