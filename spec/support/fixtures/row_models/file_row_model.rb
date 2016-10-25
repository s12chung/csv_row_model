class FileRowModel
  include CsvRowModel::Model
  include CsvRowModel::Model::FileModel

  row :string1
  row :string2, header: 'String 2'

  class << self
    def format_header(column_name, context); ":: - #{column_name} - ::" end
  end
end

#
# Import
#
class FileImportModel < FileRowModel
  include CsvRowModel::Import
  include CsvRowModel::Import::FileModel
end

#
# Export
#
class FileExportModel < FileRowModel
  include CsvRowModel::Export
  include CsvRowModel::Export::FileModel

  def rows_template
    @rows_template ||= begin
      [
        [ :string1, ''  , string_value(1)                  ],
        [ 'String 2', '', ''             , ''              ],
        [ ''        , '', ''             , string_value(2) ],
      ]
    end
  end

  def string_value(number)
    source_model.string_value(number)
  end
end
