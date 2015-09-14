require 'spec_helper'

describe CsvRowModel::Import::Attributes do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:import_model_klass) { BasicImportModel }
    let(:instance) { import_model_klass.new(source_row, options) }

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns them" do
        expect(instance).to receive(:original_attribute).with(:string1).and_return "waka"
        expect(instance).to receive(:original_attribute).with(:string2).and_return "baka"
        expect(subject).to eql(string1: "waka", string2: "baka")
      end
    end

    describe "#original_attribute" do
      subject { instance.original_attribute(:string1) }

      it "calls format_cell and returns the result" do
        expect(import_model_klass).to receive(:format_cell).with("1.01", :string1, 0).and_return("waka").twice
        expect(import_model_klass).to receive(:format_cell).with("b", :string2, 1).and_return(nil).once
        expect(subject).to eql("waka")
      end

      context "with all options" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, default: -> { default }, parse: ->(s) { parse(s) }

            def default; "123" end
            def parse(s); s.to_f end
            def self.format_cell(*args); args.first end
          end
        end

        context "format_cell returns empty string" do
          let(:source_row) { [""] }

          it "returns the default" do
            expect(subject).to eql("123")
          end
        end

        context "when returns a parsable string" do
          let(:source_row) { ["123"] }
          it "returns the parsed result" do
            expect(subject).to eql("123".to_f)
          end
        end
      end

      context "with invalid csv_string_model" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, type: Integer, validate_type: true
          end
        end

        it "returns nil" do
          expect(subject).to eql(nil)
        end

        context "with default" do
          let(:import_model_klass) do
            Class.new do
              include CsvRowModel::Model
              include CsvRowModel::Import

              column :string1, type: Integer, validate_type: true, default: 123
            end
          end

          it "returns nil" do
            expect(subject).to eql(nil)
          end
        end
      end
    end

    describe "attribute methods" do
      subject { instance.string1 }

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

    describe "#default_changes" do
      subject { instance.default_changes }

      let(:import_model_klass) do
        Class.new do
          include CsvRowModel::Model
          include CsvRowModel::Import

          column :string1, default: 123

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

    describe "::format_cell" do
      let(:cell) { "the_cell" }
      subject { BasicImportModel.format_cell(cell, nil, nil) }

      it "returns the cell" do
        expect(subject).to eql cell
      end
    end

    describe "::default_lambda" do
      let(:instance) { import_model_klass.new(source_row) }

      context "when looking for in another field for default" do
        let(:source_row) { ['a', nil] }

        before do
          import_model_klass.class_eval do
            column :string1
            column :string2, default: -> { original_attribute(:string1) }
          end
        end

        it "returns the default" do
          expect(instance.original_attributes[:string1]).to eql('a')
          expect(import_model_klass.new(source_row).original_attributes[:string2]).to eql('a')
        end
      end
    end

    describe "::format_cell" do
      let(:cell) { "the_cell" }
      subject { BasicImportModel.format_cell(cell, nil, nil) }

      it "returns the cell" do
        expect(subject).to eql cell
      end
    end

    describe "::add_type_validation" do
      described_class::PARSE_VALIDATION_CLASSES.each do |type|
        context "with #{type} type" do
          subject { import_model_klass.class_eval { column :string1, type: type, validate_type: true } }

          it "adds the validator" do
            subject
            validators = import_model_klass.csv_string_model_class._validators[:string1]
            expect(validators.size).to eql 1
            expect(validators.first.class.to_s).to eql "#{type}FormatValidator"
          end
        end
      end

      context "when attribute is blank" do
        before { import_model_klass.class_eval { column :string1, type: Integer, validate_type: true } }
        let(:instance) { import_model_klass.new([""]) }

        subject { instance.valid? }

        it "doesn't validate" do
          expect(subject).to eql true
        end
      end

      context "with no type" do
        subject { import_model_klass.class_eval { column :string1, validate_type: true } }
        it "raises exception" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    describe "::parse_lambda" do
      let(:source_cell) { "1.01" }
      subject { import_model_klass.parse_lambda(:string1).call(source_cell) }

      {
        nil => "1.01",
        Boolean => true,
        String => "1.01",
        Integer => 1,
        Float => 1.01
      }.each do |type, expected_result|
        context "with #{type.nil? ? "nil" : type} type" do
          before { import_model_klass.class_eval { column :string1, type: type } }

          it "returns the parsed type" do
            expect(subject).to eql expected_result
          end
        end
      end

      context "with Date type" do
        let(:source_cell) { "15/12/30" }
        before { import_model_klass.class_eval { column :string1, type: Date }}

        it "returns the correct date" do
          expect(subject).to eql Date.new(2015,12,30)
        end
      end

      context "with invalid type" do
        before { import_model_klass.class_eval { column :string1, type: Object } }

        it "raises exception" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "with parse option" do
        before { import_model_klass.class_eval { column :string1, parse: ->(s) { "haha" } } }

        it "returns what the parse returns" do
          expect(subject).to eql "haha"
        end

        context "of Proc that accesses instance" do
          let(:instance) { import_model_klass.new([]) }
          subject { instance.instance_exec "", &import_model_klass.parse_lambda(:string1) }

          before do
            import_model_klass.class_eval do
              column :string1, parse: ->(s) { something }
              define_method(:something) { Random.rand }
            end
          end
          let(:random) { Random.rand }

          it "returns the default" do
            expect(Random).to receive(:rand).and_return(random)
            expect(subject).to eql random
          end
        end
      end

      context "with both option" do
        before { import_model_klass.class_eval { column :string1, type: Date, parse: ->(s) { "haha" } } }

        it "raises exception" do
          expect { subject }.to raise_error('You need either :parse OR :type but not both of them')
        end
      end

      context "with nil source cell" do
        let(:source_cell) { nil }

        described_class::CLASS_TO_PARSE_LAMBDA.keys.each do |type|
          context "with #{type.nil? ? "nil" : type} type" do
            before { import_model_klass.class_eval { column :string1, type: type } }

            it "doesn't return an exception" do
              expect { subject }.to_not raise_error
            end
          end
        end
      end
    end
  end
end