class Model
  attr_accessor :string1, :string2

  def initialize(string1, string2)
    @string1 = string1
    @string2 = string2
  end

  def string_value(number)
    "Value Of String #{number}"
  end
end
