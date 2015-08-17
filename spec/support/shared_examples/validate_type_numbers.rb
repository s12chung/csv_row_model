shared_examples "suffix_zero" do
  context "with suffix zero" do
    before { instance.string1 += "0000" }

    it "is valid" do
      expect(subject).to eql true
    end
  end
end

shared_examples "suffix_decimal_zero" do
  context "with suffix decimal zero" do
    before { instance.string1 += ".0000" }
    it "is valid" do
      expect(subject).to eql true
    end
  end
end

shared_examples "prefix_zero" do
  context "with prefix zero" do
    before { instance.string1 = "0000" + instance.string1 }

    it "is valid" do
      expect(subject).to eql true
    end
  end
end