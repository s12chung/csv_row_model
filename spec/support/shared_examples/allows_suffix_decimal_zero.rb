shared_examples "allows_suffix_decimal_zero" do
  context "with suffix decimal zero" do
    before { instance.string1 += ".0000" }
    it "is valid" do
      expect(subject).to eql true
    end
  end
end