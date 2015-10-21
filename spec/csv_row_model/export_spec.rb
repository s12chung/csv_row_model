require 'spec_helper'

describe CsvRowModel::Export do
  let(:source_model) { Model.new(string1, string2) }
  let(:instance) { BasicExportModel.new(source_model) }

  let(:string1) { "Test 1" }
  let(:string2) { "Test 2" }

  describe "instance" do
    describe "#to_row" do
      subject{ instance.to_row }

      it "return an array with model attribute values" do
        expect(subject).to eql [string1, string2]
      end
    end
  end

  describe "class" do
    context 'with column defined before and after Export module' do
      let(:export_model_class) do
        Class.new do
          include CsvRowModel::Model
          column :string1
          include CsvRowModel::Export
          column :string2
        end
      end

      it 'define_method should be called with all defined columns' do
        expect(instance.string1).to eql string1
        expect(instance.string2).to eql string2
      end
    end
  end
end