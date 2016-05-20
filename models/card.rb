class Card
  attr_reader :suit, :face

  def initialize(suit:, face:)
    @suit = suit
    @face = face
  end

  def ==(other_card)
    return false unless other_card.is_a? Card
    suit == other_card.suit && face == other_card.face
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
