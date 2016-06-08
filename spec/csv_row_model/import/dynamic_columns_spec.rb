require 'spec_helper'

describe CsvRowModel::Import::DynamicColumns do
  let(:dynamic_source_headers) { %w[Organized Clean Punctual Strong Crazy Flexible] }
  let(:headers) { dynamic_source_headers }

  let(:dynamic_source_row) { %w[Yes Yes No Yes Yes No] }
  let(:source_row) { dynamic_source_row }

  let(:instance) { import_model_class.new(source_row, source_header: headers) }

  let(:import_model_base_class) do
    Class.new do
      include CsvRowModel::Model
    end
  end
  let(:import_model_class) do
    Class.new(import_model_base_class) do
      include CsvRowModel::Import
      dynamic_column :skills
    end
  end

  let(:original_attributes) { { skills: dynamic_source_row }  }

  describe "attribute methods" do
    subject { instance.skills }

    it 'works' do
      expect(subject).to eql(dynamic_source_row)
    end

    context "when defined before Import" do
      let(:import_model_class) do
        Class.new(import_model_base_class) do
          dynamic_column :skills
          include CsvRowModel::Import
        end
      end

      it "works" do
        expect(subject).to eql(dynamic_source_row)
      end
    end

    context "when overwritten singular method" do
      context "when defined before Import" do
        let(:import_model_class) do
          Class.new(import_model_base_class) do
            dynamic_column :skills
            include CsvRowModel::Import

            def skill(value, skill_name)
              value == "Yes" ? skill_name : nil
            end

            class << self
              def format_dynamic_column_cells(cells, column_name, column_index, context)
                cells.compact
              end
            end
          end
        end

        it "works" do
          expect(subject).to eql(["Organized", "Clean", "Strong", "Crazy"])
        end
      end
    end
  end

  shared_examples "column dependent methods" do
    describe "#dynamic_source_headers" do
      subject { instance.dynamic_source_headers }

      it "returns the dynamic part of the headers" do
        expect(subject).to eql dynamic_source_headers
      end

      context "for no dynamic classes" do
        let(:import_model_class) { BasicImportModel }
        it "returns empty arry" do
          expect(subject).to eql []
        end
      end
    end

    describe "#dynamic_source_row" do
      subject { instance.dynamic_source_row }

      it "returns the dynamic part of source row" do
        expect(subject).to eql dynamic_source_row
      end

      context "for no dynamic classes" do
        let(:import_model_class) { BasicImportModel }
        it "returns empty arry" do
          expect(subject).to eql []
        end
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns all attributes including the dynamic columns" do
        expect(subject).to eql original_attributes
      end
    end

    describe "#original_attribute" do
      it "works with invalid column name" do
        expect(instance.original_attribute(:invalid_column)).to eql nil
      end

      it "works with dynamic_column" do
        expect(instance.original_attribute(:skills)).to eql dynamic_source_row
      end

      it "calls ::format_dynamic_column_cells" do
        index = import_model_class == DynamicColumnImportModel ? 2 : 0
        expect(instance.class).to receive(:format_dynamic_column_cells)
                                    .with(dynamic_source_row, :skills, index,kind_of(OpenStruct))
                                    .and_return(%w[a b c])
        expect(instance.original_attribute(:skills)).to eql %w[a b c]
      end
    end

    describe "class" do
      describe "::dynamic_source_headers" do
        subject { import_model_class.dynamic_source_headers headers }

        it "returns dynamic part of the headers" do
          expect(subject).to eql dynamic_source_headers
        end

        context "for no dynamic classes" do
          let(:import_model_class) { BasicImportModel }
          it "returns empty arry" do
            expect(subject).to eql []
          end
        end
      end
    end
  end

  include_examples "column dependent methods"

  context "with columns defined" do
    let(:import_model_class) { DynamicColumnImportModel }
    let(:headers)    { %w[first_name last_name] + dynamic_source_headers }
    let(:source_row) { %w[Mario Italian] + dynamic_source_row }
    let(:original_attributes) { { first_name: "Mario", last_name: "Italian", skills: dynamic_source_row } }

    include_examples "column dependent methods"

    describe "#original_attribute" do
      it "works with basic column name" do
        expect(instance.original_attribute(:first_name)).to eql "Mario"
      end
    end
  end
end
