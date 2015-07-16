require 'spec_helper'

describe CsvRowModel::Import::File do
  include_context 'csv file'
  
  subject do
    described_class.new file_path, BasicImportModel
  end

  specify do
    enum = subject.each
    first_line = enum.next
    expect(first_line.source_header).to eql([ 'h a', 'h b' ])
    expect(first_line.source_row).to eql(['a', 'b'])
  end
end
