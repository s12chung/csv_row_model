shared_examples "validated_types" do
  context "nil" do
    before { instance.string1 = nil }

    it "is invalid" do
      expect(subject).to eql false
    end
  end

  context "empty String" do
    before { instance.string1 = "" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end

  context "space String" do
    before { instance.string1 = " " }

    it "is invalid" do
      expect(subject).to eql false
    end
  end

  context "random String" do
    before { instance.string1 = "random" }

    it "is invalid" do
      expect(subject).to eql false
    end
  end
end