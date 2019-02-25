require 'spec_helper'

describe CsvRowModel::Model::Children do
  describe "instance" do
    let(:options) { {} }
    let(:instance) { BasicRowModel.new(options) }

    describe "#child?" do
      subject { instance.child? }

      specify { expect(subject).to eql false }

      context "with a parent" do
        let(:parent_instance) { BasicRowModel.new }
        let(:options) { { parent:  parent_instance } }
        specify { expect(subject).to eql true }
      end
    end

    context "for ImportClass" do
      let(:source_row) { %w[a b] }
      let(:options) { { parent: parent_instance } }
      let(:instance) { BasicImportModel.new(source_row, {}) }

      let(:parent_instance) { ParentImportModel.new(source_row) }
      before do
        allow(BasicRowModel).to receive(:new).with(source_row, options).and_return instance
        parent_instance.append_child(source_row, options)
      end

      describe "#append_child" do
        let(:another_instance) { instance.dup }

        subject { parent_instance.append_child(source_row) }

        before { allow(BasicRowModel).to receive(:new).with(source_row, options).and_return another_instance }

        it "appends the child and returns it" do
          expect(subject).to eql another_instance
          expect(parent_instance.children).to eql [instance, another_instance]
        end

        context "when source_row is nil" do
          let(:source_row) { nil }

          it "doesn't add a child" do
            expect(subject).to eql nil
            expect(parent_instance.children).to eql []
          end
        end

        context "when child is invalid" do
          before do
            allow(BasicRowModel).to receive(:new).with(source_row, {}).and_return instance
            allow(another_instance).to receive(:valid?).and_return(false)
          end 

          it "doesn't append the child and returns nil" do
            expect(subject).to_not be_child
            expect(parent_instance.children).to eql [parent_instance]
          end
        end
      end

      context "with a parent" do
        before do
          parent_instance.define_singleton_method(:meth) { "haha" }
          instance.define_singleton_method(:meth) { "baka" }
        end


        describe "#children_public_send" do
          subject { parent_instance.children_public_send(:meth) }

          it "returns the results of calling public_send on it's children" do
            expect(subject).to eql %w[baka]
          end
        end

        describe "#deep_public_send" do
          subject { parent_instance.deep_public_send(:meth) }

          it "returns the results of calling public_send on itself and children" do
            expect(subject).to eql %w[haha baka]
          end
        end
      end
    end
  end
end