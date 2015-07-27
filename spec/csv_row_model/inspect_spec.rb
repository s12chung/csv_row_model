require 'spec_helper'

describe CsvRowModel::Inspect do
  describe "instance" do
    let(:klass) do
      Class.new do
        include CsvRowModel::Inspect
        def initialize
          @var1 = "dog"
          @var2 = { a: "dug", b: "the" }
          @var3 = 1.645
        end

        def self.name; "SomeName" end
        def self.inspect_instance_variables; %i[@var1 @var2 @var3] end
      end
    end
    let(:instance) { klass.new }

    describe "#inspect" do
      subject { instance.inspect }
      it "works" do
        expect(subject).to match /#<SomeName:\d* @var1=\"dog\", @var2={:a=>\"dug\", :b=>\"the\"}, @var3=1.645>/
      end
    end
  end
end