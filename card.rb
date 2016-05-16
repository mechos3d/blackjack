class Card
  attr_reader :suit, :face, :value

  def initialize(suit:, face:)
    @suit = suit
    @face = face
  end

  def value
    if face.is_a?(Fixnum)
      face
    elsif face == 'A'
      11
    else
      10
    end
  end
end
