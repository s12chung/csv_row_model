require 'spec_helper'

describe CsvRowModel::Import::Mapper::Attributes do
  describe "instance" do
    let(:klass) { DependentImportMapper }
    let(:instance) { klass.new source_row }
    let (:source_row) { ["no_errors", "no_errors"]  }

    describe "attribute_methods" do
      subject { instance.attribute1 }

      it "should execute with memoization" do
        expect(subject).to_not eql nil
        expect(subject).to eql instance.attribute1
      end

      it "should work when calling next" do
        instance.attribute2
        instance.attribute2
        expect(instance.attribute2).to eql nil
        expect(instance.attribute3).to eql nil
      end

      it "should work when calling return" do
        instance.attribute4
        instance.attribute4
        expect(instance.attribute4).to eql nil
        expect(instance.attribute5).to eql nil
      end

      context "with row_model errors" do
        let(:source_row) {["", ""] }

        it "should just return nil" do
          expect(Random).to_not receive(:rand)
          expect(subject).to eql nil
        end
      end
    end

    describe "#filter_errors" do
      subject { instance.send :filter_errors }
      before do
        instance.errors.add(:attribute1)
        instance.errors.add(:string2)
      end

      it "only has mapper errors" do
        subject
        expect(instance.errors.keys).to eql [:attribute1, :string2]
      end

      context "with row_model errors" do
        let(:source_row) {["", ""] }

        it "only has row_model errors and the non-dependent attribute" do
          subject
          expect(instance.errors.keys).to eql [:string2, :string1]
        end
      end
    end

    describe "#valid_dependencies?" do
      subject { instance.send :valid_dependencies?, :attribute1 }
      before { instance.errors.add(:attribute1) }

      it "returns true" do
        expect(subject).to eql true
      end

      context "returns false" do
        let(:source_row) {["", ""] }

        it "only has row_model errors" do
          expect(subject).to eql false
        end
      end
    end

    describe "#memoize" do
      let(:klass) do
        Class.new do
          include CsvRowModel::Import::Mapper::Attributes
        end
      end

      let(:instance) { klass.new }
      subject { instance.send(:memoize, "test") { Random.rand } }

      it "memoizes the result" do
        expect(subject).to_not eql nil
        expect(subject).to eql instance.send(:memoize, "test")
      end
    end
  end
end