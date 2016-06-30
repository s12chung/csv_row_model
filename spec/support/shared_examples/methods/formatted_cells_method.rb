shared_examples "formatted_cells_method" do |mod, results|
  subject { instance.formatted_cells }

  before do
    row_model_class.class_eval do
      def self.format_cell(*args); args.join("__") end
    end
  end

  it "returns an array of the formatted_cells" do
    expect(subject).to eql results
  end

  context "with regular column defined" do
    let(:row_model_class) do
      klass = Class.new do
        include CsvRowModel::Model
        column :string1
        dynamic_column :skills
      end
      klass.send(:include, mod)
      klass
    end

    it "it bumps the index up on the formatted cell" do
      expect(subject.first).to eql results.first.gsub("__0__", "__1__")
    end
  end
end