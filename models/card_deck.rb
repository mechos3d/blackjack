require 'singleton'
require_relative 'redis_persistence'
require_relative 'card'

class CardDeck
  include Singleton
  include RedisPersistence

  CARD_INSTANCES =
    [:clubs, :diamonds, :hearts, :spades]
      .product([2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'])
        .each_with_index.map do |arr, i|
          Card.new(suit: arr[0], face: arr[1]).freeze
        end.freeze

  def initialize
    reset unless cards
  end

  def take(n)
    return [] unless n.to_i > 0
    # предусмотреть обработку ситуации, когда n > @cards.size
    taken_cards = cards.take(n)
    set_value('cards', cards[n..-1])
    taken_cards
  end

  def reset
    cards = Array(0..51).shuffle
    set_value('cards', cards)
  end

  def not_enough_cards?
    return true unless cards
    cards.size < 4
  end

  def cards
    get_value('cards')
  end

  private

  def cards=(arr)
    set_value('cards', arr)
  end
end
