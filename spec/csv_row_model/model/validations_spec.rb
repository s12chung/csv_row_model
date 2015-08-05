require 'spec_helper'

describe CsvRowModel::Model::Validations do
  describe "class" do
    let(:klass) { Class.new { include CsvRowModel::Model::Validations } }

    describe "::csv_string_model_class" do
      subject { klass.csv_string_model_class }

      let(:klass) { BasicModel }

      it "gives a name" do
        expect(subject.name).to eql "BasicModelRawCsv"
      end
      it "memoizes so there's no memory leak (classes don't GC)" do
        expect(klass.csv_string_model_class.object_id).to eql klass.csv_string_model_class.object_id
      end
    end

    describe "::csv_string_model" do
      subject do
        klass.send(:csv_string_model) do
          validates :string1, presence: true
        end
      end

      it "propagates validations" do
        subject
        expect(klass.csv_string_model_class.new(string1: "blah").valid?).to eql true
        expect(klass.csv_string_model_class.new(string1: "").valid?).to eql false
      end
    end
  end
end