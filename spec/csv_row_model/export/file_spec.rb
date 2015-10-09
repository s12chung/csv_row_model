require 'spec_helper'

describe CsvRowModel::Export::File do

  describe "instance" do
    let(:string1)    { "Test 1" }
    let(:string2)    { "Test 2" }
    let(:model)     { Model.new(string1, string2) }
    let(:instance)   { described_class.new(FileExportModel, some_context: true)  }

    describe "#generate" do
      let(:row1)        { ['string1', string1] }
      let(:row2)        { ['String 2', string2] }

      include_context 'csv file'

      let(:csv_source) { [row1, row2] }

      it "returns csv string" do
        expect(FileExportModel).to receive(:new)
                                         .with(anything, { some_context: true, another_context: true })
                                         .and_call_original

        expect(instance.generated?).to eql false

        instance.generate do |csv|
          csv.append_model(model, another_context: true)
        end
        expect(instance.generated?).to eql true
        expect(instance.context).to eql(some_context: true)
        expect(instance.to_s).to eql csv_string
      end
    end
  end
end