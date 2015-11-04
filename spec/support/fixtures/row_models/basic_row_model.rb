class BasicRowModel
  include CsvRowModel::Model

  column :string1
  column :string2, header: 'String 2'
end

#
# Import
#
class BasicImportModel < BasicRowModel
  include CsvRowModel::Import

  def method_that_raises; raise "test" end

  protected
  def protected_method; end
end

class ChildImportModel < BasicImportModel
  validates :string1, absence: true
end

class ParentImportModel < BasicImportModel
  has_many :children, ChildImportModel
end

class ImportModelWithValidations < BasicRowModel
  include CsvRowModel::Import

  validates :string1, presence: true
end

#
# Export
#
class BasicExportModel < BasicRowModel
  include CsvRowModel::Export

  class << self
    def format_cell(cell, _column_name, _column_index)
      cell.upcase
    end
  end
end
