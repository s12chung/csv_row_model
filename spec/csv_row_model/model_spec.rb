require 'spec_helper'

describe CsvRowModel::Model do
  describe "instance" do
    let(:options) { {} }
    let(:instance) { BasicModel.new(nil, options) }

    describe "#initialize" do
      subject { instance }
      let(:parent) { BasicModel.new }
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
  end
end
