require 'singleton'

class CardDeck
  include Singleton

  attr_reader :cards, :card_instances

  def initialize
    fill_deck
  end

  def get_cards!(n)
    return [] unless n
    # предусмотреть обработку ситуации, когда n > @cards.size
    @cards.pop(n)
  end

  def card_instance(n)
    self.card_instances[n].dup
  end

  private

  def fill_deck
    @cards =(0..52).to_a.shuffle
    @card_instances = []

    [:clubs, :diamonds, :hearts, :spades].each do |suit|
      [2,3,4,5,6,7,8,9,10,'J','Q','K','A'].each do |face|
        @card_instances << Card.new(suit: suit, face: face)
      end
    end
  end

end
