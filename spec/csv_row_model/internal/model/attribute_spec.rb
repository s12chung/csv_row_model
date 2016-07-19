require 'spec_helper'

describe CsvRowModel::Model::Attribute do
  describe "instance" do
    let(:instance) { described_class.new(:string1, row_model) }
    let(:row_model_class) { Class.new BasicRowModel }
    let(:row_model) { row_model_class.new }

    let(:source_value) { "1.01" }
    before do
      allow(instance).to receive(:source_value).and_return(source_value)
    end

    describe "#formatted_value" do
      subject { instance.formatted_value }

      before do
        row_model_class.class_eval do
          def self.format_cell(*args); args.join("__") end
        end
      end

      it "returns the formatted_cell value and memoizes it" do
        expect(subject).to eql("1.01__string1__0__#<OpenStruct>")
        expect(subject.object_id).to eql instance.formatted_value.object_id
      end
    end
  end
end