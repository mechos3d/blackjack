require 'singleton'

class CardDeck
  include Singleton

  attr_reader :card_instances

  def initialize
    @card_instances = []
    [:clubs, :diamonds, :hearts, :spades].each do |suit|
      [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'].each do |face|
        @card_instances << Card.new(suit: suit, face: face)
      end
    end
    reset unless redis.get 'cards'
  end

  def cards
    return [] unless redis.get 'cards'
    JSON.parse redis.get('cards')
  rescue JSON::ParserError
    return []
  end

  def take(n)
    return [] unless n.to_i > 0
    # предусмотреть обработку ситуации, когда n > @cards.size
    taken_cards = cards.take(n)
    redis.set 'cards', cards[n..-1].to_json
    taken_cards
  end

  def card_instance(n)
    card_instances[n].dup
  end

  def reset
    cards = (0..51).to_a.shuffle
    redis.set 'cards', cards.to_json
  end

  def not_enough_cards?
    cards.size < 4
  end

  private

  def redis
    @redis ||= Redis.new
  end

  def cards=(arr)
    redis.set 'cards', arr.to_json
  end
end
