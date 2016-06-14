require 'spec_helper'

describe CsvRowModel::Import::Attributes do
  let(:import_row_model_class) { BasicImportModel }
  let(:source_row)         { %w[1.01 b] }
  let(:instance)           { import_row_model_class.new(source_row) }

  describe "instance" do
    describe "#cells" do
      subject { instance.cells }

      it "returns a hash of cells mapped to their column_name" do
        expect(subject.keys).to eql import_row_model_class.column_names
        expect(subject.values.map(&:class)).to eql [CsvRowModel::Import::Cell] * 2
      end

      context "invalid and invalid csv_string_model" do
        let(:import_row_model_class) do
          Class.new(BasicImportModel) do
            validates :string1, presence: true
            csv_string_model { validates :string2, presence: true }
          end
        end
        let(:source_row) { [] }

        it "passes the csv_string_model.errors to _cells" do
          expect(instance).to receive(:_cells).with(no_args).once.and_call_original # for csv_string_model
          expect(instance).to receive(:_cells).once do |errors|
            expect(errors.messages).to eql(string2: ["can't be blank"])
            {} # return empty hash to keep calling API
          end
          subject
        end

        it "returns the cells with the right attributes" do
          values = subject.values
          expect(values.map(&:column_name)).to eql %i[string1 string2]
          expect(values.map(&:source_value)).to eql [nil, nil]
          expect(values.map(&:csv_string_model_errors)).to eql [[], ["can't be blank"]]
        end
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns the attributes hash" do
        # 2 attributes * (1 for csv_string_model + 1 for original_attributes)
        expect(import_row_model_class).to receive(:format_cell).exactly(4).times.and_call_original
        expect(subject).to eql(string1: '1.01', string2: 'b')
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

      let(:import_row_model_class) do
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
    let(:import_row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
      end
    end

    describe ":column" do
      context "when module included before and after #column call" do
        let(:import_row_model_class) do
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

      context "with method defined before column" do
        let(:import_row_model_class) do
          Class.new do
            def string1; "custom1" end
            def string2; "custom2" end

            include CsvRowModel::Model
            column :string1
            include CsvRowModel::Import
            column :string2
          end
        end

        it "does not override those methods" do
          expect(instance.string1).to eql 'custom1'
          expect(instance.string2).to eql 'custom2'
        end
      end
    end

    describe "::merge_options" do
      subject { import_row_model_class.send(:merge_options, :waka, type: Integer, validate_type: true) }

      before { import_row_model_class.send(:column, :waka, original_options) }
      let(:original_options) { {} }

      it "adds validations" do
        expect(import_row_model_class).to_not receive(:define_method)
        expect(import_row_model_class.csv_string_model_class).to receive(:add_type_validation).once.and_call_original
        subject
      end

      context "with original_options has validate_type" do
        let(:original_options) { { type: Integer, validate_type: true } }

        it "doesn't add validations" do
          expect(import_row_model_class).to_not receive(:define_method)
          expect(import_row_model_class.csv_string_model_class).to_not receive(:add_type_validation)

          subject
        end
      end
    end

    describe "::define_attribute_method" do
      it "does not do anything the second time" do
        expect(import_row_model_class).to receive(:define_method).with(:waka).once.and_call_original
        expect(import_row_model_class.csv_string_model_class).to receive(:add_type_validation).with(:waka, nil).once
        expect(import_row_model_class).to receive(:define_method).with(:waka2).once.and_call_original
        expect(import_row_model_class.csv_string_model_class).to receive(:add_type_validation).with(:waka2, nil).once

        import_row_model_class.send(:define_attribute_method, :waka)
        import_row_model_class.send(:define_attribute_method, :waka)
        import_row_model_class.send(:define_attribute_method, :waka2)
        import_row_model_class.send(:define_attribute_method, :waka2)
      end
    end
  end
end
