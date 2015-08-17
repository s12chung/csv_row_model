require 'spec_helper'

describe FloatFormatValidator do
  let(:klass) do
    Class.new do
      include ActiveWarnings
      attr_accessor :string1
      warnings do
        validates :string1, float_format: true
      end

      def self.name; "TestClass" end
    end
  end
  let(:instance) { klass.new }
  subject { instance.safe? }

  include_examples "validate_type_examples"

  context "proper Float" do
    before { instance.string1 = "123.23" }
    it "is valid" do
      expect(subject).to eql true
    end

    context "trailing zero" do
      before { instance.string1 = "1230.12300" }
      it "is valid" do
        expect(subject).to eql true
      end
    end

    include_examples "prefix_zero"
    include_examples "suffix_zero"
  end

  context "Integer" do
    before { instance.string1 = "123" }
    it "is valid" do
      expect(subject).to eql true
    end

    include_examples "prefix_zero"
    include_examples "suffix_zero"
    include_examples "suffix_decimal_zero"
  end

  context "bad Float" do
    before { instance.string1 = "asdad" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end