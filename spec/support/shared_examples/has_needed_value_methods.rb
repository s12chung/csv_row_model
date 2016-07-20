shared_examples "has_needed_value_methods" do |mod=CsvRowModel::AttributesBase|
  mod::ATTRIBUTE_METHODS.values.each do |method_name|
    describe "##{method_name}" do
      subject { instance.public_send(method_name) }

      it "#attributes works" do
        expect(subject).to_not eql nil
      end
    end
  end
end