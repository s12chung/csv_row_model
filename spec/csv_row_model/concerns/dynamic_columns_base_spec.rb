require 'spec_helper'

header_models = Skill.all
describe CsvRowModel::DynamicColumnsBase do
  let(:instance) { row_model_class.new("Mario", "Italian") }
  let(:row_model_class) do
    Class.new do
      include BasicDynamicColumns
      dynamic_column :skills
    end
  end

  shared_context "standard columns defined" do
    let(:row_model_class) do
      Class.new do
        include BasicDynamicColumns
        column :first_name
        column :last_name
        dynamic_column :skills
      end
    end
  end

  before do
    allow(instance).to receive(:context).and_return(OpenStruct.new)
    allow(instance).to receive(:header_models).and_return(header_models)
  end

  describe "instance" do
    describe "#attribute_objects" do
      it_behaves_like "attribute_objects_method",
                      %i[skills],
                      BasicDynamicColumnAttribute => 1

      with_context "standard columns defined" do
        it_behaves_like "attribute_objects_method",
                        %i[first_name last_name skills],
                        BasicAttribute => 2,
                        BasicDynamicColumnAttribute => 1
      end
    end

    describe "#attributes" do
      subject { instance.attributes }

      it "returns the map of column_name => public_send(column_name)" do
        expect(subject).to eql(skills: header_models)
      end

      with_context "standard columns defined" do
        it "returns the map of column_name => public_send(column_name)" do
          expect(subject).to eql(first_name: "Mario", last_name: "Italian", skills: header_models)
        end
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }

      it "should have dynamic columns" do
        expect(subject).to eql(skills: header_models)
      end

      with_context "standard columns defined" do
        it "should have standard and dynamic columns" do
          expect(subject).to eql(first_name: "Mario", last_name: "Italian", skills: header_models)
        end
      end
    end

    describe "#original_attribute" do
      subject { instance.original_attribute(:skills) }
      it_behaves_like "attribute_object_value", :original_attribute, :value, skills: header_models
    end

    describe "#formatted_attributes" do
      subject { instance.formatted_attributes }

      before do
        row_model_class.class_eval { def self.format_cell(*args); args.join("__") end }
      end

      it "returns all attributes of dynamic columns" do
        expect(subject).to eql(skills: ["Organized__skills__0__#<OpenStruct>", "Clean__skills__1__#<OpenStruct>", "Punctual__skills__2__#<OpenStruct>", "Strong__skills__3__#<OpenStruct>", "Crazy__skills__4__#<OpenStruct>", "Flexible__skills__5__#<OpenStruct>"])
      end

      with_context "standard columns defined" do
        it "returns all attributes including the dynamic columns" do
          expect(subject).to eql(
                               first_name: "Mario_source__first_name__0__#<OpenStruct>",
                               last_name: "Italian_source__last_name__1__#<OpenStruct>",
                               skills: ["Organized__skills__2__#<OpenStruct>", "Clean__skills__3__#<OpenStruct>", "Punctual__skills__4__#<OpenStruct>", "Strong__skills__5__#<OpenStruct>", "Crazy__skills__6__#<OpenStruct>", "Flexible__skills__7__#<OpenStruct>"]
                             )
        end
      end
    end
  end

  describe "class" do
    it_behaves_like "defines_attributes_methods_safely", { string1: "Mario", string2: "Italian" }, BasicDynamicColumns
  end
end