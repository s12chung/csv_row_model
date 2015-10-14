require 'spec_helper'

describe CsvRowModel::Import::Attributes do
  let(:instance) { import_model_klass.new(source_row, options) }

  context 'regular colums' do
    let(:source_row) { %w[1.01 b] }
    let(:options)    { {} }

    context 'with column included before and after including Import module' do
      let(:import_model_klass) do
        Class.new do
          include CsvRowModel::Model
          column :string1
          include CsvRowModel::Import
          column :string2
        end
      end

      it 'define_method should be called with all defined columns' do
        expect(instance.string1).to eql('1.01')
        expect(instance.string2).to eql('b')
      end
    end
  end

  context 'dynamic colums' do
    let(:source_row) { %w[Yes Yes No Yes Yes No] }
    let(:headers)    { %w[Organize Clean Punctual Strong Crazy Flexible] }
    let(:options)    { { source_header: headers } }

    context 'with dynamic column defined after including Import module' do
      let(:import_model_klass) do
        Class.new do
          include CsvRowModel::Model
          include CsvRowModel::Import

          dynamic_column :skills

          def skill(value, skill_name)
            value == 'No' ? nil : skill_name
          end
        end
      end

      it 'define_method should be called with all defined dynamic olumns' do
        expect(instance.skills).to be_present
        expect(instance.skills.compact).to eql(%w[Organize Clean Strong Crazy])
      end
    end
  end

end
