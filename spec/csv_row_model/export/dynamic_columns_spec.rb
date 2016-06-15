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

    describe "#cells" do
      it_behaves_like "cells_method",
                      %i[skills],
                      CsvRowModel::Export::DynamicColumnCell => 1

      with_context "standard columns defined" do
        it_behaves_like "cells_method",
                        %i[first_name last_name skills],
                        CsvRowModel::Export::Cell => 2,
                        CsvRowModel::Export::DynamicColumnCell => 1
      end
    end

    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }

      it "should have dynamic columns" do
        expect(subject).to eql(skills: skills)
      end

      with_context "standard columns defined" do
        it "should have standard and dynamic columns" do
          expect(subject).to eql(first_name: "Mario", last_name: "Doe", skills: skills)
        end
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
  end
end
