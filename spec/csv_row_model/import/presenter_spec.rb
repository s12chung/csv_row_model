require 'spec_helper'

describe CsvRowModel::Import::Presenter do
  describe "instance" do
    let(:row_model_class) { ImportModelWithValidations }
    let(:klass) { PresenterWithValidations }

    let(:instance) { klass.new(row_model_class.new(source_row)) }
    let(:source_row) { ["no_errors", "no_errors"]  }

    describe "#inspect" do
      subject { instance.inspect }
      it("works") { subject }
    end

    describe "attribute_methods" do
      subject { instance.attribute1 }

      it "should execute with memoization" do
        expect(subject).to_not eql nil
        expect(subject).to eql instance.attribute1
      end

      context "when calling next" do
        let(:klass) do
          Class.new(CsvRowModel::Import::Presenter) do
            attribute(:attribute1) { attribute2; attribute2; next; "never" }
            attribute(:attribute2) { next; "never touch" }
          end
        end

        it "works" do
          instance.attribute1; instance.attribute1
          expect(instance.attribute1).to eql nil
          expect(instance.attribute2).to eql nil
        end
      end

      context "when calling return" do
        let(:klass) do
          Class.new(CsvRowModel::Import::Presenter) do
            attribute(:attribute1) { attribute2; attribute2; return; "never" }
            attribute(:attribute2) { return; "never touch" }
          end
        end

        it "works" do
          instance.attribute1; instance.attribute1
          expect(instance.attribute1).to eql nil
          expect(instance.attribute2).to eql nil
        end
      end

      context "with row_model errors" do
        let(:source_row) {["", ""] }

        it "should just return nil" do
          expect(Random).to_not receive(:rand)
          expect(subject).to eql nil
        end
      end
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

    describe "#filter_errors" do
      subject { instance.send :filter_errors }
      before do
        instance.errors.add(:attribute1)
        instance.errors.add(:string2)
      end

      it "only has presenter errors" do
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
      let(:klass) { Class.new(CsvRowModel::Import::Presenter) }
      subject { instance.send(:memoize, "test") { Random.rand } }

      it "memoizes the result" do
        expect(subject).to_not eql nil
        expect(subject).to eql instance.send(:memoize, "test")
      end
    end

    describe "class" do
      describe "::dependencies" do
        context "with many dependencies" do
          subject { klass.dependencies }

          let(:klass) do
            Class.new(CsvRowModel::Import::Presenter) do
              attribute(:a1, dependencies: %i[a b c d]) { true }
              attribute(:a2, dependencies: %i[b c]) { true }
            end
          end
          let(:default_dependencies) { { a: %i[a1], b: %i[a1 a2], c: %i[a1 a2], d: %i[a1] } }

          it "merges the dependencies of overlapping attributes" do
            expect(subject).to eql(default_dependencies)
          end

          shared_examples("dependencies cache") do
            it "clears the cache and merges the dependencies" do
              expect(testing_class).to receive(:attribute_names).twice.and_call_original

              expect(testing_class.dependencies).to eql(default_dependencies)
              expect(testing_class.dependencies).to eql(default_dependencies)
              klass.send(:attribute, :a3, dependencies: %i[d e]) { true }
              expect(testing_class.dependencies).to eql(default_dependencies.merge(d: %i[a1 a3], e: %i[a3]))
            end
          end

          context "with new attribute added" do
            let(:testing_class) { klass }
            include_examples "dependencies cache"
          end

          context "on a subclass" do
            let(:testing_class) { Class.new(klass) }

            include_examples "dependencies cache"
          end
        end
      end

      describe "::attribute" do
        let(:klass) { Class.new(CsvRowModel::Import::Presenter) }
        subject { klass.send(:attribute, :attribute_name, options) { true } }
        let(:options) { { dependencies: [], memoize: false } }

        it "works" do
          subject
        end

        context "when giving an invalid option" do
          let(:options) { { testing: "" } }

          it "raises exception" do
            expect { subject }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end