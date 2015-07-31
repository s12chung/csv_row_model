require 'spec_helper'

describe CsvRowModel::Import::File do
  let(:file_path) { basic_1_row_path }
  let(:model_class) { BasicImportModel }
  let(:instance) { described_class.new file_path, model_class }

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