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
  end

  context "Integer" do
    before { instance.string1 = "123" }
    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "bad Float" do
    before { instance.string1 = "asdad" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end