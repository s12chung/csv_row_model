require 'spec_helper'

describe CsvRowModel::Import::FileModel do
  let(:context) {{}}

  describe "class" do
    let(:import_model_klass) { FileImportModel }

    describe "#header_matchers" do
      let(:header_matchers) { [/^:: - string1 - ::$/i, /^:: - string2 - ::$/i] }

      subject { import_model_klass.header_matchers(context) }

      it{ expect(subject).to eql header_matchers }
    end

    describe "#index_header_match" do


      context 'when is a match' do
        let(:some_cell) { ':: - string2 - ::' }

        subject { import_model_klass.index_header_match(some_cell, context) }

        it{ expect(subject).to eql 1 }
      end

      context 'when is not a match' do
        let(:some_cell) { 'String 3'}

        subject { import_model_klass.index_header_match(some_cell, context) }

        it{ expect(subject).to be_nil }
      end
    end
  end
end
