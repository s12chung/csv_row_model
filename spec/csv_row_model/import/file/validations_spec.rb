require 'spec_helper'

describe CsvRowModel::Import::File do
  let(:file_path) { basic_1_row_path }
  let(:model_class) { BasicImportModel }
  let(:instance) { described_class.new file_path, model_class }

  describe "#safe?" do
    subject { instance.safe? }

    it "defaults to true" do
      expect(subject).to eql true
    end

    context "bad header" do
      let(:file_path) { bad_header_1_row_path }

      it "has header to be an empty array" do
        expect(subject).to eql false
        expect(instance.headers).to eql []
        expect(instance.warnings.full_messages).to eql ["Csv has header with Unclosed quoted field on line 1."]
      end
    end
  end

  describe "abort?" do
    subject { instance.abort? }

    context "when valid?" do
      before do
        expect(instance).to receive(:valid?).and_return(true)
      end

      context "when current_row_model is nil" do
        before do
          expect(instance).to receive(:current_row_model).and_return(nil)
        end

        it "returns false" do
          expect(subject).to eql false
        end
      end
    end
  end

  describe "skip?" do
    subject { instance.skip? }

    context "when current_row_model is nil" do
      before do
        expect(instance).to receive(:current_row_model).and_return(nil)
      end

      it "returns false" do
        expect(subject).to eql false
      end
    end
  end
end