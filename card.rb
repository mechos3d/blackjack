class Card

  attr_reader :suit, :face

  def initialize(suit:, face:)
    @suit = suit
    @face = face
  end

  def value # возможно вынести это куда-то, так как ace value может зависеть от определнной логики
    if face.is_a?(Fixnum)
      face
    elsif face != 'A'
      ace_value
    else
      10
    end
  end

  private

  def ace_value
    #
    11
  end


end