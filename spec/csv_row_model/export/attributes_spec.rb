require 'spec_helper'

describe CsvRowModel::Export::Attributes do
  let(:source_model) { Model.new('a', 'b') }
  let(:instance) { export_row_model_class.new(source_model) }

  describe 'instance' do
    let(:export_row_model_class) { BasicExportModel }

    describe "#cells" do
      subject { instance.cells }

      it "returns a hash of cells mapped to their column_name" do
        expect(subject.keys).to eql export_row_model_class.column_names
        expect(subject.values.map(&:class)).to eql [CsvRowModel::Export::Cell] * 2
      end
    end

    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }

      it "returns the attributes hash" do
        expect(export_row_model_class).to receive(:format_cell).exactly(2).times.and_call_original
        expect(subject).to eql(string1: 'a', string2: 'b')
      end
    end

    {
      formatted_attribute: :value,
      source_attribute: :source_value
    }.each do |method, cell_method|
      describe "##{method}" do
        subject { instance.formatted_attribute(:string1) }

        it "works" do
          expect_any_instance_of(CsvRowModel::Export::Cell).to receive(cell_method).and_call_original
          expect(subject).to eql "a"
        end

        context "invalid column_name" do
          subject { instance.formatted_attribute(:not_a_column) }

          it "works" do
            expect(subject).to eql nil
          end
        end
      end
    end
  end

  describe 'class' do
    let(:export_row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Export
      end
    end

    describe "::column" do
      context 'with column defined before and after Export module' do
        let(:export_row_model_class) do
          Class.new do
            include CsvRowModel::Model
            column :string1
            include CsvRowModel::Export
            column :string2
          end
        end

        it 'works' do
          expect(instance.string1).to eql 'a'
          expect(instance.string2).to eql 'b'
        end
      end

      context "with method defined before column" do
        let(:export_row_model_class) do
          Class.new do
            def string1; "custom1" end
            def string2; "custom2" end

            include CsvRowModel::Model
            column :string1
            include CsvRowModel::Export
            column :string2
          end
        end

        it "does not override those methods" do
          expect(instance.string1).to eql 'custom1'
          expect(instance.string2).to eql 'custom2'
        end
      end
    end

    describe "::define_attribute_method" do
      it "does not do anything the second time" do
        expect(export_row_model_class).to receive(:define_method).with(:waka).once.and_call_original
        expect(export_row_model_class).to receive(:define_method).with(:waka2).once.and_call_original

        export_row_model_class.send(:define_attribute_method, :waka)
        export_row_model_class.send(:define_attribute_method, :waka)
        export_row_model_class.send(:define_attribute_method, :waka2)
        export_row_model_class.send(:define_attribute_method, :waka2)
      end
    end
  end
end
