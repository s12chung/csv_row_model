require 'spec_helper'

describe CsvRowModel::Import do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:import_model_klass) { BasicImportModel }
    let(:instance) { import_model_klass.new(source_row, options) }

    describe "#initialize" do
      subject { instance }

      context "should set the child" do
        let(:parent_instance) { BasicModel.new }
        let(:options) { { parent:  parent_instance } }
        specify { expect(subject.child?).to eql true }
      end
    end

    describe "#inspect" do
      subject { instance.inspect }
      it("works") { subject }
    end

    describe "#mapped_row" do
      subject { instance.mapped_row }
      it "returns a map of `column_name => source_row[index_of_column_name]" do
        expect(subject).to eql(string1: "1.01", string2: "b")
      end
    end

    describe "#free_previous" do
      let(:options) { { previous: import_model_klass.new([]) } }

      subject { instance.free_previous }

      it "makes previous nil" do
        expect(instance.previous).to_not eql nil
        subject
        expect(instance.previous).to eql nil
      end
    end
  end
end
