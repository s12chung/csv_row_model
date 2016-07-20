require 'spec_helper'

describe CsvRowModel::Model::DynamicColumns do
  let(:skills) { %w[skill1 skill2] }
  let(:row_model_class) do
    Class.new do
      include CsvRowModel::Model::Attributes
      include CsvRowModel::Model::DynamicColumns
      dynamic_column :skills
    end
  end
  let(:instance) { row_model_class.new }

  shared_context "standard columns defined" do
    let(:row_model_class) { DynamicColumnModel }
  end

  describe "class" do
    describe "::dynamic_column_index" do
      subject { row_model_class.dynamic_column_index(:skills) }

      it "returns the index after the columns" do
        expect(subject).to eql 0
      end

      with_context "standard columns defined" do
        it "returns the index after the columns" do
          expect(subject).to eql 2
        end
      end
    end

    describe "::dynamic_column_names" do
      subject { row_model_class.dynamic_column_names }

      with_context "standard columns defined" do
        it "returns just the dynamic column names" do
          expect(subject).to eql [:skills]
        end
      end
    end

    describe "::dynamic_columns?" do
      it "returns true if class is a dynamic_column class" do
        expect(row_model_class.dynamic_columns?).to eql(true)
        expect(BasicRowModel.dynamic_columns?).to eql(false)
      end
    end

    describe "::headers" do
      subject { row_model_class.headers(skills: skills) }

      it "returns the header_models" do
        expect(subject).to eql skills
      end

      with_context "standard columns defined" do
        it "returns an array with header column names + header_models" do
          expect(subject).to eql [:first_name, :last_name] + skills
        end
      end
    end

    describe "::dynamic_column_headers" do
      subject { row_model_class.dynamic_column_headers(context) }
      let(:context) { { skills: skills } }

      with_this_then_context "standard columns defined" do
        it "returns the header that is the header_model" do
          expect(subject).to eql skills
        end
      end
    end

    describe "::format_dynamic_column_cells" do
      subject { row_model_class.format_dynamic_column_cells(["blah"], nil, nil, nil) }

      it "returns the cells" do
        expect(subject).to eql ["blah"]
      end
    end

    describe "::format_dynamic_column_header" do
      subject { row_model_class.format_dynamic_column_header("blah", nil, nil, nil) }

      it "returns the header_model" do
        expect(subject).to eql "blah"
      end
    end
  end
end
