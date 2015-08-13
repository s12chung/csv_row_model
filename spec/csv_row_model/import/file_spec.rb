require 'spec_helper'

describe CsvRowModel::Import::File do

  let(:file_path) { basic_1_row_path }
  let(:model_class) { BasicImportModel }
  let(:instance) { described_class.new file_path, model_class }

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

    it "gets the rows until the end of file" do
      (0..4).each do |index|
        row_model = instance.next
        expect(row_model.class).to eql model_class
        expect(row_model.source_row).to eql %W[firsts#{index} seconds#{index}]
      end
      3.times do
        expect(instance.next).to eql nil
        expect(instance.end_of_file?).to eql true
      end
    end

    context "with children" do
      let(:file_path) { parent_5_rows_path }
      let(:model_class) { ParentImportModel }

      shared_examples("with children") do
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

      include_examples "with children"

      context "with mapper" do
        let(:model_class) { ParentImportMapper }

        include_examples "with children"
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
    context "with abort" do
      before { instance.define_singleton_method(:abort?) { true } }
      it "never yields and call callbacks" do
        expect(instance).to receive(:run_callbacks).with(:abort).once
        expect { |b| instance.each(&b) }.to_not yield_control.once
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

        expect { |b| instance.each(&b) }.to yield_control.twice
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

        expect { |b| instance.each(&b) }.to yield_control.exactly(3).times
      end
    end
  end

  context "colection model" do
    let(:file_path) { basic_1_row_path }

    subject do
      described_class.new file_path, BasicImportModel
    end

    specify do
      enum = subject.each
      first_line = enum.next
      expect(first_line.source_header).to eql(['string1', 'string2'])
      expect(first_line.source_row).to eql(['lang1', 'lang2'])
    end
  end

  context "single model" do
    let(:file_path) { basic_1_model_path }

    subject do
      described_class.new file_path, BasicRowImportModel
    end

    specify do
      enum = subject.each
      model = enum.next
      expect(model.source_row).to eql(['value 1', 'value 2'])
    end
  end
end
