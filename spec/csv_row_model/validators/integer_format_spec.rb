require 'spec_helper'

describe DateFormatValidator do
  let(:klass) do
    Class.new do
      include ActiveWarnings
      attr_accessor :string1
      warnings do
        validates :string1, integer_format: true
      end

      def self.name; "TestClass" end
    end
  end
  let(:instance) { klass.new }
  subject { instance.safe? }

  context "proper Integer" do
    before { instance.string1 = "123" }
    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "Float" do
    before { instance.string1 = "123.00" }
    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "bad Integer" do
    before { instance.string1 = "asdad" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end