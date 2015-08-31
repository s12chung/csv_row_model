require 'spec_helper'

describe CsvRowModel::Import::SingleModel do
  describe "class" do
    let(:import_model_klass) { BasicRowImportModel }

    describe "#header_matchers" do
      let(:header_matchers) { [/string1/i, /String 2|string two/i] }

      subject { import_model_klass.header_matchers }

      it{ expect(subject).to eql header_matchers }
    end

    describe "#index_header_match" do

      context 'when is a match' do
        let(:some_cell) { 'String Two'}

        subject { import_model_klass.index_header_match(some_cell) }

        it{ expect(subject).to eql 1 }
      end

      context 'when is not a match' do
        let(:some_cell) { 'String 3'}

        subject { import_model_klass.index_header_match(some_cell) }

        it{ expect(subject).to be_nil }
      end
    end
  end
end