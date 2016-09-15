shared_examples "with_or_without_csv_row_model_model" do |mod|
  context "without including CsvRowModel::Model" do
    let(:klass) do
      Class.new do
        include mod

        column :string1
        column :string2
      end
    end

    it "works" do
      test_attributes
    end

    it "has CsvRowModel::Model included" do
      module_indices = [mod, CsvRowModel::Model].map { |c| klass.ancestors.index(c) }
      expect(module_indices).to eql module_indices.sort
    end
  end

  context "has CsvRowModel::Model and another module" do
    let(:klass) do
      Class.new do
        include CsvRowModel::Model
        include CsvRowModel::Inspect
        include mod

        column :string1
        column :string2
      end
    end

    it "works" do
      test_attributes
    end

    it "class order is kept the same" do
      module_indices = [mod, CsvRowModel::Inspect, CsvRowModel::Model].map { |c| klass.ancestors.index(c) }
      expect(module_indices).to eql module_indices.sort
    end
  end
end