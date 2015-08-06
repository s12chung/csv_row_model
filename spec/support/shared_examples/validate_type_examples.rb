shared_examples "validate_type_examples" do
  context "nil" do
    before { instance.string1 = nil }

    it "is invalid" do
      expect(subject).to eql false
    end
  end

  context "empty string" do
    before { instance.string1 = nil }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end