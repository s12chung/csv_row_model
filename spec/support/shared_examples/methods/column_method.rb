shared_examples "column_method" do |mod, expectation={}|
  context "when module included before and after #column call" do
    let(:row_model_class) { Class.new }
    before do
      row_model_class.send(:include, CsvRowModel::Model)
      row_model_class.send(:column, :string1)
      row_model_class.send(:include, mod)
      row_model_class.send(:column, :string2)
    end

    it "works" do
      expect(instance.string1).to eql expectation[:string1]
      expect(instance.string2).to eql expectation[:string2]
    end

    context "with method defined before column" do
      let(:row_model_class) do
        Class.new do
          def string1; "custom1" end
          def string2; "custom2" end
        end
      end

      it "does not override those methods" do
        expect(instance.string1).to eql 'custom1'
        expect(instance.string2).to eql 'custom2'
      end
    end
  end
end