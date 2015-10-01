require 'spec_helper'

describe CsvRowModel::Import::File do

  let(:file_path) { basic_1_row_path }
  let(:model_class) { BasicImportModel }
  let(:instance) { described_class.new file_path, model_class, some_context: true }

  describe "#reset" do
    subject { instance.reset }

    context "at the end of the file" do
      before { while instance.next; end }

      it "resets and starts at the first row" do
        subject
        expect(instance.index).to eql -1
        expect(instance.current_row_model).to eql nil
        expect(instance.next.source_row).to eql %w[lang1 lang2]
      end
    end
  end

  describe "#next" do
    let(:file_path) { basic_5_rows_path }
    subject { instance.next }

    context "when passing a context" do
      subject { instance.next(another_context: true) }
      it "merges contexts" do
        expect(subject.context).to eql(OpenStruct.new(some_context: true, another_context: true))
      end
    end

    it "gets the rows until the end of file" do
      row_model = nil
      (0..4).each do |index|
        previous_row_model = row_model
        row_model = instance.next
        expect(row_model.class).to eql model_class

        expect(row_model.source_row).to eql %W[firsts#{index} seconds#{index}]

        expect(row_model.previous.try(:source_row)).to eql previous_row_model.try(:source_row)
        # + 1 due to header
        expect(row_model.index).to eql index + 1
        expect(row_model.context).to eql OpenStruct.new(some_context: true)
      end

      3.times do
        expect(instance.next).to eql nil
        expect(instance.end_of_file?).to eql true
      end
    end

    context "with children" do
      let(:file_path) { parent_5_rows_path }
      let(:model_class) { ParentImportModel }

      it "gets the rows until the end of file" do
        (0..1).each do |index|
          row_model = instance.next
          expect(row_model.class).to eql model_class
          expect(row_model.source_row).to eql %W[firsts#{index} seconds#{index}]

          children = row_model.children
          expect(children.map(&:source_row)).to eql children.map.with_index {|c, index| [nil, "seconds#{index}"]  }
        end
        3.times do
          expect(instance.next).to eql nil
          expect(instance.end_of_file?).to eql true
        end
      end
    end

    context "single_model" do
      let(:file_path) { basic_1_model_path }
      let(:instance) { described_class.new file_path, BasicRowImportModel }

      it "works" do
        expect(subject.source_row).to eql(['value 1', 'value 2'])
        3.times do
          expect(instance.next).to eql nil
          expect(instance.end_of_file?).to eql true
        end
      end
    end
  end

  describe "#end_of_file?" do
    subject { instance.end_of_file? }

    it "returns false" do
      expect(subject).to eql false
    end

    context "in the middle of file (last row)" do
      before { instance.next }

      it "returns false" do
        expect(subject).to eql false
      end
    end

    context "at the end of file" do
      before { instance.next; instance.next }

      it "returns true" do
        expect(subject).to eql true
      end
    end
  end

  describe "#each" do
    subject { instance.each }

    context "with abort" do
      before { instance.define_singleton_method(:abort?) { true } }
      it "never yields and call callbacks" do
        expect(instance).to receive(:run_callbacks).with(:abort).once
        expect { subject.next }.to raise_error(StopIteration)
      end
    end

    context "with abort on third row_model (abort on valid? ChildImport)" do
      let(:file_path) { basic_5_rows_path }
      let(:model_class) do
        Class.new(BasicImportModel) do
          def abort?; source_row.last.ends_with? "2" end
          def self.name; "BasicImportModelWithAbort" end
        end
      end

      it "yields twice and call callbacks" do
        allow(instance).to receive(:run_callbacks).with(anything).and_call_original
        expect(instance).to receive(:run_callbacks).with(:abort).and_call_original.once

        subject.next
        subject.next
        expect { subject.next }.to raise_error(StopIteration)
      end
    end

    context "with skips on even rows" do
      let(:file_path) { basic_5_rows_path }
      let(:model_class) do
        Class.new(BasicImportModel) do
          def skip?; source_row.last.last.to_i % 2 == 1 end
          def self.name; "BasicImportModelWithSkip" end
        end
      end

      it "skips twice" do
        allow(instance).to receive(:run_callbacks).with(anything).and_call_original
        expect(instance).to receive(:run_callbacks).with(:skip).and_call_original.twice

        subject.next
        subject.next
        subject.next
        expect { subject.next }.to raise_error(StopIteration)
      end
    end
  end
end
