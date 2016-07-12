require 'spec_helper'

dynamic_column_source_headers = %w[Organized Clean Punctual Strong Crazy Flexible]
dynamic_column_source_cells = %w[Yes Yes No Yes Yes No]

describe CsvRowModel::Import::DynamicColumns do
  let(:row_model_class) do
    Class.new do
      include CsvRowModel::Model
      include CsvRowModel::Import
      dynamic_column :skills
    end
  end

  let(:instance) { row_model_class.new(source_row, source_headers: headers) }
  let(:headers) { dynamic_column_source_headers }
  let(:source_row) { dynamic_column_source_cells }

  shared_context "standard columns defined" do
    let(:row_model_class) { DynamicColumnImportModel }
    let(:headers)    { %w[first_name last_name] + dynamic_column_source_headers }
    let(:source_row) { %w[Mario Italian] + dynamic_column_source_cells }
    let(:original_attributes) {  }
  end

  describe "instance" do
    describe "#cell_objects" do
      it_behaves_like "cell_objects_method",
                      %i[skills],
                      CsvRowModel::Import::DynamicColumnCell => 1

      with_context "standard columns defined" do
        it_behaves_like "cell_objects_method",
                        %i[first_name last_name skills],
                        CsvRowModel::Import::Cell => 2,
                        CsvRowModel::Import::DynamicColumnCell => 1
      end
    end

    describe "#dynamic_Column_cell_objects" do
      with_this_then_context "standard columns defined" do
        it_behaves_like "cell_objects_method",
                        %i[skills],
                        { CsvRowModel::Import::DynamicColumnCell => 1 },
                        :dynamic_column_cell_objects
      end
    end

    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }
      let(:row_model_class) { Class.new(super()) { def self.format_cell(*args); args.join("__") end } }

      it "returns all attributes of dynamic columns" do
        expect(subject).to eql(skills: ["Yes__skills__0__#<OpenStruct>", "Yes__skills__1__#<OpenStruct>", "No__skills__2__#<OpenStruct>", "Yes__skills__3__#<OpenStruct>", "Yes__skills__4__#<OpenStruct>", "No__skills__5__#<OpenStruct>"])
      end

      with_context "standard columns defined" do
        let(:row_model_class) { Class.new(DynamicColumnImportModel) { def self.format_cell(*args); args.join("__") end } }

        it "returns all attributes including the dynamic columns" do
          expect(subject).to eql(
                               first_name: "Mario__first_name__0__#<OpenStruct>",
                               last_name: "Italian__last_name__1__#<OpenStruct>",
                               skills: ["Yes__skills__2__#<OpenStruct>", "Yes__skills__3__#<OpenStruct>", "No__skills__4__#<OpenStruct>", "Yes__skills__5__#<OpenStruct>", "Yes__skills__6__#<OpenStruct>", "No__skills__7__#<OpenStruct>"]
                             )
        end
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

    describe "#formatted_dynamic_column_headers" do
      subject { instance.formatted_dynamic_column_headers }
      let(:row_model_class) { Class.new(super()) { def self.format_dynamic_column_header(*args); args.join("__") end } }

      it "returns the formatted_headers" do
        expect(subject).to eql ["Organized__skills__0__0__#<OpenStruct>", "Clean__skills__0__1__#<OpenStruct>", "Punctual__skills__0__2__#<OpenStruct>", "Strong__skills__0__3__#<OpenStruct>", "Crazy__skills__0__4__#<OpenStruct>", "Flexible__skills__0__5__#<OpenStruct>"]
      end
    end

    describe "#dynamic_column_source_headers" do
      subject { instance.dynamic_column_source_headers }
      it("calls the class method") { expect(row_model_class).to receive(:dynamic_column_source_headers).with(headers); subject }
    end

    describe "#dynamic_column_source_cells" do
      subject { instance.dynamic_column_source_cells }
      it("calls the class method") { expect(row_model_class).to receive(:dynamic_column_source_cells).with(source_row); subject }
    end

    describe "#original_attribute" do
      subject { instance.original_attribute(:skills) }

      it_behaves_like "cell_object_attribute", :original_attribute, :value, skills: dynamic_column_source_cells

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
    describe "::dynamic_column_source_headers" do
      subject { row_model_class.dynamic_column_source_headers headers  }

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

    describe "::dynamic_column_source_cells" do
      subject { row_model_class.dynamic_column_source_cells source_row }

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

    describe "::dynamic_column" do
      it_behaves_like "dynamic_column_method", CsvRowModel::Import, dynamic_column_source_cells
    end

    describe "::define_dynamic_attribute_method" do
      subject { row_model_class.send(:define_dynamic_attribute_method, :skills) }

      it "makes an attribute that calls original_attribute" do
        subject
        expect(instance).to receive(:original_attribute).with(:skills).and_return("tested")
        expect(instance.skills).to eql "tested"
      end
    end
  end
end
