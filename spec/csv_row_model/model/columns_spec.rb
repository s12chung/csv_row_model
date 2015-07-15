require 'spec_helper'

describe CsvRowModel::Model::Columns do
  describe "instance" do
    let(:options) { {} }
    let(:instance) { BasicModel.new(options) }

    before do
      instance.define_singleton_method(:string1) { "haha" }
      instance.define_singleton_method(:string2) { "baka" }
    end

    describe "#attributes" do
      subject { instance.attributes }

      it "returns the map of column_name => public_send(column_name)" do
        expect(instance.attributes).to eql( string1: "haha", string2: "baka" )
      end
    end

    describe "#to_json" do
      subject { instance.attributes }

      it "returns the attributes json" do
        expect(instance.to_json).to eql(instance.attributes.to_json)
      end
    end
  end

  describe "class" do
    describe "::column_names" do
      specify { expect(BasicModel.column_names).to eql %i[string1 string2] }
    end
  end
end