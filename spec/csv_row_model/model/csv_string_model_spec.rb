require 'spec_helper'

describe CsvRowModel::Model::CsvStringModel do
  describe "instance" do
    let(:instance) { described_class.new(string1: "abc", string2: "efg") }

    describe "attribute methods" do
      it "works" do
        expect(instance.string1).to eql "abc"
        expect(instance.string2).to eql "efg"
      end

      context "when calling a undefined method" do
        subject { instance.waka }
        it "gives an exception" do
          expect { subject }.to raise_error(NoMethodError)
        end
      end
    end
  end
end