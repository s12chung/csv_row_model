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

    context "with deep_deep_class_var set" do
      let(:variable_name) { :@deep_class_var }
      def deep_class_var
        ClassWithFamily.send(:deep_class_var, variable_name, [], :+)
      end

      before do
        [Grandparent, Parent, Child, ClassWithFamily].each do |klass|
          klass.instance_variable_set(variable_name, [klass.to_s])
        end
      end

      describe "::deep_class_var" do
        subject { deep_class_var }

        it "returns a class variable merged across ancestors until deep_class_module" do
          expect(subject).to eql %w[Parent ClassWithFamily]
        end

        it "caches the result" do
          expect(deep_class_var.object_id).to eql deep_class_var.object_id
        end
      end

      describe "::break_cache" do
        subject { ClassWithFamily.break_cache(variable_name) }

        it "breaks the cache" do
          value = deep_class_var
          expect(value.object_id).to eql deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql deep_class_var.object_id
        end
      end

      describe "::cache.break_all" do
        subject { Parent.send(:cache, variable_name).break_all }

        def parent_deep_class_var
          Parent.send(:deep_class_var, variable_name, [], :+)
        end

        it "breaks the cache of self class" do
          value = parent_deep_class_var
          expect(value.object_id).to eql parent_deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql parent_deep_class_var.object_id
        end

        it "breaks the cache of children class" do
          value = deep_class_var
          expect(value.object_id).to eql deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql deep_class_var.object_id
        end
      end
    end
  end
end
