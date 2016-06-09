require 'spec_helper'

describe CsvRowModel::Import::DynamicColumns do
  let(:instance) { import_model_class.new(source_row, source_header: headers) }

  let(:headers) { dynamic_column_source_headers }
  let(:dynamic_column_source_headers) { %w[Organized Clean Punctual Strong Crazy Flexible] }

  let(:source_row) { dynamic_column_source_cells }
  let(:dynamic_column_source_cells) { %w[Yes Yes No Yes Yes No] }

  let(:import_model_class) do
    Class.new do
      include CsvRowModel::Model
      include CsvRowModel::Import
      dynamic_column :skills
    end
  end

  let(:original_attributes) { { skills: dynamic_column_source_cells }  }

  describe "attribute methods" do
    subject { instance.skills }

    it 'works' do
      expect(subject).to eql(dynamic_column_source_cells)
    end

    context "with all overrides" do
      let(:import_model_class) do
        Class.new do
          include CsvRowModel::Model
          dynamic_column :skills
          include CsvRowModel::Import

          def skill(value, skill_name)
            value == "Yes_f" ? skill_name : nil
          end

          class << self
            def format_dynamic_column_cells(cells, column_name, column_index, context)
              cells.compact
            end

            def format_cell(cell, column_name, column_index, context)
              "#{cell}_f"
            end

            def format_dynamic_column_header(header_model, column_name, dynamic_column_index, index_of_column, context)
              "f_#{header_model}"
            end
          end
        end
      end

      it "works" do
        expect(subject).to eql(["f_Organized", "f_Clean", "f_Strong", "f_Crazy"])
      end
    end
  end

  shared_examples "column dependent methods" do
    describe "#cells" do
      subject { instance.cells }

      it "returns a hash of cells mapped to their column_name" do
        expect(subject.keys).to eql import_model_class.column_names + import_model_class.dynamic_column_names
        expect(subject.values.map(&:class)).to eql [CsvRowModel::Import::Cell] * import_model_class.columns.size +
                                                     [CsvRowModel::Import::DynamicColumnCell] *  import_model_class.dynamic_columns.size
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns all attributes including the dynamic columns" do
        expect(subject).to eql original_attributes
      end
    end

    describe "#dynamic_column_source_headers" do
      subject { instance.dynamic_column_source_headers }

      it "returns the dynamic part of the headers" do
        expect(subject).to eql dynamic_column_source_headers
      end

      context "for no dynamic classes" do
        let(:import_model_class) { BasicImportModel }
        it "returns empty arry" do
          expect(subject).to eql []
        end
      end
    end

    describe "#dynamic_column_source_cells" do
      subject { instance.dynamic_column_source_cells }

      it "returns the dynamic part of source row" do
        expect(subject).to eql dynamic_column_source_cells
      end

      context "for no dynamic classes" do
        let(:import_model_class) { BasicImportModel }
        it "returns empty arry" do
          expect(subject).to eql []
        end
      end
    end
  end

  include_examples "column dependent methods"

  context "with columns defined" do
    let(:import_model_class) { DynamicColumnImportModel }
    let(:headers)    { %w[first_name last_name] + dynamic_column_source_headers }
    let(:source_row) { %w[Mario Italian] + dynamic_column_source_cells }
    let(:original_attributes) { { first_name: "Mario", last_name: "Italian", skills: dynamic_column_source_cells } }

    include_examples "column dependent methods"
  end

  describe "class" do
    let(:import_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
      end
    end

    describe "::dynamic_column" do
      subject { import_model_class.send(:dynamic_column, :skills) }

      it "calls the right method and defines the method" do
        expect(import_model_class).to receive(:define_dynamic_attribute_method).with(:skills).and_call_original
        subject
        expect(instance.skills).to eql(dynamic_column_source_cells)
      end

      context "when defined before Import" do
        let(:import_model_class) do
          Class.new(Class.new { include CsvRowModel::Model }) do
            dynamic_column :skills
            include CsvRowModel::Import
          end
        end

        it "works" do
          expect(instance.skills).to eql(dynamic_column_source_cells)
        end
      end
    end
  end
end
