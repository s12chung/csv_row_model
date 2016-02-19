class DynamicColumnModel
  include CsvRowModel::Model

  column :first_name
  column :last_name
  dynamic_column :skills
end

#
# Import
#
class DynamicColumnImportModel < DynamicColumnModel
  include CsvRowModel::Import
end

#
# Export
#
class DynamicColumnExportModel < DynamicColumnModel
  include CsvRowModel::Export
end

class DynamicColumnExportWithFormattingModel < DynamicColumnModel
  include CsvRowModel::Export
  class << self
    def format_cell(cell, _column_name, _column_index, context={})
      cell.upcase
    end
  end
end
