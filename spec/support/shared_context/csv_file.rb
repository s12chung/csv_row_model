shared_context 'csv file' do
  let(:csv_source) { [[ 'h a', 'h b' ],[ 'a', 'b' ],[ 'c', 'd' ]] }

  let(:csv_string) do
    require 'csv'
    CSV.generate do |csv|
      csv_source.each { |row| csv << row }
    end
  end

  let(:file) do
    file = Tempfile.new(['input_file','.csv'])
    file.write(csv_string)
    file.rewind
    file
  end

  let(:file_path) { file.path }
end
