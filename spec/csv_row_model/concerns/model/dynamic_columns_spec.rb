require 'spec_helper'

describe CsvRowModel::Model::DynamicColumns do
  let(:skills) { %w[skill1 skill2] }
  let(:row_model_class) { DynamicColumnModel }

  describe "instance" do
    let(:instance) { row_model_class.new }

    before do
      instance.define_singleton_method(:first_name) { "haha" }
      instance.define_singleton_method(:last_name) { "baka" }
      instance.define_singleton_method(:skills) { %w[skill1 skill2] }
    end

    describe "#attributes" do
      subject { instance.attributes }

      it "returns the map of column_name => public_send(column_name)" do
        expect(subject).to eql( first_name: "haha", last_name: "baka", skills: %w[skill1 skill2] )
      end
    end
  end

  describe "class" do
    describe "::dynamic_column_index" do
      subject { row_model_class.dynamic_column_index(:skills) }

      it "returns the index after the columns" do
        expect(subject).to eql 2
      end
    end

    describe "::dynamic_column_names" do
      subject { row_model_class.dynamic_column_names }

      it "returns just the dynamic column names" do
        expect(subject).to eql [:skills]
      end
    end


    describe "::dynamic_columns?" do
      it "returns true if class is a dynamic_column class" do
        expect(row_model_class.dynamic_columns?).to eql(true)
        expect(BasicRowModel.dynamic_columns?).to eql(false)
      end
    end

    describe "::headers" do
      let(:headers) { [:first_name, :last_name] + skills }
      subject { row_model_class.headers(skills: skills) }

      it "returns an array with header column names" do
        expect(subject).to eql headers
      end
    end

    describe "::dynamic_column_headers" do
      subject { row_model_class.dynamic_column_headers(context) }
      let(:context) { { skills: skills } }

      it "returns the header that is the header_model" do
        expect(subject).to eql skills
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

    describe "::dynamic_columns" do
      subject { row_model_class.dynamic_columns }

      it "returns the hash representing the dynamic columns" do
        expect(subject).to eql(skills: {})
      end
    end
  end
end
