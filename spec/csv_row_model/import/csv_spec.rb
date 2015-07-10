require 'spec_helper'

describe CsvRowModel::Import::Csv do
  include_context 'csv file'

  subject do
    described_class.new(file_path)
  end

  context 'with a bad path' do
    let(:file_path) { 'no_where' }

    specify do
      expect(subject).to be_invalid
      expect(subject.errors).to be_present
      expect(subject.errors.messages[:file]).to eql(['No such file or directory @ rb_sysopen - no_where'])
    end
  end

  specify do
    expect(subject.size).to eql(3)
    expect(subject.readline).to eql([ 'h a', 'h b' ])
    expect(subject.current_row).to eql([ 'h a', 'h b' ])
    expect(subject.index).to eql(0)
    expect(subject.readline).to eql([ 'a', 'b' ])
    expect(subject.index).to eql(1)
    expect(subject.readline).to eql([ 'c', 'd' ])
    expect(subject.readline).to eql(nil)
    expect(subject.end_of_file?).to be_truthy
    expect(subject).to be_valid

    subject.reset
    subject.skip_header
    expect(subject.header).to eql([ 'h a', 'h b' ])
    expect(subject.readline).to eql([ 'a', 'b' ])
    expect(subject.readline).to eql([ 'c', 'd' ])
    expect(subject.readline).to eql(nil)
  end

end
