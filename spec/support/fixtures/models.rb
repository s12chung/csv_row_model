class BasicModel
  include CsvRowModel::Model

  column :string1
  column :string2
end

class BasicImportModel < BasicModel
  include CsvRowModel::Import

  def method_that_raises; raise "test" end

  protected
  def protected_method; end
end

class ParentImportModel < BasicImportModel
  include CsvRowModel::Import

  has_many :children, BasicImportModel
end

class ImportMapper
  include CsvRowModel::Import::Mapper

  maps_to BasicImportModel

  def string2; "mapper" end
end



class ImportModelWithValidations < BasicModel
  include CsvRowModel::Import

  validates :string1, presence: true
end
class DependentImportMapper
  include CsvRowModel::Import::Mapper

  maps_to ImportModelWithValidations

  validates :attribute1, :string2, presence: true

  attribute :attribute1, dependencies: %i[string1 string2] do
    Random.rand
  end

  attribute :attribute2 do
    attribute3
    attribute3
    next

    "never"
  end

  attribute :attribute3 do
    next
    "never touch"
  end

  attribute :attribute4 do
    attribute5
    attribute5
    return

    "never again"
  end

  attribute :attribute5 do
    return
    "never touch again"
  end

  # handle case with matching name
  def string2; nil end
end