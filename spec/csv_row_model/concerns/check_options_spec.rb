require 'spec_helper'

describe CsvRowModel::Concerns::CheckOptions do
  describe "class" do
    describe "::check_options" do
      let(:klass) do
        Class.new do
          include CsvRowModel::Concerns::CheckOptions
          VALID_OPTIONS = %i[option1 option2]
        end
      end

      subject { klass.check_options(option1: nil, option2: nil) }
      it "returns true" do
        expect(subject).to eql true
      end

      context "with invalid option" do
        subject { klass.check_options(option1: nil, invalid_option: nil) }

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError, "Invalid option(s): [:invalid_option]")
        end
      end
    end
  end
end