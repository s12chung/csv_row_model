require 'spec_helper'

describe CsvRowModel::Import::DynamicColumnCell do
  describe "instance" do
    let(:instance) { described_class.new(:skills, source_headers, source_cells, row_model) }

    let(:source_headers) { %w[Organized Clean Punctual Strong Crazy Flexible] }
    let(:source_cells) { %w[Yes Yes No Yes Yes No] }
    let(:row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
        dynamic_column :skills
      end
    end
    let(:row_model) { row_model_class.new }

    describe "#unformatted_value" do
      subject { instance.unformatted_value }

      it "returns an array of the formatted_cell" do
        expect(instance).to receive(:formatted_cells).and_call_original
        expect(instance).to receive(:formatted_headers).and_call_original

        expect(subject).to eql source_cells
      end

      context "with process method defined" do
        before do
          row_model_class.class_eval do
            def skill(formatted_cell, source_headers);  "#{formatted_cell}__#{source_headers}" end
          end
        end

        it "return an array of the result of the process method" do
          expect(subject).to eql ["Yes__Organized", "Yes__Clean", "No__Punctual", "Yes__Strong", "Yes__Crazy", "No__Flexible"]
        end
      end
    end

    describe "#formatted_cells" do
      it_behaves_like "formatted_cells_method", CsvRowModel::Import, [
        "Yes__skills__0__#<OpenStruct>",
        "Yes__skills__1__#<OpenStruct>",
        "No__skills__2__#<OpenStruct>",
        "Yes__skills__3__#<OpenStruct>",
        "Yes__skills__4__#<OpenStruct>",
        "No__skills__5__#<OpenStruct>"
      ]
    end

    describe "#formatted_headers" do
      subject { instance.formatted_headers }

      before do
        row_model_class.class_eval do
          def self.format_dynamic_column_header(*args); args.join("__") end
        end
      end

      it "returns an array of the formatted_cells" do
        expect(subject).to eql [
                                 "Organized__skills__0__0__#<OpenStruct>",
                                 "Clean__skills__0__1__#<OpenStruct>",
                                 "Punctual__skills__0__2__#<OpenStruct>",
                                 "Strong__skills__0__3__#<OpenStruct>",
                                 "Crazy__skills__0__4__#<OpenStruct>",
                                 "Flexible__skills__0__5__#<OpenStruct>"
                               ]
      end

      context "with regular column defined" do
        let(:row_model_class) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import
            column :string1
            dynamic_column :skills
          end
        end

        it "it bumps the index up for the dynamic_column_index" do
          expect(subject.first).to eql "Organized__skills__1__0__#<OpenStruct>"
        end
      end
    end
  end

  describe "class" do
    describe "::define_process_cell" do
      let(:klass) { Class.new { include CsvRowModel::Concerns::HiddenModule } }
      subject { described_class.define_process_cell(klass, :somethings) }

      it "adds the process method to the class" do
        subject
        expect(klass.new.something("a", "b")).to eql "a"
      end
    end
  end
end