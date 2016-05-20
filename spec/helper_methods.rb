def card(face, suit)
  Card.new(face: face, suit: suit)
end

def dealer
  Dealer.instance
end

def player
  Player.instance
end

def card_deck
  CardDeck.instance
end

def set_player_cards(cards)
  arr = cards.map { |i| card_deck_index(card(i.face, i.suit)) }
  player.send(:cards_array=, arr)
end

def score_with(cards)
  cards.map! { |i| Card.new(face: i, suit: :clubs) }
  set_player_cards(cards)
  player.score
end

def card_deck_index(card)
  CardDeck::CARD_INSTANCES.find_index { |dc| dc == card }
end