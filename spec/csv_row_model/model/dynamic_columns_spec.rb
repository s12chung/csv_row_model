require 'spec_helper'

describe CsvRowModel::Model::DynamicColumns do
  let(:skills) { %w[skill1 skill2] }

  describe "instance" do
    let(:source) { {} }
    let(:instance) { DynamicColumnModel.new(source) }

    before do
      instance.define_singleton_method(:first_name) { "haha" }
      instance.define_singleton_method(:last_name) { "baka" }
      instance.define_singleton_method(:skills) { %w[skill1 skill2] }
    end

    describe "#attributes" do
      subject { instance.attributes }

      it "returns the map of column_name => public_send(column_name)" do
        expect(instance.attributes).to eql( first_name: "haha", last_name: "baka", skills: %w[skill1 skill2] )
      end
    end
  end

  describe "class" do
    describe "::dynamic_column_headers" do
      subject { klass.dynamic_column_headers(skills: skills) }

      let(:klass) do
        Class.new do
          include CsvRowModel::Model
          dynamic_column :skills
        end
      end

      it "the header is the header_model" do
        expect(subject).to eql skills
      end

      context "when the method is overwritten" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Model
            dynamic_column :skills, header: ->(skill_name) { skill_name + "_changed" }
          end
        end

        it "overrides the original" do
          expect(subject).to eql skills(&->(skill_name) { skill_name + "_changed" })
        end
      end
    end

    describe "::headers" do
      let(:headers) { [:first_name, :last_name] + skills }
      subject { DynamicColumnModel.headers(skills: skills) }

      it "returns an array with header column names" do
        expect(subject).to eql headers
      end
    end

    describe "::dynamic_index" do
      subject { DynamicColumnModel.dynamic_index(:skills) }

      it "returns the index after the columns" do
        expect(subject).to eql 2
      end
    end

    describe "::dynamic_column_names" do
      subject { DynamicColumnModel.dynamic_column_names }

      it "returns just the dynamic column names" do
        expect(subject).to eql [:skills]
      end
    end

    describe "::dynamic_columns" do
      subject { DynamicColumnModel.dynamic_columns }

      it "returns the hash representing the dynamic columns" do
        expect(subject).to eql(skills: {})
      end
    end
  end
end
