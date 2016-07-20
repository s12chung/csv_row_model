require 'spec_helper'

class CheckOptions
  include CsvRowModel::CheckOptions
  VALID_OPTIONS = %i[option1 option2]
end

describe CsvRowModel::CheckOptions do
  describe "class" do
    describe "::check_options" do
      let(:klass) { CheckOptions }

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