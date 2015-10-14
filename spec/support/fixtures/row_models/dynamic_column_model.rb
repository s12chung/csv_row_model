class DynamicColumnModel
  include CsvRowModel::Model

  column :first_name, header: 'First Name'
  column :last_name,  header: 'Last Name'
  dynamic_column :skills
end

#
# Import
#
class DynamicColumnImportModel < DynamicColumnModel
  include CsvRowModel::Import

  def skill(value, skill_name)
    value == 'No' ? nil : skill_name
  end

  class << self
    def format_cell(cell, column_name, column_index)
      cell.strip
    end

    def format_dynamic_column_cells(cells, column_name)
      cells.compact
    end
  end
end

#
# Export
#
class DynamicColumnExportModel < DynamicColumnModel
  include CsvRowModel::Export

  def skill(skill)
    source_model.skills.include?(skill)
  end

  class << self
    def skill_header(skill)
      skill
    end

    def format_cell(cell, column_name, column_index)
      return 'No'  if cell.nil?
      return 'Yes' if cell == true
      return 'No'  if cell == false
      cell
    end
  end
end
