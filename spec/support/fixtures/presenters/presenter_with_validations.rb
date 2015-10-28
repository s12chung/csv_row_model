class PresenterWithValidations < CsvRowModel::Import::Presenter
  validates :attribute1, :string2, presence: true

  attribute :attribute1, dependencies: %i[string1 string2] do
    Random.rand
  end

  # handle case with matching name
  def string2; nil end
end