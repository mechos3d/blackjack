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
      ace_value
    else
      10
    end
  end

  private

  def ace_value
    # Aces are worth 1 or 11 - whichever is preferable at the moment
    11
  end
end
