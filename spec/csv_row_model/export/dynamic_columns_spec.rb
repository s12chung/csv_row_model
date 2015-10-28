require 'spec_helper'

describe CsvRowModel::Export::DynamicColumns do
  let(:skills) { Skill.all }

  let(:instance) { export_model_class.new(User.new("Mario", "Doe"), skills: skills) }
  let(:export_model_class) { DynamicColumnExportModel }

  describe "instance" do
    describe "#to_row" do
      subject { instance.to_row }

      it "returns a row representation of the row_model" do
        expect(subject).to eql ["Mario", "Doe"] + skills
      end
    end
  end

  describe "class" do
    describe "attribute methods" do
      let(:export_model_base_class) do
        Class.new do
          include CsvRowModel::Model
        end
      end
      let(:export_model_class) do
        Class.new(export_model_base_class) do
          include CsvRowModel::Export
          dynamic_column :skills
        end
      end

      subject { instance.skills }

      it 'works' do
        expect(subject).to eql(skills)
      end

      context "when defined before Export" do
        let(:export_model_class) do
          Class.new(export_model_base_class) do
            dynamic_column :skills
            include CsvRowModel::Export
          end
        end

        it "works" do
          expect(subject).to eql(skills)
        end
      end

      context 'with overwritten singular method' do
        let(:export_model_class) do
          Class.new(export_model_base_class) do
            dynamic_column :skills
            include CsvRowModel::Export

            def skill(header_model)
              header_model.upcase
            end
          end
        end

        it "works" do
          expect(subject).to eql(skills.map(&:upcase))
        end
      end
    end
  end
end
