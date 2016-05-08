class Subject

  [:money, :score, :stake].each do |method_name|
    define_method(method_name) do
      redis.get("#{subject}_#{method_name}")&.to_i || 0
    end

    define_method("#{method_name}=") do |n|
      redis.set "#{subject}_#{method_name}", n
    end
  end

  def cards
    JSON.parse(redis.get "#{subject}_cards").map do |card_index|
      card_deck.card_instance(card_index)
    end
  end

  private

  def card_deck
    CardDeck.instance
  end

  def subject
    self.class.to_s.downcase
  end

  def redis
    @redis ||= Redis.new
  end

end