require 'spec_helper'

describe CsvRowModel::Coercer do

  describe "::parse_lambda" do
    let(:parse_lambda) { CsvRowModel::Coercer.new({type: type, parse: parse}, self).send(:parse_lambda) }

    let(:source_cell) { "1.01" }

    subject { parse_lambda.call(source_cell) }

    {
      nil => "1.01",
      Boolean => true,
      String => "1.01",
      Integer => 1,
      Float => 1.01
    }.each do |type, expected_result|
      context "with #{type.nil? ? "nil" : type} type" do
        let(:type)  { type }
        let(:parse) { nil }

        it "returns the parsed type" do
          expect(subject).to eql expected_result
        end
      end
    end

    context "with both option" do
      let(:type)  { Date }
      let(:parse) { ->(s) { "haha" } }

      it "raises exception" do
        expect { subject }.to raise_error('You need either :parse OR :type but not both of them')
      end
    end

    context "with Date type" do
      let(:source_cell) { "15/12/30" }
      let(:type)  { Date }
      let(:parse) { nil }

      it "returns the correct date" do
        expect(subject).to eql Date.new(2015,12,30)
      end
    end

    context "with parse option" do
      let(:type)  { nil }
      let(:parse) { ->(s) { "haha" } }

      it "returns what the parse returns" do
        expect(subject).to eql "haha"
      end

      context "of Proc that accesses instance" do
        let(:instance) { import_model_klass.new([]) }
        let(:source_row) { [["1.01"]] }

        let(:import_model_klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :string1, parse: ->(s) { something }

            def something; Random.rand end
          end
        end
        let(:random) { 0.02183303366172007 }

        it "returns the default" do
          expect(Random).to receive(:rand).and_return(random)
          expect(
            import_model_klass.new(source_row).original_attributes[:string1]
          ).to eql(random)
        end
      end
    end

    context "with nil source cell" do
      let(:source_cell) { "15/12/30" }

      CsvRowModel::Coercer::CLASS_TO_PARSE_LAMBDA.keys.each do |type|
        context "with #{type.nil? ? "nil" : type} type" do
          let(:type) { type }
          let(:parse) { nil }

          it "doesn't return an exception" do
            expect { subject }.to_not raise_error
          end
        end
      end
    end

    context "with invalid type" do
      let(:source_cell) { "15/12/30" }
      let(:type)  { Object }
      let(:parse) { nil }

      it "raises exception" do
        expect { subject }.to raise_error("type must be Boolean, String, Integer, Float, Date")
      end
    end
  end

end
