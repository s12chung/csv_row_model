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
    let(:klass) { BasicModel }

    describe "::column_names" do
      subject { klass.column_names }
      specify { expect(subject).to eql %i[string1 string2] }
    end

    describe "::options" do
      let(:options) { { type: Integer, validate_type: true } }
      let(:klass) do
        o = options
        Class.new do
          include CsvRowModel::Model
          column :blah, o
        end
      end

      subject { klass.options(:blah) }

      it "returns the options for the column" do
        expect(subject).to eql options
      end
    end

    describe "::column" do
      context "with invalid option" do
        subject do
          Class.new do
            include CsvRowModel::Model
            column :blah, invalid_option: true
          end
        end

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    describe "::format_header" do
      let(:header) { 'user_name' }
      subject { BasicModel.format_header(header) }

      it "returns the header" do
        expect(subject).to eql header
      end
    end

    describe "::column_headers" do
      let(:column_headers) { [:string1, 'String 2'] }
      subject { BasicModel.column_headers }

      it "returns an array with header column names" do
        expect(subject).to eql column_headers
      end
    end
  end
end