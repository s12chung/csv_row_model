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

  def skills
    __skills.compact
  end

  def skill(value, skill_name)
    value == 'No' ? nil : skill_name
  end
end

#
# Export
#
class DynamicColumnExportModel < DynamicColumnModel
  include CsvRowModel::Export

  def skill(skill)
    source_model.skills.include?(skill) ? "Yes" : "No"
  end

  class << self
    def skill_header(skill)
      skill
    end
  end
end