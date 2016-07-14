require 'spec_helper'

describe CsvRowModel::Model::Base do
  describe "instance" do
    let(:options) { {} }
    let(:instance) { BasicRowModel.new(options) }

    describe "#initialize" do
      subject { instance }
      let(:parent) { BasicRowModel.new }
      let(:options) { { parent: parent } }

      it "sets the parent" do  expect(subject.parent).to eql parent  end
    end

    describe "#initialized_at" do
      subject { instance.initialized_at }
      let(:date_time) { DateTime.now }

      it "gives the time" do
        expect(DateTime).to receive(:now).and_return(date_time)
        expect(subject).to eql date_time
      end
    end

    describe "#skip?" do
      subject { instance.skip? }
      it "skips whenever invalid" do expect(subject).to eql !instance.valid? end
    end

    describe "#abort?" do
      subject { instance.abort? }
      it "never aborts" do expect(subject).to eql false end
    end

    context "with attributes stubbed" do
      let(:attributes) { { string1: "a", string2: "b" } }
      before do
        allow_any_instance_of(BasicRowModel).to receive(:string1) { "a" }
        allow_any_instance_of(BasicRowModel).to receive(:string2) { "b" }
        expect(BasicRowModel.new.attributes).to eql attributes
      end

      describe "#eql?" do
        it "removes duplicate entries" do
          expect([BasicRowModel.new,BasicRowModel.new].uniq.size).to eql(1)
        end
      end

      describe "#hash" do
        subject { instance.hash }
        it "is the attributes hash" do
          expect(subject).to eql attributes.hash
        end
      end
    end
  end
end
