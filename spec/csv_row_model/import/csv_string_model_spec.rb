require 'spec_helper'

describe CsvRowModel::Import::CsvStringModel do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:klass) { BasicImportModel }
    let(:instance) { klass.new(source_row, options) }

    describe "#csv_string_model" do
      subject { instance.csv_string_model }
      it "returns csv_string_model with methods working" do
        expect(subject.string1).to eql "1.01"
        expect(subject.string2).to eql "b"
      end

      context "with format_cell" do
        it "should format_cell first" do
          expect(klass).to receive(:format_cell).with("1.01", :string1, 0, kind_of(OpenStruct)).and_return(nil)
          expect(klass).to receive(:format_cell).with("b", :string2, 1, kind_of(OpenStruct)).and_return(nil)
          expect(subject.string1).to eql nil
          expect(subject.string2).to eql nil
        end
      end
    end

    describe "#valid?" do
      subject { instance.valid? }
      let(:klass) do
        Class.new do
          include CsvRowModel::Model
          include CsvRowModel::Import

          column :id

          def self.name; "TwoLayerValid" end
        end
      end

      context "with 1 validation" do
        before do
          klass.class_eval { validates :id, presence: true }
        end

        it "works" do
          expect(subject).to eql true
        end

        context "with empty row" do
          let(:source_row) { %w[] }

          it "works" do
            expect(subject).to eql false
          end
        end
      end

      context "when setting default, but invalid csv_string_model validation" do
        let(:source_row) { ["1", ""]}

        before do
          klass.class_eval do
            column :name, default: "the default!"
            csv_string_model { validates :name, presence: true }
          end
        end

        it "returns just invalid" do
          expect(subject).to eql false
          expect(instance.errors.full_messages).to eql ["Name can't be blank"]
        end
      end

      context "overriding validations" do
        before do
          klass.class_eval do
            validates :id, length: { minimum: 5 }
            csv_string_model { validates :id, presence: true }
          end
        end

        it "takes the csv_string_model_class validation first then the row_model validation" do
          expect(subject).to eql false
          expect(instance.errors.full_messages).to eql ["Id is too short (minimum is 5 characters)"]
        end

        context "with empty row" do
          let(:source_row) { [''] }

          it "just shows the csv_string_model_class validation" do
            expect(subject).to eql false
            expect(instance.errors.full_messages).to eql ["Id can't be blank"]
          end
        end

        context "with errors has a key with empty value" do
          before do
            expect(instance.csv_string_model).to receive(:valid?).at_least(1).times.and_wrap_original do |original, *args|
              result = original.call(*args)
              # this makes instance.csv_string_model.errors.messages = { id: [] }
              instance.csv_string_model.errors[:id]
              result
            end
          end

          it "still shows the non-string validation" do
            expect(subject).to eql false
            expect(instance.csv_string_model.errors.messages).to eql(id: [])
            expect(instance.errors.full_messages).to eql ["Id is too short (minimum is 5 characters)"]
          end
        end
      end

      context "with warnings" do
        before do
          klass.class_eval do
            warnings { validates :id, length: { minimum: 5 } }
            csv_string_model do
              warnings { validates :id, presence: true }
            end
          end
        end

        context "with empty row" do
          let(:source_row) { [''] }

          it "just shows the csv_string_model_class validation" do
            expect(subject).to eql true
            expect(instance.safe?).to eql false
            expect(instance.warnings.full_messages).to eql ["Id can't be blank"]
          end
        end
      end
    end
  end

  describe described_class::Model do
    describe "instance" do
      let(:instance) { described_class.new(string1: "abc", string2: "efg") }

      describe "attribute methods" do
        it "works" do
          expect(instance.string1).to eql "abc"
          expect(instance.string2).to eql "efg"
        end
      end
    end

    describe "class" do
      describe "::add_type_validation" do
        let(:klass) { Class.new(described_class) }
        subject { klass.add_type_validation :string1, options }


        described_class::PARSE_VALIDATION_CLASSES.each do |type|
          context "with #{type} type" do
            let(:options) { { type: type, validate_type: true } }

            it "adds the validator" do
              subject
              validators = klass._validators[:string1]
              expect(validators.size).to eql 1
              expect(validators.first.class.to_s).to eql "#{type}FormatValidator"
            end
          end
        end

        context "with no type" do
          subject { klass.add_type_validation :string1, validate_type: true }
          it "raises exception" do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        describe "#valid?" do
          subject { instance.valid? }
          before { klass.add_type_validation :string1, type: Integer, validate_type: true }
          let(:instance) { klass.new(string1: "abc") }

          it "validates non Integer" do
            expect(subject).to eql false
          end

          context "when attribute is blank" do
            let(:instance) { klass.new(string1: "") }

            it "doesn't validate" do
              expect(subject).to eql true
            end
          end
        end
      end
    end
  end
end