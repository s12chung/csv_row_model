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
    describe "#dynamic_Column_attribute_objects" do
      with_this_then_context "standard columns defined" do
        it_behaves_like "attribute_objects_method",
                        %i[skills],
                        { CsvRowModel::Import::DynamicColumnAttribute => 1 },
                        :dynamic_column_attribute_objects
      end
    end

    describe "#formatted_dynamic_column_headers" do
      subject { instance.formatted_dynamic_column_headers }
      let(:row_model_class) { Class.new(super()) { def self.format_dynamic_column_header(*args); args.join("__") end } }

      it "returns the formatted_headers" do
        expect(subject).to eql ["Organized__skills__0__#<OpenStruct>", "Clean__skills__0__#<OpenStruct>", "Punctual__skills__0__#<OpenStruct>", "Strong__skills__0__#<OpenStruct>", "Crazy__skills__0__#<OpenStruct>", "Flexible__skills__0__#<OpenStruct>"]
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
