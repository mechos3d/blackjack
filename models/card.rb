class Card
  attr_reader :suit, :face

  def initialize(suit:, face:)
    @suit = suit
    @face = face
  end

  def ==(other)
    return false unless other.is_a? Card
    suit == other.suit && face == other.face
  end

  def value(sum = 0)
    if face.is_a?(Fixnum)
      face
    elsif face == 'A'
      sum > 10 ? 1 : 11 # special Ace logic
    else
      10
    end
  end
end
