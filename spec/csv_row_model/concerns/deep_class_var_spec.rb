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

class InheritedBaseClass; end

describe CsvRowModel::Concerns::DeepClassVar do
  describe "class" do
    describe "::inherited_ancestors" do
      subject { ClassWithFamily.send(:inherited_ancestors) }

      it "returns the inherited ancestors" do
        expect(subject).to eql [ClassWithFamily, Parent, CsvRowModel::Concerns::DeepClassVar]
      end
    end

    describe "::inherited_custom_class" do
      let(:klass) { Parent }
      subject { klass.send(:inherited_custom_class, :does_not_exist, InheritedBaseClass) }

      it "gives a name" do
        expect(subject.name).to eql "ParentInheritedBaseClass"
      end

      describe "::csv_string_model_class" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Model
            def self.deep_class_module; CsvRowModel::Model end

            csv_string_model { validates :string1, presence: true }
          end
        end

        it "adds csv_string_model_class validations" do
          expect(klass.csv_string_model_class.new(string1: "blah")).to be_valid
          expect(klass.csv_string_model_class.new(string1: "")).to_not be_valid
        end

        context "with multiple subclasses" do
          let(:klass2) { Class.new(klass) { csv_string_model { validates :string2, presence: true } } }
          let(:klass3) { Class.new(klass2) { csv_string_model { validates :string3, presence: true } } }

          it "adds propagates validations to subclasses" do
            expect(klass2.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "blah")).to be_valid
            expect(klass2.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "")).to be_valid
            expect(klass2.csv_string_model_class.new(string1: "", string2: "1233", string3: "")).to_not be_valid

            expect(klass3.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "blah")).to be_valid
            expect(klass3.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "")).to_not be_valid
            expect(klass3.csv_string_model_class.new(string1: "", string2: "1233", string3: "blah")).to_not be_valid
          end
        end
      end

      describe "::presenter_class" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import
            def self.name; "TestRowModel" end
            def self.deep_class_module; CsvRowModel::Import end

            presenter do
              validates :attr2, presence: true
              attribute(:attr1) { "blah" }
              attribute(:attr2) { nil }
            end
          end
        end

        let(:row_model) { klass.new([""]) }
        let(:instance) { klass.presenter_class.new(row_model) }

        it "works" do
          expect(instance.attr1).to eql "blah"
          expect(instance.attr2).to eql nil

          expect(instance).to_not be_valid
          expect(instance.errors.full_messages).to eql ["Attr2 can't be blank"]
        end

        context "with multiple subclasses" do
          let(:klass2) { Class.new(klass) { presenter { attribute(:attr3) { "waka" } } } }
          let(:instance2) { klass2.presenter_class.new(row_model) }
          let(:klass3) { Class.new(klass2) { presenter { attribute(:attr2) { "override!" } } } }
          let(:instance3) { klass3.presenter_class.new(row_model) }

          it "just subclasses attributes fine" do
            [instance2, instance3].each do |instance|
              expect(instance.attr1).to eql "blah"
              expect(instance.attr3).to eql "waka"
            end

            expect(instance2.attr2).to eql nil
            expect(instance2).to_not be_valid
            expect(instance2.errors.full_messages).to eql ["Attr2 can't be blank"]

            expect(instance3.attr2).to eql "override!"
            expect(instance3).to be_valid
          end
        end
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

      describe "::clear_class_cache" do
        subject { ClassWithFamily.clear_class_cache(variable_name) }

        it "clears the cache" do
          value = deep_class_var
          expect(value.object_id).to eql deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql deep_class_var.object_id
        end
      end

      describe "::clear_deep_class_cache" do
        subject { Parent.send(:clear_deep_class_cache, variable_name) }

        def parent_deep_class_var
          Parent.send(:deep_class_var, variable_name, [], :+)
        end

        it "clears the cache of self class" do
          value = parent_deep_class_var
          expect(value.object_id).to eql parent_deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql parent_deep_class_var.object_id
        end

        it "clears the cache of children class" do
          value = deep_class_var
          expect(value.object_id).to eql deep_class_var.object_id
          subject
          expect(value.object_id).to_not eql deep_class_var.object_id
        end
      end
    end
  end
end
