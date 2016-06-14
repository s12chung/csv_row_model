require 'spec_helper'

describe CsvRowModel::Export::Cell do
  describe "instance" do
    let(:instance) { described_class.new(:string1, row_model) }
    let(:export_row_model_class) { BasicExportModel }
    let(:source_model) { OpenStruct.new(string1: "1.01") }
    let(:row_model) { export_row_model_class.new(source_model) }

    describe "#value" do
      subject { instance.value }

      it "equals the formatted_value" do
        expect(instance).to receive(:formatted_value).and_return("stub")
        expect(subject).to eql "stub"
      end
    end

    describe "#formatted_value" do
      subject { instance.formatted_value }

      it "returns the formatted_cell value and memoizes it" do
        expect(export_row_model_class).to receive(:format_cell).with("1.01", :string1, 0, kind_of(OpenStruct)).once.and_return("waka")
        expect(subject).to eql("waka")
        expect(subject.object_id).to eql instance.formatted_value.object_id
      end
    end

    describe "#source_value" do
      subject { instance.source_value }

      it "returns the row_model method" do
        expect(source_model).to receive(:string1).and_call_original
        expect(subject).to eql("1.01")
      end
    end
  end
end