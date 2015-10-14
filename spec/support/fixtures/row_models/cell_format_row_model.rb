class CellFormatRowModel
  include CsvRowModel::Model

  column :first_name, header: 'First Name'
  column :last_name,  header: 'Last Name'
end

#
# Export
#
class CellFormatExportModel < CellFormatRowModel
  include CsvRowModel::Export

  def last_name
    source_model.last_name.upcase
  end

  def first_name
    source_model.first_name.capitalize
  end

  def self.format_cell(cell, column_name, column_index)
    cell.try(:strip)
  end
end

#
# Import
#
class CellFormatImportModel < CellFormatRowModel
  include CsvRowModel::Import

  def last_name
    original_attribute(:last_name).upcase
  end

  def first_name
    original_attribute(:first_name).capitalize
  end

  def self.format_cell(cell, column_name, column_index)
    cell.try(:strip)
  end
end
