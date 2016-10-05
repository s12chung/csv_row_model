require 'spec_helper'

describe CsvRowModel::Import::Attributes do
  let(:row_model_class) { Class.new BasicImportModel }
  let(:source_row) { %w[1.01 b] }
  let(:instance) { row_model_class.new(source_row) }

  describe "instance" do
    describe "#attribute_objects" do
      subject { instance.attribute_objects }

      it "returns a hash of cells mapped to their column_name" do
        expect(subject.keys).to eql row_model_class.column_names
        expect(subject.values.map(&:class)).to eql [CsvRowModel::Import::Attribute] * 2
      end

      context "invalid and invalid parsed_model" do
        let(:row_model_class) do
          Class.new(BasicImportModel) do
            validates :string1, presence: true
            parsed_model { validates :string2, presence: true }
          end
        end
        let(:source_row) { [] }

        it "passes the parsed_model.errors to _cells_objects" do
          expect(instance).to receive(:_attribute_objects).with(no_args).once.and_call_original # for parsed_model
          expect(instance).to receive(:_attribute_objects).once do |errors|
            expect(errors.messages).to eql(string2: ["can't be blank"])
            {} # return empty hash to keep calling API
          end
          subject
        end

        it "returns the cells with the right attributes" do
          values = subject.values
          expect(values.map(&:column_name)).to eql %i[string1 string2]
          expect(values.map(&:source_value)).to eql [nil, nil]
          expect(values.map(&:parsed_model_errors)).to eql [[], ["can't be blank"]]
        end
      end
    end

    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }
      let(:row_model_class) { Class.new(super()) { def self.format_cell(*args); args.join("__") end } }

      it "returns the formatted_headers" do
        expect(subject).to eql(string1: "1.01__string1__#<OpenStruct>", string2: "b__string2__#<OpenStruct>")
      end
    end

    describe "#default_changes" do
      subject { instance.default_changes }

      let(:row_model_class) do
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
    let(:row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
      end
    end

    it_behaves_like "defines_attributes_methods_safely", string1: "1.01", string2: "b"

    describe ":column" do
      it_behaves_like "column_method", CsvRowModel::Import, string1: "1.01", string2: "b"
    end

    describe "::merge_options" do
      subject { row_model_class.send(:merge_options, :waka, type: Integer, validate_type: true) }

      before { row_model_class.send(:column, :waka, original_options) }
      let(:original_options) { {} }

      it "adds validations" do
        expect(row_model_class).to_not receive(:define_proxy_method)
        expect(row_model_class.parsed_model_class).to receive(:add_type_validation).once.and_call_original
        subject
      end

      context "with original_options has validate_type" do
        let(:original_options) { { type: Integer, validate_type: true } }

        it "doesn't add validations" do
          expect(row_model_class).to_not receive(:define_proxy_method)
          expect(row_model_class.parsed_model_class).to_not receive(:add_type_validation)

          subject
        end
      end
    end

    describe "::define_attribute_method" do
      subject { row_model_class.send(:define_attribute_method, :waka) }
      before { expect(row_model_class.parsed_model_class).to receive(:add_type_validation).with(:waka, nil).once }

      it "makes an attribute that calls original_attribute" do
        subject
        expect(instance).to receive(:original_attribute).with(:waka).and_return("tested")
        expect(instance.waka).to eql "tested"
      end

      context "with another validation added" do
        before { expect(row_model_class.parsed_model_class).to receive(:add_type_validation).with(:waka2, nil).once }
        it_behaves_like "define_attribute_method"
      end
    end
  end
end
