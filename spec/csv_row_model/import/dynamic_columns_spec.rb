require 'spec_helper'

dynamic_column_source_headers = %w[Organized Clean Punctual Strong Crazy Flexible]
dynamic_column_source_cells = %w[Yes Yes No Yes Yes No]

describe CsvRowModel::Import::DynamicColumns do
  let(:instance) { row_model_class.new(source_row, source_header: headers) }
  let(:headers) { dynamic_column_source_headers }
  let(:source_row) { dynamic_column_source_cells }

  describe "instance" do
    let(:row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
        dynamic_column :skills
      end
    end

    shared_context "standard columns defined" do
      let(:row_model_class) { DynamicColumnImportModel }
      let(:headers)    { %w[first_name last_name] + dynamic_column_source_headers }
      let(:source_row) { %w[Mario Italian] + dynamic_column_source_cells }
      let(:original_attributes) {  }
    end

    describe "#cells" do
      it_behaves_like "cells_method",
                      %i[skills],
                      CsvRowModel::Import::DynamicColumnCell => 1

      with_context "standard columns defined" do
        it_behaves_like "cells_method",
                        %i[first_name last_name skills],
                        CsvRowModel::Import::Cell => 2,
                        CsvRowModel::Import::DynamicColumnCell => 1
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "returns all attributes of dynamic columns" do
        expect(subject).to eql(skills: dynamic_column_source_cells)
      end

      with_context "standard columns defined" do
        it "returns all attributes including the dynamic columns" do
          expect(subject).to eql( first_name: "Mario", last_name: "Italian", skills: dynamic_column_source_cells )
        end
      end
    end

    describe "#dynamic_column_source_headers" do
      subject { instance.dynamic_column_source_headers }

      with_this_then_context "standard columns defined" do
        it "returns the dynamic part of the headers" do
          expect(subject).to eql dynamic_column_source_headers
        end

        context "for no dynamic classes" do
          let(:row_model_class) { BasicImportModel }
          it "returns empty array" do
            expect(subject).to eql []
          end
        end
      end
    end

    describe "#dynamic_column_source_cells" do
      subject { instance.dynamic_column_source_cells }

      with_this_then_context "standard columns defined" do
        it "returns the dynamic part of source row" do
          expect(subject).to eql dynamic_column_source_cells
        end

        context "for no dynamic classes" do
          let(:row_model_class) { BasicImportModel }
          it "returns empty array" do
            expect(subject).to eql []
          end
        end
      end
    end

    describe "#original_attribute" do
      subject { instance.original_attribute(:skills) }

      it_behaves_like "cell_attribute", :original_attribute, :value, skills: dynamic_column_source_cells

      context "with all overrides" do
        let(:row_model_class) do
          Class.new do
            include CsvRowModel::Model
            dynamic_column :skills
            include CsvRowModel::Import

            def skill(value, skill_name)
              value == "Yes_f" ? skill_name : nil
            end

            class << self
              def format_dynamic_column_cells(cells, column_name, column_index, context); cells.compact end
              def format_cell(cell, column_name, column_index, context); "#{cell}_f" end
              def format_dynamic_column_header(header_model, column_name, dynamic_column_index, index_of_column, context); "f_#{header_model}" end
            end
          end
        end

        it "works" do
          expect(subject).to eql(["f_Organized", "f_Clean", "f_Strong", "f_Crazy"])
        end
      end
    end
  end

  describe "class" do
    describe "::dynamic_column" do
      it_behaves_like "dynamic_column_method", CsvRowModel::Import, dynamic_column_source_cells
    end
  end
end
