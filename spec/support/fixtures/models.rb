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
class BasicImportMapper
  include CsvRowModel::Import::Mapper

  maps_to BasicImportModel

  def string2; "mapper" end
end


class ChildImportModel < BasicImportModel
  validates :string1, absence: true
end
class ParentImportModel < BasicImportModel
  has_many :children, ChildImportModel
end
class ParentImportMapper
  include CsvRowModel::Import::Mapper

  maps_to ParentImportModel
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

  # handle case with matching name
  def string2; nil end
end