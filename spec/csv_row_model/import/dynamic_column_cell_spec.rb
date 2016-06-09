require 'spec_helper'

describe CsvRowModel::Import::DynamicColumnCell do
  describe "instance" do
    let(:instance) { described_class.new(:skills, source_headers, source_cells, row_model) }

    let(:source_headers) { %w[Organized Clean Punctual Strong Crazy Flexible] }
    let(:source_cells) { %w[Yes Yes No Yes Yes No] }
    let(:import_row_model_class) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Import
        dynamic_column :skills
      end
    end
    let(:row_model) { import_row_model_class.new }

    describe "#value" do
      subject { instance.value }
      before do
        import_row_model_class.class_eval do
          def self.format_dynamic_column_cells(*args); args end
        end
      end

      it "formats the column cells and memoizes" do
        expect(subject).to eql [["Yes", "Yes", "No", "Yes", "Yes", "No"], :skills, 0, OpenStruct.new]
      end
    end

    describe "#unformatted_value" do
      subject { instance.unformatted_value }

      it "returns an array of the formatted_cell" do
        expect(instance).to receive(:formatted_cells).and_call_original
        expect(instance).to receive(:formatted_headers).and_call_original

        expect(subject).to eql ["Yes", "Yes", "No", "Yes", "Yes", "No"]
      end

      context "with process method defined" do
        before do
          import_row_model_class.class_eval do
            def skill(formatted_cell, source_header);  "#{formatted_cell}__#{source_header}" end
          end
        end

        it "return an array of the result of the process method" do
          expect(subject).to eql ["Yes__Organized", "Yes__Clean", "No__Punctual", "Yes__Strong", "Yes__Crazy", "No__Flexible"]
        end
      end
    end

    describe "#formatted_cells" do
      subject { instance.formatted_cells }

      before do
        import_row_model_class.class_eval do
          def self.format_cell(*args); args.join("__") end
        end
      end

      it "returns an array of the formatted_cells" do
        expect(subject).to eql [
                                 "Yes__skills__0__#<OpenStruct>",
                                 "Yes__skills__1__#<OpenStruct>",
                                 "No__skills__2__#<OpenStruct>",
                                 "Yes__skills__3__#<OpenStruct>",
                                 "Yes__skills__4__#<OpenStruct>",
                                 "No__skills__5__#<OpenStruct>"
                               ]
      end

      context "with regular column defined" do
        let(:import_row_model_class) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import
            column :string1
            dynamic_column :skills
          end
        end

        it "it bumps the index up on the formatted cell" do
          expect(subject.first).to eql "Yes__skills__1__#<OpenStruct>"
        end
      end
    end

    describe "#formatted_headers" do
      subject { instance.formatted_headers }

      before do
        import_row_model_class.class_eval do
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
        let(:import_row_model_class) do
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

    describe "#dynamic_column_index" do
      subject { instance.dynamic_column_index }

      it "calls dynamic_column_index on the class and memoizes" do
        expect(import_row_model_class).to receive(:dynamic_column_index).with(:skills).and_call_original
        expect(subject).to eql 0
        expect(subject.object_id).to eql instance.dynamic_column_index.object_id
      end
    end

    describe "#call_process_method" do
      subject { instance.send(:call_process_method, "a", "b") }

      before do
        import_row_model_class.class_eval do
          def skill(formatted_cell, source_header);  "#{formatted_cell}**#{source_header}" end
        end
      end

      it "calls the process_method properly" do
        expect(subject).to eql "a**b"
      end
    end
  end

  describe "class" do
    describe "::process_method_name" do
      subject { described_class.process_method_name(:somethings) }

      it "returns a singularized name" do
        expect(subject).to eql :something
      end
    end

    describe "::defined_process_method" do
      let(:klass) { Class.new }
      subject { described_class.define_process_method(klass, :somethings) }

      it "adds the process method to the class" do
        subject
        expect(klass.new.something("a", "b")).to eql "a"
      end
    end
  end
end