require 'spec_helper'

describe CsvRowModel::Export::Attributes do
  let(:source_model) { Model.new('Test 1', 'Test 2') }
  let(:instance)     { BasicExportModel.new(source_model) }

  describe 'instance' do
    subject { instance.formatted_attributes }
    context 'regular columns' do
      describe "#formatted_attributes" do
        it "returns the map of column_name => format_cell(public_send(column_name))" do
          expect(subject).to eql( string1: "TEST 1", string2: "TEST 2" )
        end
      end
    end
    context 'dynamic olumns' do
      describe "#formatted_attributes" do
        let(:instance) { DynamicColumnExportWithFormattingModel.new(User.new('Mario', 'Doe'), skills: Skill.all) }
        it "ensure CsvRowModel::Export::Attributes#formatted_attributes don't format dynamic columns" do
          expect(subject).to eql(first_name: 'MARIO', last_name: 'DOE', skills: ['ORGANIZED', 'CLEAN', 'PUNCTUAL', 'STRONG', 'CRAZY', 'FLEXIBLE'])
        end
      end
    end
  end

  describe 'class' do
    let(:export_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Export
      end
    end

    describe "::define_attribute_method" do
      it "does not do anything the second time" do
        expect(export_model_class).to receive(:define_method).with(:waka).once.and_call_original
        expect(export_model_class).to receive(:define_method).with(:waka2).once.and_call_original

        export_model_class.send(:define_attribute_method, :waka)
        export_model_class.send(:define_attribute_method, :waka)
        export_model_class.send(:define_attribute_method, :waka2)
        export_model_class.send(:define_attribute_method, :waka2)
      end
    end

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
