require 'spec_helper'

describe CsvRowModel::Import::File do
  let(:instance) { described_class.new cell_format_rows_path, CellFormatImportModel }

  subject { instance.next }

  it 'should be well formatted' do
    row_model = instance.next

    # Before cell_format call
    expect(row_model.mapped_row).to                      eql({'first_name'=>'Josie        ', 'last_name'=>' Herman'})
    expect(row_model.mapped_row['first_name']).to        eql('Josie        ')
    expect(row_model.mapped_row['last_name']).to         eql(' Herman')

    # After cell format call
    expect(row_model.first_name).to                      eql('Josie')
    expect(row_model.last_name).to                       eql('HERMAN')

    expect(row_model.original_attributes).to             eql({'first_name'=>'Josie', 'last_name'=>'Herman'})
    expect(row_model.original_attribute(:first_name)).to eql('Josie')
    expect(row_model.original_attribute(:last_name)).to  eql('Herman')
  end
end
