shared_examples "defines_attributes_methods_safely" do |attributes, mod=described_class|
  let(:row_model_class) do
    Class.new do
      include CsvRowModel::Model
      column :string1
      inner_mod = mod.to_s.deconstantize # CsvRowModel::Import or CsvRowModel::Export for constructor
      include "#{inner_mod}::Base".constantize if inner_mod.present?
      include mod
      column :string2
    end
  end

  subject { instance.attributes }

  it "#attributes works" do
    expect(subject).to eql attributes
  end
end