module BlackJackPlayer

  def score
    cards.inject(0) do |sum, i|
      if i.face == 'A' && sum > 10
        sum += 1 # особая логика для туза - его стоитость 11 или 1
      else
        sum += i.value
      end
      sum
    end
  end

  def cards
    return [] unless redis.get "#{subject}_cards"
    cards_array.map do |card_index|
      card_deck.card_instance(card_index)
    end
  end

  def give_cards(n)
    new_cards_array = cards_array + card_deck.take(n)
    redis.set "#{subject}_cards", new_cards_array.to_json
  end

  def reset(reset_money: true)
    redis.pipelined do
      redis.set "#{subject}_money", 1000 if reset_money
      redis.set "#{subject}_stake", 0
      redis.set "#{subject}_cards", [].to_json
      redis.set "#{subject}_score", 0
    end
  end

  private

  def cards_array
    return [] unless redis.get "#{subject}_cards"
    JSON.parse(redis.get "#{subject}_cards")
  end

  def card_deck
    @card_deck ||= CardDeck.instance
  end

  def subject
    self.class.to_s.downcase
  end

  def redis
    @redis ||= Redis.new
  end

end
