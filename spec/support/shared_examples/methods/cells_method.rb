# it_behaves_like "cells_method", %i[first_name last_name], CsvRowModel::Import::Cell => 2
shared_examples "cells_method" do |column_names, cell_classes_to_count|
  subject { instance.cells }

  it "returns a hash of cells mapped to their column_name" do
    expect(subject.keys).to eql column_names
    expect(subject.values.map(&:class)).to eql cell_classes_to_count
                                                 .map { |cell_class, count| [cell_class] * count }
                                                 .flatten
  end
end