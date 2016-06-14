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
end

class ChildImportModel < BasicImportModel
  validates :string1, absence: true
  validates :source_row, presence: true # hack before changing how children work
end

class ParentImportModel < BasicImportModel
  has_many :children, ChildImportModel
end

#
# Export
#
class BasicExportModel < BasicRowModel
  include CsvRowModel::Export

  class << self
    def format_cell(cell, _column_name, _column_index, context)
      cell.upcase
    end
  end
end
