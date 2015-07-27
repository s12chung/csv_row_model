module CsvFilePaths
  extend RSpec::SharedContext

  Dir[Dir.pwd + '/spec/support/csv_files/*.csv'].each do |file_path|
    let("#{File.basename file_path, ".*"}_path") { file_path }
  end
end