require 'spec_helper'

describe DefaultChangeValidator do
  let(:klass) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :string1
      attr_accessor :string2
      validates :string1, default_change: true

      def self.name; "TestClass" end
    end
  end

  let(:instance) { klass.new }
  subject { instance.valid? }

  context "with no default_changes" do
    before do
      klass.send(:define_method, :default_changes) { {} }
    end

    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "with default change that does not match attribute" do
    before do
      klass.send(:define_method, :default_changes) { { string2: ["a", "b"] } }
    end

    it "is valid" do
      expect(subject).to eql true
    end
  end

  context "with default change that does match attributes" do
    before do
      klass.send(:define_method, :default_changes) { { string1: ["a", "b"] } }
    end

    it "is invalid" do
      expect(subject).to eql false
      expect(instance.errors.full_messages).to eql ["String1 changed by default"]
    end
  end
end
