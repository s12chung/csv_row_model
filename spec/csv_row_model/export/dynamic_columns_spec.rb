require 'spec_helper'

describe CsvRowModel::Export::DynamicColumns do

  subject do
    CsvRowModel::Export::File.new(DynamicColumnExportModel, { skills: Skill.all  })
  end

  let(:models) do
    [ User.new('Josie', 'Herman', Skill.all - ['Clean']) ]
  end

  before do
    subject.generate do |csv|
      models.each do |model| csv << model end
    end
  end

  it 'Should generate right headers and values' do
    expect(subject.to_s).to eql(
      "First Name,Last Name,Organize,Clean,Punctual,Strong,Crazy,Flexible\n" \
      "Josie,Herman,Yes,No,Yes,Yes,Yes,Yes\n"
    )
  end
end
