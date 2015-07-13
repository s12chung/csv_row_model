require 'spec_helper'

describe CsvRowModel::Import do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:import_model_klass) { BasicImportModel }
    let(:instance) { import_model_klass.new(source_row, options) }

    describe "attribute methods" do
      subject { instance.string1 }

      it "calls format_cell and returns the result" do
        expect(import_model_klass).to receive(:format_cell).with("1.01", :string1, 0).and_return "waka"
        expect(subject).to eql "waka"
      end

      context "when included after #column call" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model

            column :string1

            include CsvRowModel::Import
          end
        end

        it "works" do
          expect(subject).to eql "1.01"
        end
      end


      context "when included before #column call" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1
          end
        end

        it "works" do
          expect(subject).to eql "1.01"
        end
      end

      {
        nil => "1.01",
        String => "1.01",
        Integer => 1,
        Float => 1.01
      }.each do |type, expected_result|
        context "with #{type.nil? ? "nil" : type} type" do
          let(:import_model_klass) do
            Class.new do
              include CsvRowModel::Model
              include CsvRowModel::Import

              column :string1, type: type
            end
          end

          it "returns the parsed type" do
            expect(subject).to eql expected_result
          end
        end
      end

      context "with Date type" do
        let(:source_row) { %w[15/12/30 b] }

        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, type: Date
          end
        end

        it "returns the correct date" do
          expect(subject).to eql Date.new(2015,12,30)
        end
      end

      context "with invalid type" do
        let(:source_row) { %w[15/12/30 b] }

        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, type: Object
          end
        end

        it "raises exception" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "with parse option" do
        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, parse: ->(s) { "haha" }
          end
        end

        it "returns what the parse returns" do
          expect(subject).to eql "haha"
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
  end
end