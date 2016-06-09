require 'spec_helper'

describe CsvRowModel::Import::Represents do
  let(:klass) { Class.new(BasicImportModel) { def self.name; "RepresentsTestModel" end } }
  let(:instance) { klass.new }

  describe "instance" do
    describe "#attributes" do
      subject { instance.attributes }

      let(:instance) { klass.new(%w[a b]) }
      before { klass.send(:represents_one, :test_model, dependencies: %i[string1 string2]) { "test" } }

      it "includes representations" do
        expect(subject).to eql(string1: "a", string2: "b", test_model: "test")
        expect(subject).to_not eql instance.column_attributes
      end
    end

    describe "#representation_attributes" do
      subject { instance.representation_attributes }
      before { klass.send(:represents_one, :test_model) { "test" } }

      it "includes representations" do
        expect(subject).to eql(test_model: "test")
      end
    end

    describe "#valid?" do
      subject { instance.valid? }

      it "calls #filter_errors and returns valid" do
        expect(instance).to receive(:filter_errors)
        expect(subject).to eql true
      end

      context "when invalid" do
        before { klass.send(:validates, :string1, presence: true) }

        it "returns invalid and has errors" do
          expect(subject).to eql false
          expect(instance.errors.full_messages).to eql ["String1 can't be blank"]
        end
      end
    end

    describe "#filter_errors" do
      subject { instance.send :filter_errors }
      before do
        klass.send(:represents_one, :test_model, dependencies: %i[string1]) { "test" }
        instance.errors.add(:test_model)
        instance.errors.add(:string2)
      end

      it "errors doesn't do anything with unrelated errors" do
        subject
        expect(instance.errors.keys).to eql [:test_model, :string2]
      end

      context "with an dependency errors" do
        before { instance.errors.add(:string1) }

        it "it removes the representation error" do
          subject
          expect(instance.errors.keys).to eql [:string2, :string1]
        end

        context "when called within #using_warnings" do
          subject { instance.using_warnings { super() } }

          before do
            instance.warnings.add(:test_model)
            instance.warnings.add(:string2)
            instance.warnings.add(:string1)
          end

          it "removes warnings only" do
            subject
            expect(instance.errors.keys).to eql [:test_model, :string2, :string1]
            expect(instance.warnings.keys).to eql [:string2, :string1]
          end
        end
      end
    end

    describe "#memoize" do
      subject { instance.send(:memoize, "test") { Random.rand } }

      it "memoizes the result" do
        expect(subject).to be_present
        expect(subject).to eql instance.send(:memoize, "test")
      end
    end

    describe "#valid_dependencies?" do
      before { klass.send(:represents_one, :test_model, dependencies: %i[string1 string2]) { "test" } }

      subject { instance.send(:valid_dependencies?, :test_model) }

      it "finds empty attribute and return false" do
        expect(subject).to eql false
      end

      context "with columns filled" do
        let(:instance) { klass.new(%w[a b]) }

        it "returns true" do
          expect(subject).to eql true
        end
      end

      context "with representation check" do
        before { klass.send(:represents_one, :string2, dependencies: %i[string1]) { "test" } }

        let(:instance) { klass.new(%w[a]) }

        it "returns true" do
          expect(instance.string2).to eql "test"
          expect(subject).to eql true
        end
      end
    end
  end

  describe "class" do
    describe "::represents_one" do
      subject { klass.send(:represents_one, :test_model) { "test" } }

      it "adds the named method to the class" do
        subject
        expect(instance.test_model).to eql "test"
      end

      it "calls the helper methods" do
        expect(klass).to receive(:set_representation_options).with(:test_model, {})
        expect(klass).to receive(:define_representation_method).with(:test_model).and_yield
        subject
      end
    end

    describe "::represents_many" do
      subject { klass.send(:represents_many, :test_models) { %w[test test] } }

      it "adds the named method to the class" do
        subject
        expect(instance.test_models).to eql %w[test test]
      end

      it "calls the helper methods" do
        expect(klass).to receive(:set_representation_options).with(:test_models, {})
        expect(klass).to receive(:define_representation_method).with(:test_models, []).and_yield
        subject
      end
    end

    describe "::set_representation_options" do
      let(:options) { { memoize: false } }
      subject { klass.send(:set_representation_options, :test_model, options) { "test" } }

      it "sets the option with defaults" do
        subject
        expect(klass.send(:representations)[:test_model]).to eql(options.merge(dependencies: []))
      end

      context "invalid option" do
        let(:options) { { blah: false } }

        it "raises error with bad invalid option" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    describe "::define_representation_method" do
      subject { klass.send(:define_representation_method, :test_model, []) { "test" } }

      let(:options) { {} }
      before { klass.send(:set_representation_options, :test_model, options) }

      it "creates the memoized representation_method method and the underlying one" do
        subject
        expect(instance.test_model).to eql "test"
        expect(instance.test_model.object_id).to eql instance.test_model.object_id
        expect(instance.__test_model).to eql "test"
        expect(instance.__test_model.object_id).to_not eql instance.__test_model.object_id
      end

      it "works with subclassing and overriding" do
        subject
        expect(Class.new(klass).new.test_model).to eql "test"

        instance = Class.new(klass) { def test_model; "overwritten" end }.new
        expect(instance.test_model).to eql "overwritten"
        expect(instance.__test_model).to eql "test"
      end

      context "with memoization off" do
        let(:options) { { memoize: false } }

        it "doesn't memoize anything" do
          subject
          expect(instance.test_model).to eql "test"
          expect(instance.test_model.object_id).to_not eql instance.test_model.object_id
          expect(instance.__test_model).to eql "test"
          expect(instance.__test_model).to_not eql instance.__test_model.object_id
        end
      end

      context "with dependencies" do
        let(:options) { { dependencies: %i[string1 string2] } }

        it "returns empty_value" do
          subject
          expect(instance.test_model).to eql []
        end

        context "with dependencies set" do
          let(:instance) { klass.new %w[a b] }

          it "returns the defined value" do
            subject
            expect(instance.test_model).to eql "test"
          end
        end
      end
    end
  end
end