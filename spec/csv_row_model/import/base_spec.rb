require 'spec_helper'

describe CsvRowModel::Import::Base do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:row_model_class) { BasicImportModel }
    let(:instance) { row_model_class.new(source_row, options) }

    describe "#inspect" do
      subject { instance.inspect }
      it("works") { subject }
    end

    describe "#valid?" do
      subject { instance.valid? }

      it "defaults to true" do
        expect(subject).to eql true
      end

      context "with Exception given" do
        let(:instance) { row_model_class.new(StandardError.new("msg")) }

        it "is invalid and has empty row as source" do
          expect(subject).to eql false
          expect(instance.errors.full_messages).to eql ["Csv has msg"]
          expect(instance.source_row).to eql []
        end
      end

      context "with more errors" do
        let(:source_row) { [] }
        let(:row_model_class) do
          Class.new(BasicImportModel) do
            validates :string1, :string2, presence: true
            def self.name; "test" end
          end
        end

        it "had working validations" do
          subject
          expect(instance.errors.full_messages).to eql ["String1 can't be blank", "String2 can't be blank"]
        end

        context "with Exception given" do
          let(:instance) { row_model_class.new(StandardError.new("msg")) }

          it "removes the other errors" do
            subject
            expect(instance.errors.full_messages).to eql ["Csv has msg"]
          end
        end
      end
    end

    describe "#source_attributes" do
      subject { instance.source_attributes }
      it "returns a map of `column_name => source_row[index_of_column_name]" do
        expect(subject).to eql({ string1: '1.01', string2: 'b'})
      end
    end

    describe "#free_previous" do
      let(:options) { { previous: row_model_class.new([]) } }

      subject { instance.free_previous }

      it "makes previous nil" do
        expect { subject }.to change { instance.previous }.to(nil)
      end

      context "when the class depends on the previous.previous" do
        let(:row_model_class) do
          Class.new(BasicImportModel) do
            def string1
              @string1 ||= original_attribute(:string1) || previous.try(:string1)
            end
          end
        end
        let(:source_row) { [] }
        let(:options) { { previous: row_model_class.new([], previous: row_model_class.new(%w[1.01 b])) } }

        it "should grab string1 from previous.previous" do
          expect(instance.string1).to eql "1.01"
        end
      end
    end

    describe "#skip?" do
      subject { instance.skip? }

      it "is false when valid" do
        expect(subject).to eql false
      end

      it "is true when invalid" do
        expect(instance).to receive(:valid?).and_return(false)
        expect(subject).to eql true
      end
    end

    describe "#abort?" do
      subject { instance.skip? }

      it "is always false" do
        expect(subject).to eql false
      end
    end
  end
end
