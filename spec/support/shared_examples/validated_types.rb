shared_examples "validated_types" do
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