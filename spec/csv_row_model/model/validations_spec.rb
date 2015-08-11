require 'spec_helper'

describe CsvRowModel::Model::Validations do
  describe "class" do
    let(:klass) { Class.new { include CsvRowModel::Model::Validations } }

    describe "::csv_string_model_class" do
      subject { klass.csv_string_model_class }

      before do
        klass.instance_eval do
          def self.name; "Waka" end
        end
      end

      it "gives a name" do
        expect(subject.name).to eql "WakaCsvStringModel"
      end
      it "memoizes so there's no memory leak (classes don't GC)" do
        expect(klass).to receive(:inherited_ancestors).once.and_call_original
        expect(klass.csv_string_model_class.object_id).to eql klass.csv_string_model_class.object_id
      end
    end

    describe "::csv_string_model" do
      context "with one validation" do
        before do
          klass.instance_eval do
            csv_string_model { validates :string1, presence: true }
          end
        end

        it "adds csv_string_model_class validations" do
          expect(klass.csv_string_model_class.new(string1: "blah").valid?).to eql true
          expect(klass.csv_string_model_class.new(string1: "").valid?).to eql false
        end

        context "with multiple subclasses" do
          let(:klass2) do
            Class.new(klass) do
              csv_string_model { validates :string2, presence: true }
            end
          end
          let(:klass3) do
            Class.new(klass2) do
              csv_string_model { validates :string3, presence: true }
            end
          end


          it "adds propagates validations to subclasses" do
            expect(klass2.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "blah").valid?).to eql true
            expect(klass2.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "").valid?).to eql true
            expect(klass2.csv_string_model_class.new(string1: "", string2: "1233", string3: "").valid?).to eql false

            expect(klass3.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "blah").valid?).to eql true
            expect(klass3.csv_string_model_class.new(string1: "blah", string2: "1233", string3: "").valid?).to eql false
            expect(klass3.csv_string_model_class.new(string1: "", string2: "1233", string3: "blah").valid?).to eql false
          end
        end
      end
    end
  end
end