require 'spec_helper'

describe CsvRowModel::Import::Mapper do
  describe "instance" do
    let(:source_row) { %w[a b] }
    let(:options) { {} }
    let(:instance) { ImportMapper.new(source_row, options) }

    describe "#initialize" do
      it "created the row_model" do
        expect(instance.row_model.class).to eql BasicImportModel
      end
    end

    describe "#skip?" do
      subject { instance.skip? }

      around do |example|
        expect(instance.skip?).to eql false
        example.run
        expect(instance.skip?).to eql true
      end

      it "skips when invalid" do
        instance.define_singleton_method(:valid?) { false }
      end

      it "skips when the row_model skips" do
        instance.row_model.define_singleton_method(:skip?) { true }
      end
    end

    describe "#abort?" do
      it "aborts when the row_model aborts" do
        expect(instance.abort?).to eql false
        instance.row_model.define_singleton_method(:abort?) { true }
        expect(instance.abort?).to eql true
      end
    end

    describe "::memoize" do
      before do
        instance.define_singleton_method(:_memoized_method) { Random.rand }
      end
      subject { -> { instance.memoized_method } }

      it "memoized the method" do
        expect(subject.call).to eql subject.call
      end
    end
  end

  describe "class" do
    describe "::maps_to" do
      context "when called twice" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Import::Mapper
            maps_to Class
            maps_to Class
          end
        end
        subject { klass }

        it "raises an exception" do
          expect { subject }.to raise_error(CsvRowModel::Import::Mapper::AlreadyInitializedMap)
        end
      end
    end

    describe "::row_model_class" do
      class FooRowModel; end

      subject { klass.send(:row_model_class) }

      context "when not defined" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Import::Mapper
            def self.name() 'Foo' ; end
          end
        end
        it "set's the row_model_class" do
          expect(subject).to eql(FooRowModel)
        end
      end

      context "when not defined and Mapper class contain 'Mapper'" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Import::Mapper
            def self.name() 'FooMapper' ; end
          end
        end
        it "set's the row_model_class" do
          expect(subject).to eql(FooRowModel)
        end
      end
    end
  end
end
