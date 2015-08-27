require 'spec_helper'

describe CsvRowModel::Concerns::Inspect do
  describe "instance" do
    let(:klass) do
      Class.new do
        include CsvRowModel::Concerns::Inspect
        attr_accessor :var1, :var2, :var3
        def initialize
          @var1 = "dog"
          @var2 = { a: "dug", b: "the" }
          @var3 = OpenStruct.new(c: "waka")
        end

        def self.name; "SomeName" end
        def self.inspect_methods; %i[var1 var2 var3] end
      end
    end
    let(:instance) { klass.new }

    describe "#inspect" do
      subject { instance.inspect }
      it "works" do
        expect(subject).to match /#<SomeName:\d* var1=\"dog\", var2={:a=>\"dug\", :b=>\"the\"}, var3=#<OpenStruct c=\"waka\">>/
      end
    end
  end
end