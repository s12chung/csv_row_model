require 'spec_helper'

describe CsvRowModel::Model do
  describe "instance" do
    let(:options) { {} }
    let(:instance) { BasicModel.new(nil, options) }

    describe "#initialize" do
      subject { instance }
      let(:parent) { BasicModel.new }
      let(:options) { { parent: parent } }

      it "sets the parent" do  expect(subject.parent).to eql parent  end
    end

    describe "#skip?" do
      subject { instance.skip? }
      it "skips whenever invalid" do expect(subject).to eql !instance.valid? end
    end

    describe "#abort?" do
      subject { instance.abort? }
      it "never aborts" do expect(subject).to eql false end
    end
  end

  describe "class" do
    let(:class_with_family) do
      class Grandparent; end
      class Parent < Grandparent; end
      module Child; end
      class ClassWithFamily < Parent
        include Child
        include CsvRowModel::Model
      end
    end

    describe "::memoized_class_included_var" do
      let(:var_name) { :memoized_var }
      let(:at_var_name) { "@#{var_name}" }
      subject { -> { class_with_family.send(:memoized_class_included_var, var_name, Random.rand, CsvRowModel::Model) } }

      it "memoizes the default value" do
        expect(class_with_family.instance_variable_get(at_var_name)).to eql nil
        expect(subject.call).to eql subject.call # Value shouldn't change
        expect(class_with_family.instance_variable_get(at_var_name)).to eql subject.call # Variable should be set
      end
    end

    describe "::class_included" do
      subject { class_with_family.send(:class_included, CsvRowModel::Model) }
      it "gets the class that included CsvRowModel::Model" do
        expect(subject).to eql class_with_family
      end
    end
  end
end
