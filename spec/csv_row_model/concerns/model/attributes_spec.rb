require 'spec_helper'

describe CsvRowModel::Model::Attributes do
  describe "class" do
    let(:klass) { BasicRowModel }

    describe "::column_names" do
      subject { klass.column_names }
      specify { expect(subject).to eql %i[string1 string2] }
    end

    describe "::format_header" do
      let(:header) { 'user_name' }
      subject { BasicRowModel.format_header(header, nil, nil) }

      it "returns the header" do
        expect(subject).to eql header
      end
    end

    describe "::headers" do
      let(:headers) { [:string1, 'String 2'] }
      subject { klass.headers }

      it "returns an array with header column names" do
        expect(subject).to eql headers
      end
    end

    describe "::format_cell" do
      let(:cell) { "the_cell" }
      subject { BasicRowModel.format_cell(cell, nil, nil, nil) }

      it "returns the cell" do
        expect(subject).to eql cell
      end
    end

    context "with custom class" do
      let(:klass) { Class.new { include CsvRowModel::Model } }

      describe "::column" do
        subject { klass.send(:column, :blah) }

        it "calls ::check_options with the args" do
          expect(klass).to receive(:check_options).with(CsvRowModel::Model::Header,
                                                        CsvRowModel::Import::CsvStringModel::Model,
                                                        CsvRowModel::Import::Attribute,
                                                        {}).once.and_call_original
          subject
        end

        context "with invalid option" do
          subject { klass.send(:column, :blah, invalid_option: true) }

          it "raises error" do
            expect { subject }.to raise_error("Invalid option(s): [:invalid_option]")
          end
        end
      end

      describe "::merge_options" do
        before { klass.send(:column, :blah, type: Integer) }
        subject { klass.send(:merge_options, :blah, default: 1) }

        it "merges the option" do
          result = { blah: { type: Integer, default: 1 }}

          expect { subject }.to change { klass.columns }.from(blah: { type: Integer }).to(result)
          expect(klass.columns_object.raw_value).to eql(result)
        end

        context "with child class class" do
          let(:child_class) { Class.new(klass) }

          subject do
            klass.send(:merge_options, :blah, default: 1)
            child_class.send(:merge_options, :blah, header: "Blah")
          end

          it "passes merged option to child, but not to parent" do
            expect(klass.columns).to eql(blah: { type: Integer })
            expect(klass.columns_object.raw_value).to eql(blah: { type: Integer })

            expect(child_class.columns).to eql(blah: { type: Integer })
            expect(child_class.columns_object.raw_value).to eql({})

            subject

            expect(klass.columns).to eql(blah: { type: Integer, default: 1 })
            expect(klass.columns_object.raw_value).to eql(blah: { type: Integer, default: 1 })

            expect(child_class.columns).to eql(blah: { type: Integer, default: 1, header: "Blah" })
            expect(child_class.columns_object.raw_value).to eql(blah: { header: "Blah" })
          end

          context "with multiple columns" do
            before { %i[blah1 blah2].each {|column_name| klass.send(:column, column_name, type: Integer) } }
            subject { child_class.send(:merge_options, :blah1, default: 1) }

            it "keeps the column_names in the same order " do
              subject
              expect(child_class.column_names).to eql %i[blah blah1 blah2]
            end
          end
        end
      end
    end
  end
end
