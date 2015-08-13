require 'spec_helper'

class Grandparent; end
module Child
  extend ActiveSupport::Concern

  class_methods do
    def deep_class_module
      Child
    end
  end
end
class Parent < Grandparent
  include Child
  include CsvRowModel::Concerns::DeepClassVar
end
class ClassWithFamily < Parent; end

describe CsvRowModel::Concerns::DeepClassVar do
  describe "class" do
    describe "::inherited_ancestors" do
      subject { ClassWithFamily.send(:inherited_ancestors) }

      it "returns the inherited ancestors" do
        expect(subject).to eql [ClassWithFamily, Parent, CsvRowModel::Concerns::DeepClassVar]
      end
    end

    describe "::deep_class_var" do
      let(:variable_name) { :@deep_class_var }

      before do
        [Grandparent, Parent, Child, ClassWithFamily].each do |klass|
          klass.instance_variable_set(variable_name, [klass.to_s])
        end
      end

      subject { ClassWithFamily.send(:deep_class_var, variable_name, [], :+) }

      it "returns a class variable merged across ancestors until deep_class_module" do
        expect(subject).to eql %w[Parent ClassWithFamily]
      end
    end
  end
end
