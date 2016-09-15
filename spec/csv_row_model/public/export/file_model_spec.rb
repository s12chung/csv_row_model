require 'spec_helper'

describe CsvRowModel::Export::FileModel do
  describe 'class' do
    let(:export_model_klass) { FileExportModel }
    let(:source_model) do
      Class.new do
        def string1
          string_value :string1
        end
        def string2
          string_value :string2
        end

        def string_value(number)
          "Value Of String #{number}"
        end
      end.new
    end

    subject { export_model_klass.new(source_model) }

    it '' do
      expect(subject.to_rows).to eql(
        [
          [ ':: - string1 - ::', '', 'Value Of String 1'                      ],
          [ 'String 2'         , '', ''                 , ''                  ],
          [ ''                 , '', ''                 , 'Value Of String 2' ]
        ]
      )
    end
  end
end
