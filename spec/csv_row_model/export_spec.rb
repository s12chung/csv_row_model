require 'spec_helper'

describe CsvRowModel::Export do
  describe "class" do
    describe "::format_header" do
      let(:header) { 'user_name' }
      subject { BasicExportModel.format_header(header) }

      it "returns the header" do
        expect(subject).to eql header
      end
    end

    describe "::column_headers" do
      let(:column_headers) { [:string1, 'String 2'] }
      subject { BasicExportModel.column_headers }

      it "returns an array with header column names" do
        expect(subject).to eql column_headers
      end
    end
  end

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