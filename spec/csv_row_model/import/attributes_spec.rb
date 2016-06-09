require 'spec_helper'

describe CsvRowModel::Import::Attributes do
  let(:import_model_klass) { BasicImportModel }
  let(:instance)           { import_model_klass.new(source_row, options) }
  let(:source_row)         { %w[1.01 b] }
  let(:options)            { {} }

  describe "instance" do
    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns the attributes hash" do
        # 2 attributes * (1 for csv_string_model + 1 for original_attributes)
        expect(import_model_klass).to receive(:format_cell).exactly(4).times.and_call_original
        expect(instance.original_attributes).to eql(string1: '1.01', string2: 'b')
      end
    end

    describe "#original_attribute" do
      subject { instance.original_attribute(:string1) }

      it "works" do
        expect(subject).to eql "1.01"
      end

      context "invalid column_name" do
        subject { instance.original_attribute(:not_a_column) }
        it "works" do
          expect(subject).to eql nil
        end
      end
    end

    describe "#default_changes" do
      subject { instance.default_changes }

      let(:import_model_klass) do
        Class.new(BasicImportModel) do
          merge_options :string1, default: 123
          def self.format_cell(*args); nil end
        end
      end

      it "sets the default" do
        expect(subject).to eql(string1: [nil, 123])
      end
    end
  end

  describe "class" do
    let(:import_model_klass) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
      end
    end

    describe ":column" do
      context "when included before and after #column call" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            column :string1
            include CsvRowModel::Import
            column :string2
          end
        end

        it "works" do
          expect(instance.string1).to eql "1.01"
          expect(instance.string2).to eql "b"
        end
      end
    end

    describe "::merge_options" do
      subject { import_model_klass.send(:merge_options, :waka, type: Integer, validate_type: true) }

      before { import_model_klass.send(:column, :waka, original_options) }
      let(:original_options) { {} }

      it "adds validations" do
        expect(import_model_klass).to_not receive(:define_method)
        expect(import_model_klass.csv_string_model_class).to receive(:add_type_validation).once.and_call_original
        subject
      end

      context "with original_options has validate_type" do
        let(:original_options) { { type: Integer, validate_type: true } }

        it "doesn't add validations" do
          expect(import_model_klass).to_not receive(:define_method)
          expect(import_model_klass.csv_string_model_class).to_not receive(:add_type_validation)

          subject
        end
      end
    end

    describe "::define_attribute_method" do
      it "does not do anything the second time" do
        expect(import_model_klass).to receive(:define_method).with(:waka).once.and_call_original
        expect(import_model_klass.csv_string_model_class).to receive(:add_type_validation).with(:waka, nil).once
        expect(import_model_klass).to receive(:define_method).with(:waka2).once.and_call_original
        expect(import_model_klass.csv_string_model_class).to receive(:add_type_validation).with(:waka2, nil).once

        import_model_klass.send(:define_attribute_method, :waka)
        import_model_klass.send(:define_attribute_method, :waka)
        import_model_klass.send(:define_attribute_method, :waka2)
        import_model_klass.send(:define_attribute_method, :waka2)
      end
    end
  end
end
