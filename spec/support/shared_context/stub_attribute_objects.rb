shared_context "stub_attribute_objects" do |hash|
  before do
    allow(instance).to receive(:attribute_objects).and_return(
      Hash[hash.to_a.map { |key, value| [key, OpenStruct.new(value: value)] }]
    )
  end
end