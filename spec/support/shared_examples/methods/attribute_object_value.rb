shared_examples "attribute_object_value"  do |method_name, value_method, expectation={} |
  let(:column_name) { expectation.keys.first }
  let(:expected_value) { expectation[column_name] }

  subject { instance.public_send(method_name, column_name) }

  it "works" do
    expect_any_instance_of(instance.attribute_objects.values.first.class).to receive(value_method).and_call_original
    expect(subject).to eql expected_value
  end

  context "invalid column_name" do
    let(:column_name) { :not_a_column }

    it "works" do
      expect(subject).to eql nil
    end
  end
end