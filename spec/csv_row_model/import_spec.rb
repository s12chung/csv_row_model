require 'spec_helper'

describe CsvRowModel::Import do
  describe "instance" do
    let(:source_row) { %w[1.01 b] }
    let(:options) { {} }
    let(:klass) { BasicImportModel }
    let(:instance) { klass.new(source_row, options) }

    describe "#initialize" do
      subject { instance }

      context "should set the child" do
        let(:parent_instance) { BasicModel.new }
        let(:options) { { parent:  parent_instance } }
        specify { expect(subject.child?).to eql true }
      end
    end

    describe "#inspect" do
      subject { instance.inspect }
      it("works") { subject }
    end

    describe "#mapped_row" do
      subject { instance.mapped_row }
      it "returns a map of `column_name => source_row[index_of_column_name]" do
        expect(subject).to eql(string1: "1.01", string2: "b")
      end
    end

    describe "#free_previous" do
      let(:options) { { previous: klass.new([]) } }

      subject { instance.free_previous }

      it "makes previous nil" do
        expect {
          subject
        }.to change {
          instance.previous
        }.to(nil)
      end
    end

    describe "#presenter" do
      let(:klass) do
        Class.new(BasicImportModel) do
          presenter do
            attribute(:both_strings) { row_model.string1 + row_model.string2 }
          end
        end
      end

      subject { instance.presenter }

      it "returns presenter with methods working" do
        expect(subject.both_strings).to eql "1.01b"
      end
    end

    describe "#csv_string_model" do
      subject { instance.csv_string_model }
      it "returns csv_string_model with methods working" do
        expect(subject.string1).to eql "1.01"
        expect(subject.string2).to eql "b"
      end

      context "with format_cell" do
        it "should format_cell first" do
          expect(klass).to receive(:format_cell).with("1.01", :string1, 0).and_return(nil)
          expect(klass).to receive(:format_cell).with("b", :string2, 1).and_return(nil)
          expect(subject.string1).to eql nil
          expect(subject.string2).to eql nil
        end
      end
    end

    describe "#valid?" do
      subject { instance.valid? }
      let(:klass) { ImportModelWithValidations }

      it "works" do
        expect(subject).to eql true
      end

      context "with empty row" do
        let(:source_row) { %w[] }

        it "works" do
          expect(subject).to eql false
        end
      end

      describe "with custom class" do
        let(:klass) do
          Class.new do
            include CsvRowModel::Model
            include CsvRowModel::Import

            column :id

            def self.name; "TwoLayerValid" end
          end
        end

        context "when setting default, but invalid csv_string_model validation" do
          let(:source_row) { ["1", ""]}

          before do
            klass.instance_eval do
              column :name, default: "the default!"
              csv_string_model do
                validates :name, presence: true
              end
            end
          end

          it "returns just invalid" do
            expect(subject).to eql false
            expect(instance.errors.full_messages).to eql ["Name can't be blank"]
          end
        end

        context "overriding validations" do
          before do
            klass.instance_eval do
              validates :id, length: { minimum: 5 }
              csv_string_model do
                validates :id, presence: true
              end
            end
          end

          it "takes the csv_string_model_class validation first then the row_model validation" do
            expect(subject).to eql false
            expect(instance.errors.full_messages).to eql ["Id is too short (minimum is 5 characters)"]
          end

          context "with empty row" do
            let(:source_row) { [''] }

            it "just shows the csv_string_model_class validation" do
              expect(subject).to eql false
              expect(instance.errors.full_messages).to eql ["Id can't be blank"]
            end
          end

          context "with errors has a key with empty value" do
            before do
              expect(instance.csv_string_model).to receive(:valid?).at_least(1).times.and_wrap_original do |original, *args|
                result = original.call(*args)
                # this makes instance.csv_string_model.errors.messages = { id: [] }
                instance.csv_string_model.errors[:id]
                result
              end
            end

            it "still shows the non-string validation" do
              expect(subject).to eql false
              expect(instance.csv_string_model.errors.messages).to eql(id: [])
              expect(instance.errors.full_messages).to eql ["Id is too short (minimum is 5 characters)"]
            end
          end
        end

        context "with warnings" do
          before do
            klass.instance_eval do
              warnings do
                validates :id, length: { minimum: 5 }
              end
              csv_string_model do
                warnings do
                  validates :id, presence: true
                end
              end
            end
          end

          context "with empty row" do
            let(:source_row) { [''] }

            it "just shows the csv_string_model_class validation" do
              expect(subject).to eql true
              expect(instance.safe?).to eql false
              expect(instance.warnings.full_messages).to eql ["Id can't be blank"]
            end
          end
        end
      end
    end
  end
end
