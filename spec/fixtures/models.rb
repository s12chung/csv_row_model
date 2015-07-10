class BasicModel
  include CsvRowModel::Model

  column :string1
  column :string2
end

class BasicImportModel < BasicModel
  include CsvRowModel::Import
end

class ParentImportModel < BasicImportModel
  include CsvRowModel::Import

  has_many :children, BasicImportModel
end

class ImportMapper
  include CsvRowModel::Import::Mapper

  memoize :memoized_method

  class << self
    def row_model_class
      BasicImportModel
    end
  end
end
