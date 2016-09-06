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

  it_behaves_like "validated_types"

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

    it_behaves_like "allows_prefix_zero"
    it_behaves_like "allows_suffix_zero"
    it_behaves_like "allows_zeros_with_decimal"
  end

  context "Integer" do
    before { instance.string1 = "123" }
    it "is valid" do
      expect(subject).to eql true
    end

    it_behaves_like "allows_prefix_zero"
    it_behaves_like "allows_suffix_zero"
    it_behaves_like "allows_suffix_decimal_zero"
  end
end