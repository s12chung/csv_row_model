require 'spec_helper'

describe CsvRowModel::Import do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:import_model_klass) { BasicImportModel }
    let(:instance) { import_model_klass.new(source_row, options) }

    describe "#initialize" do
      subject { instance }

      context "should set the child" do
        let(:parent_instance) { BasicModel.new }
        let(:options) { { parent:  parent_instance } }
        specify { expect(subject.child?).to eql true }
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

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
            expect(subject).to eql(string1: "123")
          end
        end

        context "when returns a parsable string" do
          let(:source_row) { ["123"] }
          it "returns the default" do
            expect(subject).to eql(string1: "123".to_f)
          end
        end
      end

      it "calls format_cell and returns the result" do
        expect(import_model_klass).to receive(:format_cell).with("1.01", :string1, 0).and_return "waka"
        expect(import_model_klass).to receive(:format_cell).with("b", :string2, 1).and_return "baka"
        expect(subject).to eql(string1: "waka", string2: "baka")
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

    describe "#mapped_row" do
      subject { instance.mapped_row }
      it "returns a map of `column_name => source_row[index_of_column_name]" do
        expect(subject).to eql(string1: "1.01", string2: "b")
      end
    end

    describe "#free_previous" do
      let(:options) { { previous: import_model_klass.new([]) } }

      subject { instance.free_previous }

      it "makes previous nil" do
        expect(instance.previous).to_not eql nil
        subject
        expect(instance.previous).to eql nil
      end
    end
  end

  describe "class" do
    describe "::format_cell" do
      let(:cell) { "the_cell" }
      subject { BasicImportModel.format_cell(cell, nil, nil) }

      it "returns the cell" do
        expect(subject).to eql cell
      end
    end

    describe "::default_lambda" do
      let(:source_row) { ['a', nil] }

      context "try to looking for in another field" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1
            column :string2, default: -> { string1 }
          end
        end

        it "returns the default", skip: true do
          expect(
            import_model_klass.new(source_row).original_attributes[:string1]
          ).to eql('a')
          expect(
            import_model_klass.new(source_row).original_attributes[:string2]
          ).to eql('a')
        end
      end
    end

  end
end
