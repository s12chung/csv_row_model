class BasicModel
  include CsvRowModel::Model

  column :string1
  column :string2, header: 'String 2'
end

class BasicImportModel < BasicModel
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

class ImportModelWithValidations < BasicModel
  include CsvRowModel::Import

  validates :string1, presence: true
end
class PresenterWithValidations < CsvRowModel::Import::Presenter
  validates :attribute1, :string2, presence: true

  attribute :attribute1, dependencies: %i[string1 string2] do
    Random.rand
  end

  # handle case with matching name
  def string2; nil end
end

class BasicExportModel < BasicModel
  include CsvRowModel::Export
end

class Model
  attr_accessor :string1, :string2

  def initialize(string1, string2)
    @string1 = string1
    @string2 = string2
  end
end

class BasicRowModel
  include CsvRowModel::Model
  include CsvRowModel::Model::FileModel

  row :string1
  row :string2, header_matchs: ['String 2', 'string two']
end


class BasicRowImportModel < BasicRowModel
  include CsvRowModel::Import
  include CsvRowModel::Import::FileModel
end

class BasicRowExportModel < BasicRowModel
  include CsvRowModel::Export
  include CsvRowModel::Export::FileModel
end
