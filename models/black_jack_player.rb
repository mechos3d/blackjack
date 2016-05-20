require_relative 'redis_persistence'

class BlackJackPlayer
  include Singleton
  include RedisPersistence

  def score
    cards.inject(0) { |sum, card| card.value(sum) + sum }
  end

  def cards
    return [] unless get_value("#{subject}.cards")
    cards_array.map do |card_index|
      CardDeck::CARD_INSTANCES[card_index]
    end
  end

  def give_cards(n)
    given_cards = card_deck.take(n)
    set_value("#{subject}.cards", (cards_array + given_cards))
  end

  def reset
    set_values("#{subject}.cards" => [],
               "#{subject}.score" => 0)
  end

  private

  def cards_array=(arr)
    set_value("#{subject}.cards", arr)
  end

  def cards_array
    get_value("#{subject}.cards") || []
  end

  def card_deck
    @card_deck ||= CardDeck.instance
  end

  def subject
    self.class.to_s.downcase
  end

end
