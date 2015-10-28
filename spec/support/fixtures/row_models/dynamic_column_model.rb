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
