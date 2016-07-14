require 'spec_helper'

describe CsvRowModel::Export::DynamicColumns do
  let(:skills) { Skill.all }
  let(:instance) { row_model_class.new(User.new('Mario', 'Doe'), skills: skills) }
  let(:row_model_class) do
    Class.new do
      include CsvRowModel::Model
      include CsvRowModel::Export
      dynamic_column :skills
    end
  end

  describe 'instance' do
    shared_context "standard columns defined" do
      let(:row_model_class) { DynamicColumnExportModel }
    end

    describe "#attribute_objects" do
      it_behaves_like "attribute_objects_method",
                      %i[skills],
                      CsvRowModel::Export::DynamicColumnAttribute => 1

      with_context "standard columns defined" do
        it_behaves_like "attribute_objects_method",
                        %i[first_name last_name skills],
                        CsvRowModel::Export::Attribute => 2,
                        CsvRowModel::Export::DynamicColumnAttribute => 1
      end
    end

    describe '#to_row' do
      subject { instance.to_row }

      it 'returns a row representation of the row_model' do
        expect(subject).to eql skills
      end

      with_context "standard columns defined" do
        it 'returns a row representation of the row_model' do
          expect(subject).to eql ['Mario', 'Doe'] + skills
        end
      end
    end
  end

  describe 'class' do
    describe "::dynamic_column" do
      it_behaves_like "dynamic_column_method", CsvRowModel::Export, Skill.all
    end

    describe "::define_dynamic_attribute_method" do
      subject { row_model_class.send(:define_dynamic_attribute_method, :skills) }

      it "makes an attribute that calls :original_attribute" do
        subject
        expect(instance).to receive(:original_attribute).with(:skills).and_return("tested")
        expect(instance.skills).to eql "tested"
      end
    end
  end
end
