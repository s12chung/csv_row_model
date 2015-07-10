require 'spec_helper'

describe CsvRowModel::Import do
  describe "instance" do
    let(:source_row) { %w[a b] }
    let(:options) { {} }
    let(:instance) { BasicImportModel.new(source_row, options) }

    describe "attribute methods" do
      subject { instance.string1 }

      it "calls format_cell and returns the result" do
        expect(BasicImportModel).to receive(:format_cell).with("a", :string1, 0).and_return "waka"
        expect(subject).to eql "waka"
      end
    end

    describe "#mapped_row" do
      subject { instance.mapped_row }
      it "returns a map of `column_name => source_row[index_of_column_name]" do
        expect(subject).to eql(string1: "a", string2: "b")
      end
    end

    describe "#free_previous" do
      let(:options) { { previous: BasicImportModel.new([]) } }

      subject { instance.free_previous }

      it "makes previous nil" do
        expect(instance.previous).to_not eql nil
        subject
        expect(instance.previous).to eql nil
      end
    end
  end

  describe "class" do
    describe "::format_cell" do
      let(:cell) { "the_cell" }
      subject { BasicImportModel.format_cell(cell, nil, nil) }

      it "returns the cell" do
        expect(subject).to eql cell
      end
    end
  end
end