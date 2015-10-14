require 'spec_helper'

describe CsvRowModel::Export::File do

  describe 'instance' do
    let(:first_name) { 'florian' }
    let(:last_name)  { 'bartoletti' }
    let(:model)      { CellFormatModel.new(first_name, last_name) }
    let(:instance)   { described_class.new(CellFormatExportModel, some_context: true)  }

    describe '#generate' do
      include_context 'csv file'

      let(:csv_source) do
        [
          [ 'First Name', 'Last Name'  ],
          [ 'Florian'   , 'BARTOLETTI' ],
        ]
      end

      before do
        instance.generate do |csv|
          csv.append_model(model, another_context: true)
        end
      end

      it 'returns csv string' do
        expect(instance.to_s).to eql csv_string
      end
    end
  end
end
