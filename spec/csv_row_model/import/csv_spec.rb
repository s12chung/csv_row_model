require 'spec_helper'

describe CsvRowModel::Import::Csv do
  let(:file_path) { basic_1_row_path }
  let(:instance) { described_class.new(file_path) }

  describe "#size" do
    subject { instance.size }
    it "works" do
      expect(subject).to eql 2
    end

    context "with empty lines" do
      let(:file_path) { syntax_empty_5_rows_path }

      it "counts the empty lines" do
        expect(subject).to eql 7
      end
    end
  end

  def start_of_file?(instance)
    expect(instance.index).to eql -1
    expect(instance.current_row).to eql nil
  end

  def second_row?(instance)
    expect(instance.index).to eql 0
    expect(instance.current_row).to eql ["string1", "string2"]
  end

  describe "#skip_header" do
    subject { instance.skip_header }

    it "goes to the second row and doesn't move" do
      start_of_file? instance

      expect(instance.skip_header).to eql ["string1", "string2"]
      expect(instance.skip_header).to eql false

      second_row? instance
    end

    it "works when header is called" do
      start_of_file? instance

      instance.header
      expect(subject).to eql ["string1", "string2"]

      second_row? instance
    end
  end

  describe "#header" do
    subject { instance.header }

    it "returns the header without changing the state" do
      start_of_file? instance

      expect(subject).to eql ["string1", "string2"]

      start_of_file? instance
    end
  end

  describe "#reset" do
    subject { instance.reset }

    it "sets the state back to reset" do
      expect(instance.read_row).to eql ["string1", "string2"]
      second_row? instance
      expect(subject).to eql true
      start_of_file? instance
      expect(instance.read_row).to eql ["string1", "string2"]
    end
  end

  describe "#start_of_file?" do
    subject { instance.start_of_file? }

    it "works" do
      expect(subject).to eql true
    end
  end

  describe "#end_of_file?" do
    subject { instance.end_of_file? }

    it "works" do
      while instance.read_row; end
      expect(subject).to eql true
    end
  end

  describe "#next_row" do

  end

  describe "#read_row" do
    subject { instance.read_row }

    it "works and goes to end of file" do
      expect(instance.read_row).to eql ["string1", "string2"]
      expect(instance.read_row).to eql ["lang1", "lang2"]
      expect(instance.read_row).to eql nil
      expect(instance.read_row).to eql nil
      expect(instance.end_of_file?).to eql true
    end

    context "after next_row" do
      before { instance.next_row }

      it "works" do
        expect(subject).to eql ["string1", "string2"]
      end
    end

    context "with empty lines" do
      let(:file_path) { syntax_empty_5_rows_path }

      it "skips the empty lines" do
        expect(instance.read_row).to eql ["string1", "string2"]
        expect(instance.index).to eql 1
        expect(instance.read_row).to eql ["lang1", "lang2"]
        expect(instance.index).to eql 3
        expect(instance.read_row).to eql nil
      end
    end
  end
end
