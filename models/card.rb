class Card
  attr_reader :suit, :face, :value

  def initialize(suit:, face:)
    @suit = suit
    @face = face
  end

  def value(sum = 0)
    if face.is_a?(Fixnum)
      face
    elsif face == 'A'
      sum > 10 ? 1 : 11 # туз имеет особую логику подсчета - отразить это в тестах
    else
      10
    end
  end
end
