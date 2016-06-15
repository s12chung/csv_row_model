shared_examples "formatted_value_method" do |result|
  subject { instance.formatted_value }

  before do
    row_model_class.class_eval do
      def self.format_cell(*args); args.join("__") end
    end
  end

  it "returns the formatted_cell value and memoizes it" do
    expect(subject).to eql(result)
    expect(subject.object_id).to eql instance.formatted_value.object_id
  end
end