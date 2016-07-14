require 'spec_helper'

describe CsvRowModel::Export::Attribute do
  describe "instance" do
    let(:instance) { described_class.new(:string1, row_model) }
    let(:row_model_class) { Class.new BasicExportModel }
    let(:source_model) { OpenStruct.new(string1: "1.01") }
    let(:row_model) { row_model_class.new(source_model) }

    describe "#value" do
      subject { instance.value }

      it "equals the formatted_value" do
        expect(instance).to receive(:formatted_value).and_return("stub")
        expect(subject).to eql "stub"
      end
    end

    describe "#formatted_value" do
      it_behaves_like "formatted_value_method", "1.01__string1__0__#<OpenStruct>"
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