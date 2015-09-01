require 'spec_helper'

describe CsvRowModel::Export do
  describe "instance" do
    let(:string1) { "Test 1" }
    let(:string2) { "Test 2" }
    let(:source_model) { Model.new(string1, string2) }
    let(:instance) { BasicExportModel.new(source_model) }

    describe "#to_row" do
      subject{ instance.to_row }

      it "return an array with model attribute values" do
        expect(subject).to eql [string1, string2]
      end
    end
  end
end