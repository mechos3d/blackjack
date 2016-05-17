require 'singleton'
require_relative 'redis_persistence'

class CardDeck
  include Singleton
  include RedisPersistence

  attr_reader :card_instances

  def initialize
    @card_instances = []
    [:clubs, :diamonds, :hearts, :spades].each do |suit|
      [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].each do |face|
        @card_instances << Card.new(suit: suit, face: face)
      end
    end
    reset unless cards
  end

  def cards
    get_value('cards')
  end

  def take(n)
    return [] unless n.to_i > 0
    # предусмотреть обработку ситуации, когда n > @cards.size
    taken_cards = cards.take(n)
    set_value('cards', cards[n..-1])
    taken_cards
  end

  def card_instance(n)
    card_instances[n].dup
  end

  def reset
    cards = Array(0..51).shuffle
    set_value('cards', cards)
  end

  def not_enough_cards?
    return true unless cards
    cards.size < 4
  end

  private

  def cards=(arr)
    set_value('cards', arr)
  end
end
