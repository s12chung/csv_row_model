require 'spec_helper'

describe DateTimeFormatValidator do
  let(:klass) do
    Class.new do
      include ActiveWarnings
      attr_accessor :string1
      warnings do
        validates :string1, date_time_format: true
      end

      def self.name; "TestClass" end
    end
  end
  let(:instance) { klass.new }
  subject { instance.safe? }

  include_examples "validate_type_examples"

  context "proper Date" do
    before { instance.string1 = "2026-12-12T17:47:43.884+02:00" }

    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "bad Date" do
    before { instance.string1 = "asdad" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end
