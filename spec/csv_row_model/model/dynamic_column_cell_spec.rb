require 'spec_helper'

describe CsvRowModel::Model::DynamicColumnCell do
  describe "instance" do
    let(:instance) { described_class.new(:skills, row_model) }
    let(:row_model_class) do
      Class.new do
        include CsvRowModel::Model
        dynamic_column :skills
      end
    end
    let(:row_model) { row_model_class.new }

    describe "#value" do
      subject { instance.value }
      let(:unformatted_value) { ["Yes", "Yes", "No", "Yes", "Yes", "No"] }
      before do
        row_model_class.class_eval do
          def self.format_dynamic_column_cells(*args); args end
        end
      end

      it "formats the column cells and memoizes" do
        expect(instance).to receive(:unformatted_value).and_return(unformatted_value)
        expect(subject).to eql [unformatted_value, :skills, 0, OpenStruct.new]
        expect(subject.object_id).to eql instance.value.object_id
      end
    end

    describe "#dynamic_column_index" do
      subject { instance.dynamic_column_index }

      it "calls dynamic_column_index on the class and memoizes" do
        expect(row_model_class).to receive(:dynamic_column_index).with(:skills).and_call_original
        expect(subject).to eql 0
        expect(subject.object_id).to eql instance.dynamic_column_index.object_id
      end
    end

    describe "#process_cell_method_name" do
      subject { instance.send(:process_cell_method_name) }

      it "calls the class method" do
        expect(described_class).to receive(:process_cell_method_name).with(:skills).and_call_original
        expect(subject).to eql :skill
      end
    end

    describe "#call_process_cell" do
      subject { instance.send(:call_process_cell, "a", "b") }

      before do
        row_model_class.class_eval do
          def skill(formatted_cell, source_header);  "#{formatted_cell}**#{source_header}" end
        end
      end

      it "calls the process_cell properly" do
        expect(subject).to eql "a**b"
      end
    end
  end

  describe "class" do
    describe "::process_cell_method_name" do
      subject { described_class.process_cell_method_name(:somethings) }

      it "returns a singularized name" do
        expect(subject).to eql :something
      end
    end
  end
end