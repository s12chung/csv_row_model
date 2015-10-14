class Skill < Struct.new(:name, :have)

  class << self
    def all
      ['Organize', 'Clean', 'Punctual', 'Strong', 'Crazy', 'Flexible']
    end
  end
end
