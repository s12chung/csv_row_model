require 'spec_helper'

describe CsvRowModel::Export::Attributes do
  let(:string1)            { 'Test 1' }
  let(:string2)            { 'Test 2' }
  let(:context)            {{}}
  let(:source_model)       { Model.new(string1, string2) }
  let(:instance)           { export_model_class.new(source_model, context) }

  let(:export_model_class) do
    Class.new(BasicExportModel) do
      def self.format_cell(cell, _column_name, _column_index)
        cell.upcase
      end
    end
  end

  describe '#attributes' do
    subject{ instance.attributes }

    it 'return an hash with model attribute values' do
      expect(subject).to eql({string1: 'Test 1', string2: 'Test 2'})
    end
  end

  describe '#formatted_attributes' do
    subject{ instance.formatted_attributes }

    it 'return an hash with model attribute values formatted' do
      expect(subject).to eql({string1: 'TEST 1', string2: 'TEST 2'})
    end
  end

end
