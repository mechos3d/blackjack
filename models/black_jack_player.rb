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
      card_deck.card_instance(card_index)
    end
  end

  def give_cards(n)
    new_cards_array = cards_array + card_deck.take(n)
    set_value("#{subject}.cards", new_cards_array)
  end

  def reset
    set_values("#{subject}.cards" => [],
               "#{subject}.score" => 0)
  end

  private

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
