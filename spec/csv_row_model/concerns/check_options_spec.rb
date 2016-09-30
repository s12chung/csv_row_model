require 'spec_helper'

class UsesOptions
  class << self
    def valid_options; %i[option1] end
  end
end

class UsesMoreOptions
  class << self
    def valid_options; %i[option1 option2] end

    def custom_check_options(options) raise ArgumentError.new("UsesMoreOptions raise_error! test") if options[:option1] == "raise_error!" end
  end
end

class DoesNothing; end

class ChecksOptions
  include CsvRowModel::CheckOptions
end

describe CsvRowModel::CheckOptions do
  describe "class" do
    describe "::check_options" do
      let(:klass) { ChecksOptions }

      subject { klass.check_options(UsesOptions, UsesMoreOptions, option1: nil, option2: nil) }
      it "returns true" do
        expect(subject).to eql true
      end

      context "with invalid option" do
        subject { klass.check_options(UsesOptions, UsesMoreOptions, option1: nil, invalid_option: nil) }

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError, "Invalid option(s): [:invalid_option]")
        end
      end

      context "with extra option not used" do
        subject { klass.check_options(UsesOptions, option1: nil, option2: nil) }

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError, "Invalid option(s): [:option2]")
        end
      end

      context "with no valid options set on a class" do
        subject { klass.check_options(UsesOptions, DoesNothing, option1: nil) }

        it "does nothing" do
          subject
        end

        context "with nil key" do
          subject { klass.check_options(UsesOptions, DoesNothing, option1: nil, nil => "blah") }

          it "raises error" do
            expect { subject }.to raise_error(ArgumentError, "Invalid option(s): [nil]")
          end
        end
      end

      context "with custom_check_options Error" do
        subject { klass.check_options(UsesOptions, UsesMoreOptions, option1: "raise_error!", option2: nil) }

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError, "UsesMoreOptions raise_error! test")
        end
      end
    end
  end
end