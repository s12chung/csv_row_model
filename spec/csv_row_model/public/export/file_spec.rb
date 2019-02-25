require 'spec_helper'
require 'tempfile'

describe CsvRowModel::Export::File do

  describe "instance" do
    let(:string1)  { "Value Of String 1" }
    let(:string2)  { "Value Of String 2" }
    let(:model)    { Model.new(string1, string2) }
    let(:instance) { described_class.new(FileExportModel, some_context: true)  }

    describe "#generate" do
      let(:file_path) { file_export_model_path }
      let(:csv_string) { File.read(file_path) }

      it "returns csv string" do
        expect(FileExportModel).to receive(:new).with(anything, { some_context: true, another_context: true }).and_call_original

        expect(instance.generated?).to eql false

        instance.generate do |csv|
          expect(csv.class).to_not eql described_class
          csv.append_model(model, another_context: true)
        end

        expect(instance.generated?).to eql true
        expect(instance.context).to eql(some_context: true)
        expect(instance.to_s).to eql csv_string
      end
    end

    describe "#headers" do
      it "returns headers passing context" do
        expect(FileExportModel).to receive(:headers).with({ some_context: true})
        instance.headers
      end
    end
  end
end
