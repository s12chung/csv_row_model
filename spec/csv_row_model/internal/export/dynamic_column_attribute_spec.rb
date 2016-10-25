require 'spec_helper'

describe CsvRowModel::Export::DynamicColumnAttribute do
  describe "instance" do
    let(:instance) { described_class.new(:skills, row_model) }
    let(:row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Export
        dynamic_column :skills
      end
    end
    let(:row_model) { row_model_class.new(nil, skills: Skill.all) }

    it_behaves_like "has_needed_value_methods", CsvRowModel::DynamicColumnsBase

    describe "#unformatted_value" do
      subject { instance.unformatted_value }

      it "calls formatted_cells" do
        expect(instance).to receive(:formatted_cells)
        subject
      end
    end

    describe "#formatted_cells" do
      open_struct = OpenStruct.new(skills: Skill.all)
      it_behaves_like "formatted_cells_method", CsvRowModel::Export, [
        "Organized__skills__#{open_struct}",
        "Clean__skills__#{open_struct}",
        "Punctual__skills__#{open_struct}",
        "Strong__skills__#{open_struct}",
        "Crazy__skills__#{open_struct}",
        "Flexible__skills__#{open_struct}"
      ]
    end

    describe "#source_cells" do
      subject { instance.source_cells }

      it "returns an array of unformatted_cell" do
        expect(instance).to receive(:header_models).and_call_original
        expect(subject).to eql Skill.all
      end

      context "with process method defined" do
        before do
          row_model_class.class_eval do
            def skill(header_model);  "__#{header_model}" end
          end
        end

        it "return an array of the result of the process method" do
          expect(subject).to eql ["__Organized", "__Clean", "__Punctual", "__Strong", "__Crazy", "__Flexible"]
        end
      end
    end

    describe "class" do
      describe "::define_process_cell" do
        let(:klass) { Class.new { include CsvRowModel::HiddenModule } }
        subject { described_class.define_process_cell(klass, :somethings) }

        it "adds the process method to the class" do
          subject
          expect(klass.new.something("a")).to eql "a"
        end
      end
    end
  end
end