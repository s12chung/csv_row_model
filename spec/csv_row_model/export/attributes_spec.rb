require 'spec_helper'

describe CsvRowModel::Export::Attributes do
  let(:source_model) { Model.new('Test 1', 'Test 2') }
  let(:instance)     { BasicExportModel.new(source_model) }

  describe 'instance' do
    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }

      it "returns the map of column_name => format_cell(public_send(column_name))" do
        expect(subject).to eql( string1: "TEST 1", string2: "TEST 2" )
      end
    end
  end

  describe 'class' do
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
        expect(instance.string1).to eql 'Test 1'
        expect(instance.string2).to eql 'Test 2'
      end
    end
  end
end
