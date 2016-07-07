shared_examples "define_attribute_method" do
  it "does not do anything the second time" do
    expect(row_model_class).to receive(:define_proxy_method).with(:waka).once.and_call_original
    expect(row_model_class).to receive(:define_proxy_method).with(:waka2).once.and_call_original

    row_model_class.send(:define_attribute_method, :waka)
    row_model_class.send(:define_attribute_method, :waka)
    row_model_class.send(:define_attribute_method, :waka2)
    row_model_class.send(:define_attribute_method, :waka2)
  end
end