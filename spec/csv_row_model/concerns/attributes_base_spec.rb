require 'spec_helper'

describe CsvRowModel::AttributesBase do
  let(:row_model_class) do
    Class.new do
      include BasicAttributes

      column :string1
      column :string2
    end
  end
  let(:instance) { row_model_class.new(*attributes.values) }
  let(:attributes) { { string1: "haha", string2: "baka" } }

  describe "instance" do
    describe "#attributes" do
      subject { instance.attributes }

      it "returns the map of column_name => public_send(column_name)" do
        expect(subject).to eql attributes
      end

      context "with no methods defined" do
        before do
          row_model_class.send :undef_method, :string1
          row_model_class.send :undef_method, :string2
        end
        it "returns a hash with nils" do
          expect(subject).to eql(string1: nil, string2: nil)
        end
      end

      context "with one method defined" do
        before do
          row_model_class.send :undef_method, :string2
        end
        it "returns a hash with a nil" do
          expect(subject).to eql(string1: "haha", string2: nil)
        end
      end

      context "with nil returned in method" do
        let(:attributes) { { string1: nil, string2: "baka" } }
        it "returns a hash with a nil" do
          expect(subject).to eql attributes
        end
      end
    end

    describe "#original_attributes" do
      subject { instance.original_attributes }
      it "returns the attributes hash" do
        expect(subject).to eql(string1: 'haha', string2: 'baka')
      end
    end

    describe "#formatted_attributes" do
      before do
        row_model_class.class_eval do
          def self.format_cell(*args); args.join("__") end
        end
      end

      subject { instance.formatted_attributes }
      it "returns the attributes hash" do
        expect(subject).to eql(string1: "haha_source__string1__#<OpenStruct>", string2: "baka_source__string2__#<OpenStruct>")
      end
    end

    describe "#source_attributes" do
      subject { instance.source_attributes }
      it "returns the attributes hash" do
        expect(subject).to eql(string1: 'haha_source', string2: 'baka_source')
      end
    end

    describe "#original_attribute" do
      it_behaves_like "attribute_object_value", :original_attribute, :value, string1: "haha"
    end

    describe "#to_json" do
      it "returns the attributes json" do
        expect(instance.to_json).to eql(instance.attributes.to_json)
      end
    end

    describe "#eql?" do
      it "removes duplicate entries" do
        expect([row_model_class.new, row_model_class.new].uniq.size).to eql(1)
      end
    end

    describe "#hash" do
      subject { instance.hash }
      it "is the attributes hash" do
        expect(subject).to eql attributes.hash
      end
    end
  end

  describe "class" do
    it_behaves_like "defines_attributes_methods_safely", { string1: "haha", string2: "baka" }, BasicAttributes
  end
end