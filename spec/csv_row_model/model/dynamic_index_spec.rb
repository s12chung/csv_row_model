require 'spec_helper'

describe CsvRowModel::Model do

  subject { DynamicColumnModel }

  it 'should given the right index' do
    expect(subject.index(:first_name)).to     eql(0)
    expect(subject.index(:last_name)).to      eql(1)
    expect(subject.dynamic_index(:skills)).to eql(2)
  end
end
