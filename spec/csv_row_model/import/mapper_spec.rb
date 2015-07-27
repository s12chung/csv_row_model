require 'spec_helper'

describe CsvRowModel::Import::Mapper do
  describe "instance" do
    let(:source_row) { %w[a b] }
    let(:options) { {} }
    let(:instance) { BasicImportMapper.new(source_row, options) }

    describe "#initialize" do
      it "created the row_model" do
        expect(instance.row_model.class).to eql BasicImportModel
      end
    end

    describe "#inspect" do
      subject { instance.inspect }
      it("works") { subject }
    end

    describe "#valid?" do
      subject { instance.valid? }

      it "calls #filter_errors" do
        expect(instance).to receive(:filter_errors)
        subject
      end

      it "calls #filter_errors when calling #safe?" do
        expect(instance.row_model).to receive(:using_warnings).and_call_original
        instance.safe?
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

    describe "#method_missing" do
      let(:method) { :source_row }
      subject { instance.public_send(method) }

      it "calls the row model with the method" do
        expect(subject).to eql source_row
      end

      context "when the method raises an error" do
        let(:method) { :method_that_raises }

        it "gives the inner exception" do
          expect { subject }.to raise_error("test")
        end
      end

      context "when the method is protected" do
        let(:method) { :protected_method }

        it "raises the original_error before calling protected" do
          expect { subject }.to raise_error(NoMethodError, /Mapper/)
        end
      end

      context "when the method is a column_name" do
        let(:method) { :string1 }

        it "raises the original_error before calling protected" do
          expect { subject }.to raise_error(NoMethodError, /Mapper/)
        end
      end

      context "when the method is a column_name that's in Mapper" do
        let(:method) { :string2 }

        it "raises the original_error before calling protected" do
          expect(subject).to eql "mapper"
        end
      end
    end

    describe "#try" do
      let(:options) { { previous: "" } }

      it "should free the previous" do
        instance.try(:free_previous)
        expect(instance.previous).to eql nil
      end

      it "should stay with itself if it returns falsey" do
        expect(instance).to receive(:string2).and_return(false)
        instance.try(:string2)
        # expect(instance.try(:test)).to eql false
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
            maps_to Random
          end
        end
        subject { klass }

        it "sends a warning" do
          expect(Kernel).to receive(:warn)
          subject
        end
      end
    end

    describe "::row_model_class" do
      class FooRowModel; end

      let(:klass) do
        Class.new do
          include CsvRowModel::Import::Mapper
        end
      end
      subject { klass.send(:row_model_class) }

      ["Foo", "FooMapper"].each do |row_model_class|
        context "with class name #{row_model_class}" do
          before do
            klass.define_singleton_method(:name) { row_model_class }
          end

          it "set's the row_model_class" do
            expect(subject).to eql(FooRowModel)
          end
        end
      end

      context "with default not existing" do
        before do
          klass.define_singleton_method(:name) { "Blah" }
        end

        it "set's the row_model_class" do
          expect { subject }.to raise_error(CsvRowModel::RowModelClassNotDefined)
        end
      end
    end
  end
end
