require 'spec_helper'

describe CsvRowModel::Export do
  let(:instance) { export_model_class.new(source_model, options) }

  context 'regular colums' do
    let(:options)      { {} }
    let(:source_model) { User.new('Mathias','Durgan') }

    context 'with column defined before including Export module' do
      let(:export_model_class) do
        Class.new do
          include CsvRowModel::Model # adds original column_method
          column :first_name # column_names += [:first_name]
          include CsvRowModel::Export # calls define_method for column_names.each (last_name does not exist)
          column :last_name # calls define_method for :last_name and column_names += [:last_name]
        end
      end

      it 'define_method should be called with all defined columns' do
        expect(instance.first_name).to eql 'Mathias'
        expect(instance.last_name).to  eql 'Durgan'
      end
    end
  end

  context 'dynamic colums' do
    let(:options)      { { skills: ['Organize'] } }
    let(:skill)        { Skill.new('Organize', false) }
    let(:source_model) { User.new('Mathias','Durgan',[skill]) }

    context 'with column defined before including Export module' do
      let(:export_model_class) do
        Class.new do
          include CsvRowModel::Model
          dynamic_column :skills
          include CsvRowModel::Export

          def skill(skill)
            source_model.skills.select { |s| s.name == skill }.shift.have
          end
        end
      end

      it 'define_method should be called with all defined columns' do
        expect(instance.skills).to be_present
        expect(instance.skills).to eql([false])
      end
    end
  end
end
